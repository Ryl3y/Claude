"""Règles métier de TONTINE+.

Chaque opération qui modifie l'état d'une tontine est une transaction unique,
verrouille les lignes concernées et écrit une entrée dans le journal d'audit.
"""

import calendar
import secrets
import uuid
from datetime import date, timedelta

from django.db import transaction
from django.db.models import F
from django.utils import timezone

from . import mobile_money
from .models import Cotisation, Invitation, JournalAudit, Membre, Paiement, Penalite, Tontine, Tour


class ErreurMetier(Exception):
    """Refus d'une opération pour une raison métier (renvoyé en HTTP 409)."""

    def __init__(self, code, message):
        super().__init__(message)
        self.code = code
        self.message = message


def journaliser(tontine, acteur, action, **details):
    JournalAudit.objects.create(tontine=tontine, acteur=acteur, action=action, details=details)


def ajouter_mois(jour: date, mois: int) -> date:
    """Même jour, `mois` mois plus tard ; le 31 janvier + 1 mois donne le dernier jour de février."""
    annee, index = divmod(jour.month - 1 + mois, 12)
    annee += jour.year
    dernier_jour = calendar.monthrange(annee, index + 1)[1]
    return date(annee, index + 1, min(jour.day, dernier_jour))


def echeance(tontine: Tontine, numero: int) -> date:
    """Date d'échéance du tour `numero` (1 = date de début)."""
    debut = tontine.date_debut
    if tontine.frequence == Tontine.Frequence.HEBDOMADAIRE:
        return debut + timedelta(weeks=numero - 1)
    if tontine.frequence == Tontine.Frequence.QUINZAINE:
        return debut + timedelta(weeks=2 * (numero - 1))
    return ajouter_mois(debut, numero - 1)


@transaction.atomic
def creer_tontine(createur, **donnees) -> Tontine:
    tontine = Tontine.objects.create(cree_par=createur, **donnees)
    Membre.objects.create(
        tontine=tontine, utilisateur=createur, role=Membre.Role.PRESIDENT, position_tour=1
    )
    journaliser(tontine, createur, "creation")
    return tontine


def creer_invitation(tontine: Tontine, acteur, telephone: str) -> Invitation:
    if tontine.statut != Tontine.Statut.BROUILLON:
        raise ErreurMetier("tontine_demarree", "On ne peut plus inviter une fois la tontine démarrée.")
    invitation = Invitation.objects.create(
        tontine=tontine,
        telephone=telephone,
        code=secrets.token_urlsafe(12),
        invite_par=acteur,
        expire_le=timezone.now() + timedelta(days=7),
    )
    journaliser(tontine, acteur, "invitation", telephone=telephone)
    return invitation


@transaction.atomic
def accepter_invitation(code: str, utilisateur) -> Membre:
    try:
        invitation = Invitation.objects.select_for_update().select_related("tontine").get(code=code)
    except Invitation.DoesNotExist:
        raise ErreurMetier("invitation_inconnue", "Ce lien d'invitation n'existe pas.")
    if invitation.acceptee_le or invitation.expire_le < timezone.now():
        raise ErreurMetier("invitation_expiree", "Cette invitation a expiré ou a déjà servi.")
    if invitation.telephone != utilisateur.telephone:
        raise ErreurMetier("invitation_autre_numero", "Cette invitation est destinée à un autre numéro.")

    tontine = Tontine.objects.select_for_update().get(pk=invitation.tontine_id)
    if tontine.statut != Tontine.Statut.BROUILLON:
        raise ErreurMetier("tontine_demarree", "La tontine a déjà démarré.")
    membres = tontine.membres.filter(statut=Membre.Statut.ACTIF)
    if membres.count() >= tontine.nb_membres_max:
        raise ErreurMetier("tontine_complete", "La tontine a atteint son nombre maximum de membres.")
    if membres.filter(utilisateur=utilisateur).exists():
        raise ErreurMetier("deja_membre", "Vous êtes déjà membre de cette tontine.")

    position = (membres.order_by("-position_tour").values_list("position_tour", flat=True).first() or 0) + 1
    membre = Membre.objects.create(tontine=tontine, utilisateur=utilisateur, position_tour=position)
    invitation.acceptee_le = timezone.now()
    invitation.save(update_fields=["acceptee_le"])
    journaliser(tontine, utilisateur, "adhesion", membre_id=membre.pk)
    return membre


@transaction.atomic
def definir_ordre(tontine: Tontine, acteur, ids_membres: list[int]) -> None:
    tontine = Tontine.objects.select_for_update().get(pk=tontine.pk)
    if tontine.statut != Tontine.Statut.BROUILLON:
        raise ErreurMetier("tontine_demarree", "L'ordre est figé une fois la tontine démarrée.")
    membres = {m.pk: m for m in tontine.membres.filter(statut=Membre.Statut.ACTIF)}
    if sorted(ids_membres) != sorted(membres):
        raise ErreurMetier("ordre_incomplet", "L'ordre doit contenir chaque membre actif une seule fois.")
    # Deux passes pour ne pas heurter la contrainte d'unicité des positions.
    Membre.objects.filter(pk__in=ids_membres).update(position_tour=None)
    for position, pk in enumerate(ids_membres, start=1):
        Membre.objects.filter(pk=pk).update(position_tour=position)
    journaliser(tontine, acteur, "ordre_defini", ordre=ids_membres)


@transaction.atomic
def demarrer_tontine(tontine: Tontine, acteur) -> Tontine:
    """Fige les membres, génère les N tours et les N × N cotisations."""
    tontine = Tontine.objects.select_for_update().get(pk=tontine.pk)
    if tontine.statut != Tontine.Statut.BROUILLON:
        raise ErreurMetier("deja_demarree", "Cette tontine a déjà démarré.")
    membres = list(tontine.membres.filter(statut=Membre.Statut.ACTIF))
    if len(membres) < 2:
        raise ErreurMetier("membres_insuffisants", "Il faut au moins 2 membres pour démarrer.")
    if tontine.mode_attribution == Tontine.ModeAttribution.ENCHERE:
        raise ErreurMetier("mode_non_disponible", "Le mode enchère n'est pas encore disponible.")

    if tontine.mode_attribution == Tontine.ModeAttribution.TIRAGE_AU_SORT:
        secrets.SystemRandom().shuffle(membres)
    else:
        membres.sort(key=lambda m: (m.position_tour is None, m.position_tour, m.pk))
    Membre.objects.filter(pk__in=[m.pk for m in membres]).update(position_tour=None)
    for position, membre in enumerate(membres, start=1):
        membre.position_tour = position
        membre.save(update_fields=["position_tour"])

    if tontine.date_debut is None:
        tontine.date_debut = timezone.localdate()
    for membre in membres:
        tour = Tour.objects.create(
            tontine=tontine,
            numero=membre.position_tour,
            date_echeance=echeance(tontine, membre.position_tour),
            beneficiaire=membre,
        )
        Cotisation.objects.bulk_create(
            Cotisation(tour=tour, membre=m, montant_du=tontine.montant_cotisation) for m in membres
        )

    tontine.statut = Tontine.Statut.ACTIVE
    tontine.save(update_fields=["statut", "date_debut"])
    journaliser(tontine, acteur, "demarrage", ordre=[m.pk for m in membres])
    return tontine


def _crediter(cotisation: Cotisation, montant: int) -> None:
    """Ajoute un paiement réussi au montant payé et met à jour le statut."""
    Cotisation.objects.filter(pk=cotisation.pk).update(montant_paye=F("montant_paye") + montant)
    cotisation.refresh_from_db()
    if cotisation.montant_paye >= cotisation.montant_du:
        cotisation.statut = Cotisation.Statut.PAYEE
        cotisation.soldee_le = timezone.now()
    elif cotisation.statut != Cotisation.Statut.EN_RETARD:
        cotisation.statut = Cotisation.Statut.PARTIELLE
    cotisation.save(update_fields=["statut", "soldee_le"])


@transaction.atomic
def enregistrer_paiement(cotisation: Cotisation, acteur, montant: int, moyen: str,
                         reference_externe: str | None = None) -> Paiement:
    cotisation = Cotisation.objects.select_for_update().select_related("tour__tontine").get(pk=cotisation.pk)
    tontine = cotisation.tour.tontine
    if tontine.statut != Tontine.Statut.ACTIVE:
        raise ErreurMetier("tontine_inactive", "La tontine n'est pas active.")
    if cotisation.statut == Cotisation.Statut.PAYEE:
        raise ErreurMetier("deja_payee", "Cette cotisation est déjà soldée.")
    if montant > cotisation.reste_a_payer:
        raise ErreurMetier("montant_trop_eleve", f"Il reste {cotisation.reste_a_payer} FCFA à payer.")

    especes = moyen == Paiement.Moyen.ESPECES
    paiement = Paiement.objects.create(
        cotisation=cotisation,
        montant=montant,
        moyen=moyen,
        reference_externe=reference_externe,
        enregistre_par=acteur,
        statut=Paiement.Statut.REUSSI if especes else Paiement.Statut.INITIE,
        confirme_le=timezone.now() if especes else None,
    )
    if especes:
        _crediter(cotisation, montant)
    journaliser(tontine, acteur, "paiement", paiement_id=paiement.pk, montant=montant, moyen=moyen)
    return paiement


def confirmer_paiement_mobile(reference_externe: str, reussi: bool) -> tuple[Paiement, bool]:
    """Traite un webhook Mobile Money. Renvoie (paiement, deja_traite).

    Idempotent : un webhook rejoué pour un paiement déjà confirmé ne crédite pas deux fois.
    """
    with transaction.atomic():
        try:
            paiement = Paiement.objects.select_for_update().get(reference_externe=reference_externe)
        except Paiement.DoesNotExist:
            raise ErreurMetier("paiement_inconnu", "Aucun paiement pour cette référence.")
        if paiement.statut != Paiement.Statut.INITIE:
            return paiement, True
        paiement.statut = Paiement.Statut.REUSSI if reussi else Paiement.Statut.ECHOUE
        paiement.confirme_le = timezone.now()
        paiement.save(update_fields=["statut", "confirme_le"])
        if reussi:
            cotisation = Cotisation.objects.select_for_update().get(pk=paiement.cotisation_id)
            _crediter(cotisation, paiement.montant)
        journaliser(
            paiement.cotisation.tour.tontine, None, "confirmation_mobile_money",
            paiement_id=paiement.pk, reussi=reussi,
        )
        return paiement, False


@transaction.atomic
def changer_role(tontine: Tontine, acteur, membre_id: int, role: str) -> Membre:
    """Nomme ou retire le trésorier. Il n'y a qu'un trésorier ; le président garde son rôle."""
    if role not in (Membre.Role.TRESORIER, Membre.Role.MEMBRE):
        raise ErreurMetier("role_invalide", "Rôle attribuable : trésorier ou membre.")
    membre = Membre.objects.select_for_update().filter(
        tontine=tontine, pk=membre_id, statut=Membre.Statut.ACTIF
    ).first()
    if membre is None:
        raise ErreurMetier("membre_inconnu", "Ce membre n'appartient pas à la tontine.")
    if membre.role == Membre.Role.PRESIDENT:
        raise ErreurMetier("role_president", "Le rôle du président ne peut pas être changé.")
    if role == Membre.Role.TRESORIER:
        tontine.membres.filter(role=Membre.Role.TRESORIER).exclude(pk=membre.pk).update(role=Membre.Role.MEMBRE)
    membre.role = role
    membre.save(update_fields=["role"])
    journaliser(tontine, acteur, "changement_role", membre_id=membre.pk, role=role)
    return membre


def lancer_paiement_mobile(cotisation: Cotisation, acteur, moyen: str, telephone: str) -> Paiement:
    """Demande au fournisseur de débiter le payeur du reste dû ; le crédit vient à la confirmation."""
    with transaction.atomic():
        cotisation = Cotisation.objects.select_for_update().select_related("tour__tontine").get(pk=cotisation.pk)
        if cotisation.tour.tontine.statut != Tontine.Statut.ACTIVE:
            raise ErreurMetier("tontine_inactive", "La tontine n'est pas active.")
        if cotisation.statut == Cotisation.Statut.PAYEE:
            raise ErreurMetier("deja_payee", "Cette cotisation est déjà soldée.")
        if cotisation.paiements.filter(statut=Paiement.Statut.INITIE).exists():
            raise ErreurMetier("paiement_en_cours", "Un paiement est déjà en attente de validation.")
        paiement = Paiement.objects.create(
            cotisation=cotisation, montant=cotisation.reste_a_payer, moyen=moyen,
            reference_externe=str(uuid.uuid4()), telephone_payeur=telephone, enregistre_par=acteur,
        )
        journaliser(cotisation.tour.tontine, acteur, "paiement_mobile_lance",
                    paiement_id=paiement.pk, moyen=moyen, montant=paiement.montant)
    # Appel réseau hors transaction : le paiement est déjà enregistré « initié ».
    try:
        mobile_money.fournisseur(moyen).demander_paiement(paiement)
    except mobile_money.FournisseurIndisponible as exc:
        Paiement.objects.filter(pk=paiement.pk).update(statut=Paiement.Statut.ECHOUE, confirme_le=timezone.now())
        raise ErreurMetier("fournisseur_indisponible", str(exc))
    return paiement


def actualiser_paiement(paiement: Paiement) -> Paiement:
    """Relit le statut chez le fournisseur et crédite la cotisation si le paiement a réussi."""
    if paiement.statut != Paiement.Statut.INITIE or paiement.moyen == Paiement.Moyen.ESPECES:
        return paiement
    try:
        etat = mobile_money.fournisseur(paiement.moyen).statut(paiement)
    except mobile_money.FournisseurIndisponible:
        return paiement
    if etat != mobile_money.EN_ATTENTE:
        paiement, _ = confirmer_paiement_mobile(paiement.reference_externe, etat == mobile_money.REUSSI)
    return paiement


@transaction.atomic
def remettre_caisse(tour: Tour, acteur, forcer: bool = False) -> Tour:
    tour = Tour.objects.select_for_update().select_related("tontine").get(pk=tour.pk)
    if tour.statut == Tour.Statut.CLOS:
        raise ErreurMetier("tour_clos", "La caisse de ce tour a déjà été remise.")
    precedent_ouvert = Tour.objects.filter(
        tontine=tour.tontine, numero__lt=tour.numero
    ).exclude(statut=Tour.Statut.CLOS).exists()
    if precedent_ouvert:
        raise ErreurMetier("tour_precedent_ouvert", "Le tour précédent n'est pas clos.")
    impayees = tour.cotisations.exclude(statut=Cotisation.Statut.PAYEE).count()
    if impayees and not forcer:
        raise ErreurMetier("cotisations_impayees", f"{impayees} cotisation(s) non soldée(s) pour ce tour.")

    tour.montant_remis = sum(tour.cotisations.values_list("montant_paye", flat=True))
    tour.statut = Tour.Statut.CLOS
    tour.remis_le = timezone.now()
    tour.save(update_fields=["montant_remis", "statut", "remis_le"])
    journaliser(tour.tontine, acteur, "remise", tour=tour.numero, montant=tour.montant_remis, forcee=forcer)

    if not tour.tontine.tours.exclude(statut=Tour.Statut.CLOS).exists():
        Tontine.objects.filter(pk=tour.tontine_id).update(statut=Tontine.Statut.TERMINEE)
        journaliser(tour.tontine, acteur, "fin_de_cycle")
    return tour


def marquer_retards(aujourd_hui: date | None = None) -> int:
    """Passe en retard les cotisations échues non soldées et crée leur pénalité.

    Lancé chaque jour par la commande `manage.py marquer_retards`. Renvoie le nombre traité.
    """
    aujourd_hui = aujourd_hui or timezone.localdate()
    traitees = 0
    echues = Cotisation.objects.filter(
        tour__date_echeance__lt=aujourd_hui,
        tour__tontine__statut=Tontine.Statut.ACTIVE,
        statut__in=[Cotisation.Statut.DUE, Cotisation.Statut.PARTIELLE],
    ).select_related("tour__tontine")
    for cotisation in echues:
        with transaction.atomic():
            cotisation.statut = Cotisation.Statut.EN_RETARD
            cotisation.save(update_fields=["statut"])
            penalite = cotisation.tour.tontine.penalite_retard
            if penalite:
                Penalite.objects.create(
                    cotisation=cotisation, montant=penalite,
                    motif=f"Retard au tour {cotisation.tour.numero}",
                )
            traitees += 1
    # Ouvre les tours dont l'échéance approche (3 jours).
    Tour.objects.filter(
        statut=Tour.Statut.A_VENIR,
        tontine__statut=Tontine.Statut.ACTIVE,
        date_echeance__lte=aujourd_hui + timedelta(days=3),
    ).update(statut=Tour.Statut.OUVERT)
    return traitees

