"""Envoi de SMS.

SMS_BACKEND :
- "console" (défaut) : le message est écrit dans les logs du serveur, rien n'est envoyé.
- "africastalking" : API SMS d'Africa's Talking (https://developers.africastalking.com).
"""

import json
import logging
import urllib.error
import urllib.parse
import urllib.request

from django.conf import settings

logger = logging.getLogger(__name__)


class EnvoiImpossible(Exception):
    pass


def envoyer_sms(telephone: str, message: str) -> None:
    if settings.SMS_BACKEND == "console":
        logger.warning("SMS (non envoyé, mode console) à %s : %s", telephone, message)
        return
    if settings.SMS_BACKEND == "africastalking":
        _africastalking(telephone, message)
        return
    raise EnvoiImpossible(f"SMS_BACKEND inconnu : {settings.SMS_BACKEND}")


def _africastalking(telephone, message):
    sandbox = settings.AFRICASTALKING_USERNAME == "sandbox"
    url = f"https://api.{'sandbox.' if sandbox else ''}africastalking.com/version1/messaging"
    donnees = {"username": settings.AFRICASTALKING_USERNAME, "to": telephone, "message": message}
    if settings.AFRICASTALKING_EXPEDITEUR:
        donnees["from"] = settings.AFRICASTALKING_EXPEDITEUR
    requete = urllib.request.Request(
        url, data=urllib.parse.urlencode(donnees).encode(), method="POST",
        headers={"apiKey": settings.AFRICASTALKING_API_KEY, "Accept": "application/json",
                 "Content-Type": "application/x-www-form-urlencoded"},
    )
    try:
        with urllib.request.urlopen(requete, timeout=15) as reponse:
            corps = json.loads(reponse.read() or b"{}")
    except (urllib.error.URLError, TimeoutError) as exc:
        raise EnvoiImpossible(f"Africa's Talking injoignable : {exc}") from exc
    destinataires = corps.get("SMSMessageData", {}).get("Recipients", [])
    if not destinataires or destinataires[0].get("status") != "Success":
        raise EnvoiImpossible(f"SMS refusé : {corps}")
