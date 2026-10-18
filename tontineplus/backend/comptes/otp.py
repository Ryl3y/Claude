"""Connexion par code SMS : demande d'un code, puis vérification (crée le compte si besoin)."""

import hashlib
import hmac
import secrets
from datetime import timedelta

from django.conf import settings
from django.db import transaction
from django.utils import timezone

from tontines.services import ErreurMetier

from .models import CodeSMS, Utilisateur
from .sms import EnvoiImpossible, envoyer_sms

DUREE_VALIDITE = timedelta(minutes=5)
DELAI_ENTRE_ENVOIS = timedelta(seconds=60)
ENVOIS_PAR_HEURE = 5
ESSAIS_MAX = 5


def _empreinte(telephone, code):
    return hmac.new(settings.SECRET_KEY.encode(), f"{telephone}:{code}".encode(), hashlib.sha256).hexdigest()


def demander_code(telephone: str) -> None:
    maintenant = timezone.now()
    recents = CodeSMS.objects.filter(telephone=telephone, cree_le__gte=maintenant - timedelta(hours=1))
    if recents.filter(cree_le__gte=maintenant - DELAI_ENTRE_ENVOIS).exists():
        raise ErreurMetier("code_trop_tot", "Un code vient d'être envoyé. Patientez une minute.")
    if recents.count() >= ENVOIS_PAR_HEURE:
        raise ErreurMetier("trop_de_codes", "Trop de codes demandés. Réessayez dans une heure.")
    code = f"{secrets.randbelow(10**6):06d}"
    CodeSMS.objects.create(
        telephone=telephone, empreinte=_empreinte(telephone, code), expire_le=maintenant + DUREE_VALIDITE
    )
    try:
        envoyer_sms(telephone, f"Votre code TONTINE+ : {code}. Valable 5 minutes. Ne le partagez avec personne.")
    except EnvoiImpossible as exc:
        raise ErreurMetier("sms_indisponible", "L'envoi du SMS a échoué. Réessayez plus tard.") from exc


def verifier_code(telephone: str, code: str, nom_complet: str = "") -> Utilisateur:
    """Renvoie l'utilisateur connecté. Un numéro inconnu crée le compte, à condition d'avoir le nom."""
    with transaction.atomic():
        envoi = (
            CodeSMS.objects.select_for_update()
            .filter(telephone=telephone, utilise_le__isnull=True, expire_le__gt=timezone.now())
            .order_by("-cree_le")
            .first()
        )
        if envoi is None or envoi.essais >= ESSAIS_MAX:
            raise ErreurMetier("code_expire", "Code expiré ou trop d'essais. Demandez un nouveau code.")
        if not hmac.compare_digest(envoi.empreinte, _empreinte(telephone, code)):
            envoi.essais += 1
            envoi.save(update_fields=["essais"])
            reste = ESSAIS_MAX - envoi.essais
            # Le compteur d'essais doit être enregistré malgré l'erreur : on sort sans exception de la transaction.
            erreur = ErreurMetier("code_incorrect", f"Code incorrect. {reste} essai(s) restant(s).")
        else:
            erreur = None
            utilisateur = Utilisateur.objects.filter(telephone=telephone).first()
            if utilisateur is None and not nom_complet.strip():
                # Le code reste valable : le front redemande le même code avec le nom.
                raise ErreurMetier("nom_requis", "Bienvenue ! Indiquez votre nom pour créer votre compte.")
            envoi.utilise_le = timezone.now()
            envoi.save(update_fields=["utilise_le"])
            if utilisateur is None:
                utilisateur = Utilisateur.objects.create_user(telephone, nom_complet.strip())
            elif not utilisateur.is_active:
                raise ErreurMetier("compte_desactive", "Ce compte est désactivé.")
    if erreur:
        raise erreur
    return utilisateur
