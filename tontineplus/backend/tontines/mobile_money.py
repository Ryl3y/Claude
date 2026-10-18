"""Connecteurs Mobile Money.

Chaque fournisseur sait lancer une demande de paiement et lire son statut.
Le statut fait toujours foi côté fournisseur : un callback ne sert qu'à déclencher
cette relecture, son contenu n'est jamais cru tel quel.

MOBILE_MONEY_MODE :
- "simulation" (défaut en développement) : aucun appel réseau ; le paiement réussit,
  sauf si le numéro payeur se termine par 99 (pour tester l'échec).
- "reel" : MTN MoMo (API Collection). Orange Money n'est pas encore branché.
"""

import base64
import json
import time
import urllib.error
import urllib.request

from django.conf import settings

REUSSI, ECHOUE, EN_ATTENTE = "reussi", "echoue", "en_attente"


class FournisseurIndisponible(Exception):
    pass


class Simulation:
    def demander_paiement(self, paiement):
        pass

    def statut(self, paiement):
        return ECHOUE if paiement.telephone_payeur.endswith("99") else REUSSI


class MtnMomo:
    """API MTN MoMo Collection : https://momodeveloper.mtn.com (requesttopay)."""

    _jeton = None
    _expire_a = 0.0

    def __init__(self):
        self.base = settings.MTN_MOMO_BASE_URL.rstrip("/")
        self.cle_abonnement = settings.MTN_MOMO_SUBSCRIPTION_KEY
        self.environnement = settings.MTN_MOMO_ENVIRONNEMENT
        if not (self.cle_abonnement and settings.MTN_MOMO_API_USER and settings.MTN_MOMO_API_KEY):
            raise FournisseurIndisponible("MTN MoMo n'est pas configuré.")

    def _appel(self, methode, chemin, entetes, corps=None):
        requete = urllib.request.Request(
            self.base + chemin,
            method=methode,
            data=None if corps is None else json.dumps(corps).encode(),
            headers={"Ocp-Apim-Subscription-Key": self.cle_abonnement,
                     "Content-Type": "application/json", **entetes},
        )
        try:
            with urllib.request.urlopen(requete, timeout=15) as reponse:
                contenu = reponse.read()
                return reponse.status, json.loads(contenu) if contenu else None
        except (urllib.error.URLError, TimeoutError) as exc:
            raise FournisseurIndisponible(f"MTN MoMo injoignable : {exc}") from exc

    def _jeton_acces(self):
        if MtnMomo._jeton and time.monotonic() < MtnMomo._expire_a:
            return MtnMomo._jeton
        identifiants = f"{settings.MTN_MOMO_API_USER}:{settings.MTN_MOMO_API_KEY}"
        _, donnees = self._appel("POST", "/collection/token/", {
            "Authorization": "Basic " + base64.b64encode(identifiants.encode()).decode(),
        })
        MtnMomo._jeton = donnees["access_token"]
        MtnMomo._expire_a = time.monotonic() + int(donnees.get("expires_in", 3600)) - 60
        return MtnMomo._jeton

    def _entetes(self, reference):
        return {
            "Authorization": f"Bearer {self._jeton_acces()}",
            "X-Reference-Id": reference,
            "X-Target-Environment": self.environnement,
        }

    def demander_paiement(self, paiement):
        entetes = self._entetes(paiement.reference_externe)
        if settings.MTN_MOMO_CALLBACK_URL:
            entetes["X-Callback-Url"] = settings.MTN_MOMO_CALLBACK_URL
        statut, _ = self._appel("POST", "/collection/v1_0/requesttopay", entetes, {
            "amount": str(paiement.montant),
            "currency": settings.MTN_MOMO_DEVISE,
            "externalId": paiement.reference_externe,
            "payer": {"partyIdType": "MSISDN", "partyId": paiement.telephone_payeur.lstrip("+")},
            "payerMessage": "Cotisation TONTINE+",
            "payeeNote": f"Cotisation {paiement.cotisation_id}",
        })
        if statut != 202:
            raise FournisseurIndisponible(f"MTN MoMo a refusé la demande (HTTP {statut}).")

    def statut(self, paiement):
        _, donnees = self._appel(
            "GET", f"/collection/v1_0/requesttopay/{paiement.reference_externe}",
            self._entetes(paiement.reference_externe),
        )
        etat = (donnees or {}).get("status")
        if etat == "SUCCESSFUL":
            # Le montant encaissé doit être celui demandé.
            return REUSSI if str(donnees.get("amount")).split(".")[0] == str(paiement.montant) else ECHOUE
        if etat in {"FAILED", "REJECTED", "TIMEOUT"}:
            return ECHOUE
        return EN_ATTENTE


def fournisseur(moyen):
    if settings.MOBILE_MONEY_MODE == "simulation":
        return Simulation()
    if moyen == "mtn_momo":
        return MtnMomo()
    raise FournisseurIndisponible("Ce moyen de paiement n'est pas encore disponible.")
