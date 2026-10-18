"""Règles métier de TONTINE+.

Chaque opération qui modifie l'état d'une tontine est une transaction unique,
verrouille les lignes concernées et écrit une entrée dans le journal d'audit.
"""

import calendar
import secrets
import uuid
from collections import Counter
from datetime import date, timedelta

from django.db import transaction
from django.db.models import F, Max
from django.utils import timezone

from . import mobile_money
from .models import Cotisation, Invitation, JournalAudit, Membre, Nom, Paiement, Penalite, Tontine, Tour


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


def _verrouiller_brouillon(tontine: Tontine, message: str, code: str = "tontine_demarree") -> Tontine:
    tontine = Tontine.objects.select_for_update().get(pk=tontine.pk)
    if tontine.statut != Tontine.Statut.BROUILLON:
        raise ErreurMetier(code, message)
    return tontine


def _noms_actifs(tontine: Tontine):
    return Nom.objects.filter(tontine=tontine, membre__statut=Membre.Statut.ACTIF)


def _ajouter_nom(tontine: Tontine, membre: Membre) -> Nom:
    """Ajoute un nom en fin d'ordre de passage, dans la limite des places."""
    if _noms_actifs(tontine).count() >= tontine.nb_places:
        raise ErreurMetier("tontine_complete", "Toutes les places de la tontine sont prises.")
    position = (tontine.noms.aggregate(m=Max("position"))["m"] or 0) + 1
    return Nom.objects.create(tontine=tontine, membre=membre, position=position)


def _renumeroter(tontine: Tontine, ids_noms: list[int]) -> None:
    """Réécrit les positions 1..N dans l'ordre donné (deux passes : contrainte d'unicité)."""
    Nom.objects.filter(tontine=tontine).update(position=None)
    for position, pk in enumerate(ids_noms, start=1):
        Nom.objects.filter(pk=pk).update(position=position)


@transaction.atomic
def creer_tontine(createur, **donnees) -> Tontine:
    tontine = Tontine.objects.create(cree_par=createur, **donnees)
    president = Membre.objects.create(tontine=tontine, utilisateur=createur, role=Membre.Role.PRESIDENT)
    Nom.objects.create(tontine=tontine, membre=president, position=1)
    journaliser(tontine, createur, "creation")
    return tontine


@transaction.atomic
def modifier_tontine(tontine: Tontine, acteur, **donnees) -> Tontine:
    tontine = _verrouiller_brouillon(tontine, "Les paramètres sont figés après le démarrage.")
    places = donnees.get("nb_places", tontine.nb_places)
    if places < _noms_actifs(tontine).count():
        raise ErreurMetier("places_insuffisantes", "Il y a déjà plus de noms inscrits que de places demandées.")
    for champ, valeur in donnees.items():
        setattr(tontine, champ, valeur)
    tontine.save()
    journaliser(tontine, acteur, "modification", champs=sorted(donnees))
    return tontine


@transaction.atomic
def annuler_tontine(tontine: Tontine, acteur) -> Tontine:
    tontine = _verrouiller_brouillon(tontine, "Une tontine démarrée ne peut pas être annulée.")
    tontine.statut = Tontine.Statut.ANNULEE
    tontine.save(update_fields=["statut"])
    journaliser(tontine, acteur, "annulation")
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

    tontine = _verrouiller_brouillon(invitation.tontine, "La tontine a déjà démarré.")
    membre = tontine.membres.filter(utilisateur=utilisateur).first()
    if membre and membre.statut == Membre.Statut.ACTIF:
        raise ErreurMetier("deja_membre", "Vous êtes déjà membre de cette tontine.")
    if membre:  # retiré auparavant puis réinvité
        membre.statut, membre.role = Membre.Statut.ACTIF, Membre.Role.MEMBRE
        membre.save(update_fields=["statut", "role"])
    else:
        membre = Membre.objects.create(tontine=tontine, utilisateur=utilisateur)
    _ajouter_nom(tontine, membre)
    invitation.acceptee_le = timezone.now()
    invitation.save(update_fields=["acceptee_le"])
    journaliser(tontine, utilisateur, "adhesion", membre_id=membre.pk)
    return membre


def _membre_actif(tontine: Tontine, membre_id: int) -> Membre:
    membre = tontine.membres.filter(pk=membre_id, statut=Membre.Statut.ACTIF).first()
    if membre is None:
        raise ErreurMetier("membre_inconnu", "Ce membre n'appartient pas à la tontine.")
    return membre


@transaction.atomic
def ajouter_nom(tontine: Tontine, acteur, membre_id: int) -> Nom:
    """Donne un nom de plus à un membre : il cotisera et ramassera une fois de plus."""
    tontine = _verrouiller_brouillon(tontine, "Les noms sont figés une fois la tontine démarrée.")
    nom = _ajouter_nom(tontine, _membre_actif(tontine, membre_id))
    journaliser(tontine, acteur, "ajout_nom", membre_id=membre_id, position=nom.position)
    return nom


@transaction.atomic
def retirer_nom(tontine: Tontine, acteur, nom_id: int) -> None:
    tontine = _verrouiller_brouillon(tontine, "Les noms sont figés une fois la tontine démarrée.")
    nom = tontine.noms.filter(pk=nom_id).select_related("membre").first()
    if nom is None:
        raise ErreurMetier("nom_inconnu", "Ce nom n'appartient pas à la tontine.")
    if nom.membre.noms.count() <= 1:
        raise ErreurMetier("dernier_nom", "Un membre garde au moins un nom. Retirez plutôt le membre.")
    nom.delete()
    _renumeroter(tontine, list(_noms_actifs(tontine).values_list("pk", flat=True)))
    journaliser(tontine, acteur, "retrait_nom", membre_id=nom.membre_id)


@transaction.atomic
def retirer_membre(tontine: Tontine, acteur, membre_id: int) -> None:
    tontine = _verrouiller_brouillon(tontine, "Les membres sont figés une fois la tontine démarrée.")
    membre = _membre_actif(tontine, membre_id)
    if membre.role == Membre.Role.PRESIDENT:
        raise ErreurMetier("role_president", "Le président ne peut pas être retiré.")
    membre.noms.all().delete()
    membre.statut, membre.role = Membre.Statut.EXCLU, Membre.Role.MEMBRE
    membre.save(update_fields=["statut", "role"])
    _renumeroter(tontine, list(_noms_actifs(tontine).values_list("pk", flat=True)))
    journaliser(tontine, acteur, "retrait_membre", membre_id=membre.pk)


@transaction.atomic
def definir_ordre(tontine: Tontine, acteur, ids_noms: list[int]) -> None:
    tontine = _verrouiller_brouillon(tontine, "L'ordre est figé une fois la tontine démarrée.")
    if sorted(ids_noms) != sorted(_noms_actifs(tontine).values_list("pk", flat=True)):
        raise ErreurMetier("ordre_incomplet", "L'ordre doit contenir chaque nom une seule fois.")
    _renumeroter(tontine, ids_noms)
    journaliser(tontine, acteur, "ordre_defini", ordre=ids_noms)


@transaction.atomic
def demarrer_tontine(tontine: Tontine, acteur) -> Tontine:
    """Fige les membres et les noms, génère un tour par nom et les cotisations de chaque tour."""
    tontine = _verrouiller_brouillon(tontine, "Cette tontine a déjà démarré.", "deja_demarree")
    noms = list(_noms_actifs(tontine).select_related("membre"))
    membres = {nom.membre_id: nom.membre for nom in noms}
    if len(membres) < 2:
        raise ErreurMetier("membres_insuffisants", "Il faut au moins 2 membres pour démarrer.")
    if tontine.mode_attribution == Tontine.ModeAttribution.ENCHERE:
        raise ErreurMetier("mode_non_disponible", "Le mode enchère n'est pas encore disponible.")

    if tontine.mode_attribution == Tontine.ModeAttribution.TIRAGE_AU_SORT:
        secrets.SystemRandom().shuffle(noms)
        _renumeroter(tontine, [nom.pk for nom in noms])
    else:
        noms.sort(key=lambda nom: (nom.position is None, nom.position, nom.pk))

    noms_par_membre = Counter(nom.membre_id for nom in noms)
    if tontine.date_debut is None:
        tontine.date_debut = timezone.localdate()
    for numero, nom in enumerate(noms, start=1):
        tour = Tour.objects.create(
            tontine=tontine, numero=numero, date_echeance=echeance(tontine, numero), beneficiaire=nom
        )
        Cotisation.objects.bulk_create(
            Cotisation(tour=tour, membre_id=membre_id, montant_du=tontine.montant_cotisation * nombre)
            for membre_id, nombre in noms_par_membre.items()
        )

    tontine.statut = Tontine.Statut.ACTIVE
    tontine.save(update_fields=["statut", "date_debut"])
    journaliser(tontine, acteur, "demarrage", ordre=[nom.pk for nom in noms])
    return tontine


@transaction.atomic
def nouveau_cycle(tontine: Tontine, acteur) -> Tontine:
    """Recrée la tontine terminée en brouillon : mêmes paramètres, membres, rôles et noms."""
    if tontine.statut != Tontine.Statut.TERMINEE:
        raise ErreurMetier("cycle_en_cours", "Un nouveau cycle ne démarre qu'après la fin du précédent.")
    champs = ["nom", "description", "montant_cotisation", "frequence", "mode_attribution",
              "nb_places", "penalite_retard"]
    nouvelle = Tontine.objects.create(cree_par=acteur, **{c: getattr(tontine, c) for c in champs})
    copies = {}
    for membre in tontine.membres.filter(statut=Membre.Statut.ACTIF):
        copies[membre.pk] = Membre.objects.create(
            tontine=nouvelle, utilisateur_id=membre.utilisateur_id, role=membre.role
        )
    for nom in _noms_actifs(tontine).order_by("position"):
        Nom.objects.create(tontine=nouvelle, membre=copies[nom.membre_id], position=nom.position)
    journaliser(nouvelle, acteur, "nouveau_cycle", tontine_precedente=tontine.pk)
    return nouvelle


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
    if tour.montant_remis == 0:
        raise ErreurMetier("caisse_vide", "Aucune cotisation n'a été encaissée pour ce tour.")
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
            tontine = cotisation.tour.tontine
            if tontine.penalite_retard:
                # Une pénalité par nom en retard : un membre à 2 noms en paie 2.
                noms = max(cotisation.montant_du // tontine.montant_cotisation, 1)
                Penalite.objects.create(
                    cotisation=cotisation, montant=tontine.penalite_retard * noms,
                    motif=f"Retard au tour {cotisation.tour.numero}" + (f" ({noms} noms)" if noms > 1 else ""),
                )
            traitees += 1
    # Ouvre les tours dont l'échéance approche (3 jours).
    Tour.objects.filter(
        statut=Tour.Statut.A_VENIR,
        tontine__statut=Tontine.Statut.ACTIVE,
        date_echeance__lte=aujourd_hui + timedelta(days=3),
    ).update(statut=Tour.Statut.OUVERT)
    return traitees


@transaction.atomic
def encaisser_penalite(penalite: Penalite, acteur) -> Penalite:
    """Enregistre le paiement en espèces d'une pénalité (trésorier ou président)."""
    penalite = Penalite.objects.select_for_update().select_related("cotisation__tour__tontine").get(pk=penalite.pk)
    if penalite.payee:
        raise ErreurMetier("penalite_payee", "Cette pénalité est déjà payée.")
    penalite.payee = True
    penalite.save(update_fields=["payee"])
    journaliser(penalite.cotisation.tour.tontine, acteur, "penalite_payee",
                penalite_id=penalite.pk, montant=penalite.montant)
    return penalite
