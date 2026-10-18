"""Trésorier, paiement Mobile Money (simulation et client MTN) et connexion par code SMS."""

import json
from unittest import mock

from django.core.cache import cache
from django.test import TestCase, override_settings
from rest_framework.test import APIClient

from comptes.models import CodeSMS, Utilisateur
from tontines import mobile_money
from tontines.models import Cotisation, Paiement, Tontine
from tontines.services import accepter_invitation, creer_invitation, creer_tontine, demarrer_tontine


def client_pour(utilisateur):
    client = APIClient()
    client.force_authenticate(utilisateur)
    return client


class AvecTontine(TestCase):
    def setUp(self):
        self.awa = Utilisateur.objects.create_user("+237690000001", "Awa", "motdepasse-solide-1")
        self.bello = Utilisateur.objects.create_user("+237690000002", "Bello", "motdepasse-solide-2")
        self.tontine = creer_tontine(self.awa, nom="Famille", montant_cotisation=10000,
                                     frequence="mensuelle", nb_places=3)
        invitation = creer_invitation(self.tontine, self.awa, self.bello.telephone)
        self.membre_bello = accepter_invitation(invitation.code, self.bello)

    def demarrer(self):
        demarrer_tontine(self.tontine, self.awa)
        return Cotisation.objects.get(tour__numero=1, membre=self.membre_bello)


class Tresorier(AvecTontine):
    def url(self, membre):
        return f"/api/v1/tontines/{self.tontine.pk}/membres/{membre.pk}/role/"

    def test_le_president_nomme_puis_retire_le_tresorier(self):
        api = client_pour(self.awa)
        reponse = api.put(self.url(self.membre_bello), {"role": "tresorier"}, format="json")
        self.assertEqual(reponse.status_code, 200, reponse.data)
        self.membre_bello.refresh_from_db()
        self.assertEqual(self.membre_bello.role, "tresorier")
        api.put(self.url(self.membre_bello), {"role": "membre"}, format="json")
        self.membre_bello.refresh_from_db()
        self.assertEqual(self.membre_bello.role, "membre")

    def test_un_seul_tresorier(self):
        chantal = Utilisateur.objects.create_user("+237690000003", "Chantal", "motdepasse-solide-3")
        membre_chantal = accepter_invitation(creer_invitation(self.tontine, self.awa, chantal.telephone).code, chantal)
        api = client_pour(self.awa)
        api.put(self.url(self.membre_bello), {"role": "tresorier"}, format="json")
        api.put(self.url(membre_chantal), {"role": "tresorier"}, format="json")
        roles = dict(self.tontine.membres.values_list("utilisateur__nom_complet", "role"))
        self.assertEqual(roles, {"Awa": "president", "Bello": "membre", "Chantal": "tresorier"})

    def test_le_tresorier_encaisse_les_especes(self):
        client_pour(self.awa).put(self.url(self.membre_bello), {"role": "tresorier"}, format="json")
        cotisation = self.demarrer()
        reponse = client_pour(self.bello).post(f"/api/v1/cotisations/{cotisation.pk}/paiements/",
                                               {"moyen": "especes", "montant": 10000}, format="json")
        self.assertEqual(reponse.status_code, 201, reponse.data)

    def test_refus(self):
        president = self.tontine.membres.get(role="president")
        self.assertEqual(client_pour(self.bello).put(self.url(self.membre_bello), {"role": "tresorier"},
                                                     format="json").status_code, 403)
        reponse = client_pour(self.awa).put(self.url(president), {"role": "membre"}, format="json")
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "role_president"))
        reponse = client_pour(self.awa).put(self.url(self.membre_bello), {"role": "president"}, format="json")
        self.assertEqual(reponse.status_code, 400)


@override_settings(MOBILE_MONEY_MODE="simulation")
class PaiementMobileSimule(AvecTontine):
    def payer(self, cotisation, **corps):
        return client_pour(self.bello).post(f"/api/v1/cotisations/{cotisation.pk}/paiements/",
                                            {"moyen": "mtn_momo", **corps}, format="json")

    def test_paiement_reussi_apres_suivi(self):
        cotisation = self.demarrer()
        reponse = self.payer(cotisation)
        self.assertEqual((reponse.status_code, reponse.data["statut"], reponse.data["montant"]), (201, "initie", 10000))
        self.assertEqual(reponse.data["telephone_payeur"], self.bello.telephone)
        cotisation.refresh_from_db()
        self.assertEqual(cotisation.montant_paye, 0)  # rien n'est crédité avant confirmation

        suivi = client_pour(self.bello).get(f"/api/v1/paiements/{reponse.data['id']}/")
        self.assertEqual(suivi.data["statut"], "reussi")
        cotisation.refresh_from_db()
        self.assertEqual((cotisation.statut, cotisation.montant_paye), ("payee", 10000))

    def test_paiement_refuse_par_le_payeur(self):
        cotisation = self.demarrer()
        reponse = self.payer(cotisation, telephone="+237690000099")
        suivi = client_pour(self.bello).get(f"/api/v1/paiements/{reponse.data['id']}/")
        self.assertEqual(suivi.data["statut"], "echoue")
        cotisation.refresh_from_db()
        self.assertEqual(cotisation.statut, "due")

    def test_pas_deux_paiements_en_attente(self):
        cotisation = self.demarrer()
        self.payer(cotisation)
        reponse = self.payer(cotisation)
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "paiement_en_cours"))

    def test_seul_le_payeur_ou_le_bureau_suit_le_paiement(self):
        chantal = Utilisateur.objects.create_user("+237690000003", "Chantal", "motdepasse-solide-3")
        accepter_invitation(creer_invitation(self.tontine, self.awa, chantal.telephone).code, chantal)
        paiement_id = self.payer(self.demarrer()).data["id"]
        self.assertEqual(client_pour(chantal).get(f"/api/v1/paiements/{paiement_id}/").status_code, 403)
        self.assertEqual(client_pour(self.awa).get(f"/api/v1/paiements/{paiement_id}/").status_code, 200)


class ReponseFactice:
    def __init__(self, status, corps):
        self.status, self._corps = status, corps

    def read(self):
        return json.dumps(self._corps).encode() if self._corps is not None else b""

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False


@override_settings(MOBILE_MONEY_MODE="reel", MTN_MOMO_SUBSCRIPTION_KEY="cle", MTN_MOMO_API_USER="utilisateur",
                   MTN_MOMO_API_KEY="secret", MTN_MOMO_ENVIRONNEMENT="mtncameroon", MTN_MOMO_DEVISE="XAF",
                   MTN_MOMO_CALLBACK_URL="https://exemple.cm/api/v1/webhooks/mtn-momo/")
class ClientMtn(AvecTontine):
    """Vérifie les requêtes envoyées à l'API MTN MoMo (réseau simulé)."""

    def setUp(self):
        super().setUp()
        mobile_money.MtnMomo._jeton = None
        self.requetes = []
        self.statut_mtn = "PENDING"

        def urlopen(requete, timeout):
            self.requetes.append(requete)
            if requete.full_url.endswith("/collection/token/"):
                return ReponseFactice(200, {"access_token": "jeton-mtn", "expires_in": 3600})
            if requete.get_method() == "POST":
                return ReponseFactice(202, None)
            return ReponseFactice(200, {"status": self.statut_mtn, "amount": "10000"})

        patch = mock.patch("tontines.mobile_money.urllib.request.urlopen", urlopen)
        patch.start()
        self.addCleanup(patch.stop)

    def test_demande_puis_confirmation_par_callback(self):
        cotisation = self.demarrer()
        reponse = client_pour(self.bello).post(f"/api/v1/cotisations/{cotisation.pk}/paiements/",
                                               {"moyen": "mtn_momo"}, format="json")
        self.assertEqual(reponse.status_code, 201, reponse.data)
        paiement = Paiement.objects.get(pk=reponse.data["id"])

        demande = self.requetes[1]
        entetes = {k.lower(): v for k, v in demande.header_items()}
        self.assertEqual(demande.full_url, "https://sandbox.momodeveloper.mtn.com/collection/v1_0/requesttopay")
        self.assertEqual(entetes["x-reference-id"], paiement.reference_externe)
        self.assertEqual(entetes["x-target-environment"], "mtncameroon")
        self.assertEqual(entetes["authorization"], "Bearer jeton-mtn")
        self.assertEqual(entetes["x-callback-url"], "https://exemple.cm/api/v1/webhooks/mtn-momo/")
        corps = json.loads(demande.data)
        self.assertEqual(corps["payer"], {"partyIdType": "MSISDN", "partyId": "237690000002"})
        self.assertEqual((corps["amount"], corps["currency"]), ("10000", "XAF"))

        # Callback encore en attente chez MTN : rien ne change.
        APIClient().post("/api/v1/webhooks/mtn-momo/", {"externalId": paiement.reference_externe}, format="json")
        paiement.refresh_from_db()
        self.assertEqual(paiement.statut, "initie")

        # Un callback qui prétend « SUCCESSFUL » ne suffit pas : c'est la relecture chez MTN qui compte.
        self.statut_mtn = "SUCCESSFUL"
        reponse = APIClient().put("/api/v1/webhooks/mtn-momo/",
                                  {"externalId": paiement.reference_externe, "status": "SUCCESSFUL"}, format="json")
        self.assertEqual(reponse.status_code, 204)
        cotisation.refresh_from_db()
        self.assertEqual((cotisation.statut, cotisation.montant_paye), ("payee", 10000))
        self.assertTrue(self.requetes[-1].full_url.endswith(f"/requesttopay/{paiement.reference_externe}"))

    def test_mtn_injoignable(self):
        cotisation = self.demarrer()
        with mock.patch("tontines.mobile_money.urllib.request.urlopen",
                        side_effect=mobile_money.urllib.error.URLError("hors ligne")):
            reponse = client_pour(self.bello).post(f"/api/v1/cotisations/{cotisation.pk}/paiements/",
                                                   {"moyen": "mtn_momo"}, format="json")
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "fournisseur_indisponible"))
        self.assertEqual(Paiement.objects.get().statut, "echoue")

    def test_orange_pas_encore_disponible(self):
        cotisation = self.demarrer()
        reponse = client_pour(self.bello).post(f"/api/v1/cotisations/{cotisation.pk}/paiements/",
                                               {"moyen": "orange_money"}, format="json")
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "fournisseur_indisponible"))


@override_settings(SMS_BACKEND="console")
class ConnexionParSMS(TestCase):
    TEL = "+237690000010"

    def setUp(self):
        cache.clear()  # remet à zéro la limite par adresse IP
        patch = mock.patch("comptes.otp.envoyer_sms")
        self.envoyer_sms = patch.start()
        self.addCleanup(patch.stop)
        self.api = APIClient()

    def demander(self, telephone=TEL):
        return self.api.post("/api/v1/auth/code/demande/", {"telephone": telephone}, format="json")

    def code_envoye(self):
        message = self.envoyer_sms.call_args.args[1]
        return message.split(": ")[1][:6]

    def verifier(self, code, **extra):
        return self.api.post("/api/v1/auth/code/verification/",
                             {"telephone": self.TEL, "code": code, **extra}, format="json")

    def test_nouveau_compte(self):
        self.assertEqual(self.demander().status_code, 204)
        code = self.code_envoye()
        self.assertEqual(CodeSMS.objects.get().empreinte.find(code), -1)  # jamais stocké en clair
        reponse = self.verifier(code)
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "nom_requis"))
        reponse = self.verifier(code, nom_complet="Dora")  # le même code reste valable
        self.assertEqual(reponse.status_code, 200, reponse.data)
        self.assertEqual(reponse.data["utilisateur"]["nom_complet"], "Dora")
        self.assertIn("access", reponse.data)
        self.assertFalse(Utilisateur.objects.get(telephone=self.TEL).has_usable_password())
        self.assertEqual(self.verifier(code).data["code"], "code_expire")  # usage unique

    def test_compte_existant(self):
        Utilisateur.objects.create_user(self.TEL, "Eric", "motdepasse-solide")
        self.demander()
        reponse = self.verifier(self.code_envoye())
        self.assertEqual((reponse.status_code, reponse.data["utilisateur"]["nom_complet"]), (200, "Eric"))

    def test_essais_limites(self):
        self.demander()
        bon = self.code_envoye()
        faux = "000000" if bon != "000000" else "111111"
        for reste in (4, 3, 2, 1, 0):
            reponse = self.verifier(faux)
            self.assertEqual(reponse.data["message"], f"Code incorrect. {reste} essai(s) restant(s).")
        self.assertEqual(self.verifier(bon, nom_complet="X").data["code"], "code_expire")

    def test_delai_entre_deux_envois(self):
        self.demander()
        reponse = self.demander()
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "code_trop_tot"))
        self.assertEqual(self.envoyer_sms.call_count, 1)

    def test_format_du_code(self):
        self.demander()
        self.assertEqual(self.verifier("12ab").status_code, 400)
