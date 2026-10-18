import hashlib
import hmac

from django.conf import settings
from django.db.models import Count, Prefetch, Q, Sum
from django.shortcuts import get_object_or_404
from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action, api_view, authentication_classes, permission_classes
from rest_framework.exceptions import PermissionDenied
from rest_framework.pagination import CursorPagination
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from . import services
from .models import Cotisation, Designation, Membre, Nom, Paiement, Penalite, Tontine, Tour
from .permissions import exiger_role
from .serializers import (
    CotisationSerializer, DesignationEntreeSerializer, DesignationSerializer, InvitationSerializer,
    JournalSerializer, MembreSerializer, PaiementEntreeSerializer, PaiementSerializer, PenaliteSerializer,
    RemiseSerializer, RoleSerializer, TontineDetailSerializer, TontineSerializer, TourSerializer, VoteSerializer,
    WebhookSerializer,
)

PRESIDENT, TRESORIER = Membre.Role.PRESIDENT, Membre.Role.TRESORIER
BUREAU = [r for r in Membre.Role.values if r != Membre.Role.MEMBRE]


class PaginationRecente(CursorPagination):
    ordering = "-cree_le"


def tours_avec_totaux(tontine):
    return (
        tontine.tours.select_related("beneficiaire__membre__utilisateur")
        .annotate(
            montant_attendu=Sum("cotisations__montant_du", default=0),
            montant_collecte=Sum("cotisations__montant_paye", default=0),
            nb_impayes=Count("cotisations", filter=~Q(cotisations__statut=Cotisation.Statut.PAYEE)),
        )
        .order_by("numero")
    )


class TontineViewSet(mixins.CreateModelMixin, mixins.RetrieveModelMixin, mixins.UpdateModelMixin,
                     mixins.ListModelMixin, viewsets.GenericViewSet):
    """Tontines dont l'utilisateur est membre actif."""

    pagination_class = PaginationRecente
    http_method_names = ["get", "post", "patch", "put", "delete"]

    def get_queryset(self):
        return Tontine.objects.filter(
            membres__utilisateur=self.request.user, membres__statut=Membre.Statut.ACTIF
        ).prefetch_related(
            Prefetch("membres", queryset=Membre.objects.select_related("utilisateur").prefetch_related("noms")),
            Prefetch("noms", queryset=Nom.objects.select_related("membre__utilisateur")
                     .prefetch_related("membre__noms")),
        ).distinct()

    def detail_a_jour(self, tontine):
        """Le détail relu après une modification (membres, noms et ordre à jour)."""
        return Response(TontineDetailSerializer(self.get_queryset().get(pk=tontine.pk)).data)

    def tontine_du_president(self):
        tontine = self.get_object()
        exiger_role(tontine, self.request.user, PRESIDENT)
        return tontine

    def get_serializer_class(self):
        return TontineDetailSerializer if self.action == "retrieve" else TontineSerializer

    def perform_create(self, serializer):
        serializer.instance = services.creer_tontine(self.request.user, **serializer.validated_data)

    def update(self, request, *args, **kwargs):
        if not kwargs.get("partial"):
            return Response(status=status.HTTP_405_METHOD_NOT_ALLOWED)
        tontine = self.tontine_du_president()
        entree = TontineSerializer(tontine, data=request.data, partial=True)
        entree.is_valid(raise_exception=True)
        services.modifier_tontine(tontine, request.user, **entree.validated_data)
        return self.detail_a_jour(tontine)

    def destroy(self, request, *args, **kwargs):
        return Response(status=status.HTTP_405_METHOD_NOT_ALLOWED)

    @action(detail=True, methods=["post"])
    def annuler(self, request, pk=None):
        tontine = services.annuler_tontine(self.tontine_du_president(), request.user)
        return self.detail_a_jour(tontine)

    @action(detail=True, methods=["post"], url_path="nouveau-cycle")
    def nouveau_cycle(self, request, pk=None):
        nouvelle = services.nouveau_cycle(self.tontine_du_president(), request.user)
        return Response(TontineDetailSerializer(self.get_queryset().get(pk=nouvelle.pk)).data,
                        status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"])
    def invitations(self, request, pk=None):
        tontine = self.tontine_du_president()
        entree = InvitationSerializer(data=request.data)
        entree.is_valid(raise_exception=True)
        invitation = services.creer_invitation(tontine, request.user, entree.validated_data["telephone"])
        return Response(InvitationSerializer(invitation).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["post"], url_path=r"membres/(?P<membre_id>\d+)/noms")
    def ajouter_nom(self, request, pk=None, membre_id=None):
        tontine = self.tontine_du_president()
        services.ajouter_nom(tontine, request.user, int(membre_id))
        return self.detail_a_jour(tontine)

    @action(detail=True, methods=["delete"], url_path=r"noms/(?P<nom_id>\d+)")
    def retirer_nom(self, request, pk=None, nom_id=None):
        tontine = self.tontine_du_president()
        services.retirer_nom(tontine, request.user, int(nom_id))
        return self.detail_a_jour(tontine)

    @action(detail=True, methods=["delete"], url_path=r"membres/(?P<membre_id>\d+)")
    def retirer_membre(self, request, pk=None, membre_id=None):
        tontine = self.tontine_du_president()
        services.retirer_membre(tontine, request.user, int(membre_id))
        return self.detail_a_jour(tontine)

    @action(detail=True, methods=["put"], url_path=r"membres/(?P<membre_id>\d+)/role")
    def role(self, request, pk=None, membre_id=None):
        tontine = self.tontine_du_president()
        entree = RoleSerializer(data=request.data)
        entree.is_valid(raise_exception=True)
        services.changer_role(tontine, request.user, int(membre_id), entree.validated_data["role"])
        return self.detail_a_jour(tontine)

    @action(detail=True, methods=["post"])
    def demarrer(self, request, pk=None):
        tontine = services.demarrer_tontine(self.tontine_du_president(), request.user)
        return Response(TourSerializer(tours_avec_totaux(tontine), many=True).data)

    @action(detail=True, methods=["get"])
    def tours(self, request, pk=None):
        tontine = self.get_object()
        return Response(TourSerializer(tours_avec_totaux(tontine), many=True).data)

    @action(detail=True, methods=["get"])
    def journal(self, request, pk=None):
        tontine = self.get_object()
        exiger_role(tontine, request.user, *BUREAU)
        page = self.paginate_queryset(tontine.journal.select_related("acteur"))
        return self.get_paginated_response(JournalSerializer(page, many=True).data)

    @action(detail=True, methods=["get"])
    def designations(self, request, pk=None):
        """Toutes les demandes de désignation, visibles par chaque membre (transparence)."""
        tontine = self.get_object()
        membre = exiger_role(tontine, request.user)
        demandes = (Designation.objects.filter(tour__tontine=tontine)
                    .select_related("tour__tontine", "nom__membre__utilisateur", "propose_par__utilisateur")
                    .prefetch_related("votes"))
        return Response(DesignationSerializer(demandes, many=True, context={"membre": membre}).data)


@api_view(["POST"])
def accepter_invitation(request, code):
    membre = services.accepter_invitation(code, request.user)
    return Response(MembreSerializer(membre).data, status=status.HTTP_201_CREATED)


@api_view(["GET"])
def cotisations_du_tour(request, pk):
    tour = get_object_or_404(Tour, pk=pk)
    exiger_role(tour.tontine, request.user)
    cotisations = (tour.cotisations.select_related("membre__utilisateur", "tour__tontine")
                   .prefetch_related("penalites").order_by("membre__id"))
    return Response(CotisationSerializer(cotisations, many=True).data)


@api_view(["POST"])
def payer_cotisation(request, pk):
    """Espèces : enregistré par le trésorier ou le président.
    Mobile Money : lancé par le membre pour sa propre cotisation, crédité à la confirmation."""
    cotisation = get_object_or_404(Cotisation.objects.select_related("tour__tontine", "membre"), pk=pk)
    membre = exiger_role(cotisation.tour.tontine, request.user)
    entree = PaiementEntreeSerializer(data=request.data)
    entree.is_valid(raise_exception=True)
    donnees = entree.validated_data
    if donnees["moyen"] == Paiement.Moyen.ESPECES:
        if membre.role not in (PRESIDENT, TRESORIER):
            raise PermissionDenied("Seuls le trésorier et le président enregistrent les espèces.")
        paiement = services.enregistrer_paiement(cotisation, request.user, donnees["montant"], donnees["moyen"])
    else:
        if cotisation.membre_id != membre.pk:
            raise PermissionDenied("Vous ne pouvez payer par Mobile Money que vos propres cotisations.")
        telephone = donnees.get("telephone", request.user.telephone)
        paiement = services.lancer_paiement_mobile(cotisation, request.user, donnees["moyen"], telephone)
    return Response(PaiementSerializer(paiement).data, status=status.HTTP_201_CREATED)


@api_view(["GET"])
def detail_paiement(request, pk):
    """Suivi d'un paiement : relit le statut chez le fournisseur tant qu'il est en attente."""
    paiement = get_object_or_404(Paiement.objects.select_related("cotisation__tour__tontine"), pk=pk)
    membre = exiger_role(paiement.cotisation.tour.tontine, request.user)
    if paiement.enregistre_par_id != request.user.pk and membre.role not in (PRESIDENT, TRESORIER):
        raise PermissionDenied("Ce paiement ne vous concerne pas.")
    return Response(PaiementSerializer(services.actualiser_paiement(paiement)).data)


@api_view(["POST"])
def encaisser_penalite(request, pk):
    penalite = get_object_or_404(Penalite.objects.select_related("cotisation__tour__tontine"), pk=pk)
    exiger_role(penalite.cotisation.tour.tontine, request.user, PRESIDENT, TRESORIER)
    return Response(PenaliteSerializer(services.encaisser_penalite(penalite, request.user)).data)


@api_view(["POST"])
def tirage_du_tour(request, pk):
    tour = get_object_or_404(Tour.objects.select_related("tontine"), pk=pk)
    exiger_role(tour.tontine, request.user, *BUREAU)
    tour = services.tirer_au_sort(tour, request.user)
    return Response(TourSerializer(tours_avec_totaux(tour.tontine).get(pk=tour.pk)).data)


@api_view(["POST"])
def proposer_designation(request, pk):
    tour = get_object_or_404(Tour.objects.select_related("tontine"), pk=pk)
    membre = exiger_role(tour.tontine, request.user, *BUREAU)
    entree = DesignationEntreeSerializer(data=request.data)
    entree.is_valid(raise_exception=True)
    designation = services.proposer_designation(tour, membre, entree.validated_data["nom"],
                                                entree.validated_data["motif"])
    return Response(DesignationSerializer(designation, context={"membre": membre}).data,
                    status=status.HTTP_201_CREATED)


@api_view(["POST"])
def voter_designation(request, pk):
    designation = get_object_or_404(Designation.objects.select_related("tour__tontine"), pk=pk)
    membre = exiger_role(designation.tour.tontine, request.user, *BUREAU)
    entree = VoteSerializer(data=request.data)
    entree.is_valid(raise_exception=True)
    designation = services.voter_designation(designation, membre, entree.validated_data["approuve"])
    return Response(DesignationSerializer(designation, context={"membre": membre}).data)


@api_view(["POST"])
def remise_du_tour(request, pk):
    tour = get_object_or_404(Tour.objects.select_related("tontine"), pk=pk)
    membre = exiger_role(tour.tontine, request.user, PRESIDENT, TRESORIER)
    entree = RemiseSerializer(data=request.data)
    entree.is_valid(raise_exception=True)
    forcer = entree.validated_data["forcer"]
    if forcer and membre.role != PRESIDENT:
        raise PermissionDenied("Seul le président peut forcer une remise incomplète.")
    tour = services.remettre_caisse(tour, request.user, forcer=forcer)
    return Response(TourSerializer(tours_avec_totaux(tour.tontine).get(pk=tour.pk)).data)


@api_view(["POST"])
@authentication_classes([])
@permission_classes([AllowAny])
def webhook_mobile_money(request, fournisseur):
    """Confirmation envoyée par le fournisseur, signée en HMAC-SHA256 dans l'en-tête X-Signature."""
    secret = settings.MOBILE_MONEY_WEBHOOK_SECRET.encode()
    attendue = hmac.new(secret, request.body, hashlib.sha256).hexdigest()
    if not secret or not hmac.compare_digest(attendue, request.headers.get("X-Signature", "")):
        raise PermissionDenied("Signature invalide.")
    entree = WebhookSerializer(data=request.data)
    entree.is_valid(raise_exception=True)
    paiement, deja_traite = services.confirmer_paiement_mobile(
        entree.validated_data["reference_externe"], entree.validated_data["reussi"]
    )
    return Response({"statut": paiement.statut, "deja_traite": deja_traite})


@api_view(["POST", "PUT"])
@authentication_classes([])
@permission_classes([AllowAny])
def callback_mtn(request):
    """Notification MTN MoMo (non signée) : on ne croit pas son contenu, on relit le statut chez MTN."""
    reference = request.data.get("externalId") if isinstance(request.data, dict) else None
    paiement = Paiement.objects.filter(reference_externe=reference, moyen=Paiement.Moyen.MTN_MOMO).first()
    if paiement:
        services.actualiser_paiement(paiement)
    return Response(status=status.HTTP_204_NO_CONTENT)
