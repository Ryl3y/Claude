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
from .models import Cotisation, Membre, Paiement, Tontine, Tour
from .permissions import exiger_role
from .serializers import (
    CotisationSerializer, InvitationSerializer, JournalSerializer, MembreSerializer, OrdreSerializer,
    PaiementSerializer, RemiseSerializer, TontineDetailSerializer, TontineSerializer, TourSerializer,
    WebhookSerializer,
)

PRESIDENT, TRESORIER = Membre.Role.PRESIDENT, Membre.Role.TRESORIER


class PaginationRecente(CursorPagination):
    ordering = "-cree_le"


def tours_avec_totaux(tontine):
    return (
        tontine.tours.select_related("beneficiaire__utilisateur")
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
    http_method_names = ["get", "post", "patch", "put"]

    def get_queryset(self):
        return Tontine.objects.filter(
            membres__utilisateur=self.request.user, membres__statut=Membre.Statut.ACTIF
        ).prefetch_related(
            Prefetch("membres", queryset=Membre.objects.select_related("utilisateur"))
        ).distinct()

    def get_serializer_class(self):
        return TontineDetailSerializer if self.action == "retrieve" else TontineSerializer

    def perform_create(self, serializer):
        serializer.instance = services.creer_tontine(self.request.user, **serializer.validated_data)

    def update(self, request, *args, **kwargs):
        if not kwargs.get("partial"):
            return Response(status=status.HTTP_405_METHOD_NOT_ALLOWED)
        tontine = self.get_object()
        exiger_role(tontine, request.user, PRESIDENT)
        if tontine.statut != Tontine.Statut.BROUILLON:
            raise services.ErreurMetier("tontine_demarree", "Les paramètres sont figés après le démarrage.")
        return super().update(request, *args, **kwargs)

    @action(detail=True, methods=["post"])
    def invitations(self, request, pk=None):
        tontine = self.get_object()
        exiger_role(tontine, request.user, PRESIDENT)
        entree = InvitationSerializer(data=request.data)
        entree.is_valid(raise_exception=True)
        invitation = services.creer_invitation(tontine, request.user, entree.validated_data["telephone"])
        return Response(InvitationSerializer(invitation).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["put"])
    def ordre(self, request, pk=None):
        tontine = self.get_object()
        exiger_role(tontine, request.user, PRESIDENT)
        entree = OrdreSerializer(data=request.data)
        entree.is_valid(raise_exception=True)
        services.definir_ordre(tontine, request.user, entree.validated_data["membres"])
        membres = tontine.membres.select_related("utilisateur").order_by("position_tour")
        return Response(MembreSerializer(membres, many=True).data)

    @action(detail=True, methods=["post"])
    def demarrer(self, request, pk=None):
        tontine = self.get_object()
        exiger_role(tontine, request.user, PRESIDENT)
        tontine = services.demarrer_tontine(tontine, request.user)
        return Response(TourSerializer(tours_avec_totaux(tontine), many=True).data)

    @action(detail=True, methods=["get"])
    def tours(self, request, pk=None):
        tontine = self.get_object()
        return Response(TourSerializer(tours_avec_totaux(tontine), many=True).data)

    @action(detail=True, methods=["get"])
    def journal(self, request, pk=None):
        tontine = self.get_object()
        exiger_role(tontine, request.user, PRESIDENT)
        page = self.paginate_queryset(tontine.journal.select_related("acteur"))
        return self.get_paginated_response(JournalSerializer(page, many=True).data)


@api_view(["POST"])
def accepter_invitation(request, code):
    membre = services.accepter_invitation(code, request.user)
    return Response(MembreSerializer(membre).data, status=status.HTTP_201_CREATED)


@api_view(["GET"])
def cotisations_du_tour(request, pk):
    tour = get_object_or_404(Tour, pk=pk)
    exiger_role(tour.tontine, request.user)
    cotisations = tour.cotisations.select_related("membre__utilisateur").order_by("membre__position_tour")
    return Response(CotisationSerializer(cotisations, many=True).data)


@api_view(["POST"])
def payer_cotisation(request, pk):
    """Espèces : enregistré par le trésorier ou le président.
    Mobile Money : lancé par le membre lui-même, confirmé ensuite par le webhook."""
    cotisation = get_object_or_404(Cotisation.objects.select_related("tour__tontine", "membre"), pk=pk)
    membre = exiger_role(cotisation.tour.tontine, request.user)
    entree = PaiementSerializer(data=request.data)
    entree.is_valid(raise_exception=True)
    donnees = entree.validated_data
    if donnees["moyen"] == Paiement.Moyen.ESPECES:
        if membre.role not in (PRESIDENT, TRESORIER):
            raise PermissionDenied("Seuls le trésorier et le président enregistrent les espèces.")
    elif cotisation.membre_id != membre.pk:
        raise PermissionDenied("Vous ne pouvez payer par Mobile Money que vos propres cotisations.")
    paiement = services.enregistrer_paiement(
        cotisation, request.user, donnees["montant"], donnees["moyen"], donnees.get("reference_externe")
    )
    return Response(PaiementSerializer(paiement).data, status=status.HTTP_201_CREATED)


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
