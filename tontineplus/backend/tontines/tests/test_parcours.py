"""Tests du parcours complet sur un vrai PostgreSQL : inscription → tontine → tours → paiements → remise."""

import hashlib
import hmac
import json
from datetime import date

from django.db import IntegrityError, transaction
from django.test import TestCase, override_settings
from rest_framework.test import APIClient

from comptes.models import Utilisateur
from tontines.models import Cotisation, Membre, Paiement, Penalite, Tontine, Tour
from tontines.services import ajouter_mois, marquer_retards

SECRET = "secret-de-test"


def client_pour(utilisateur):
    client = APIClient()
    client.force_authenticate(utilisateur)
    return client


class ParcoursTontine(TestCase):
    def setUp(self):
        self.awa = Utilisateur.objects.create_user("+237690000001", "Awa", "motdepasse-solide-1")
        self.bello = Utilisateur.objects.create_user("+237690000002", "Bello", "motdepasse-solide-2")
        self.chantal = Utilisateur.objects.create_user("+237690000003", "Chantal", "motdepasse-solide-3")
        self.api_awa = client_pour(self.awa)

    def creer_tontine(self, **extra):
        donnees = {"nom": "Famille", "montant_cotisation": 10000, "frequence": "mensuelle",
                   "nb_places": 3, "penalite_retard": 500, "date_debut": "2026-11-01", **extra}
        reponse = self.api_awa.post("/api/v1/tontines/", donnees, format="json")
        self.assertEqual(reponse.status_code, 201, reponse.data)
        return Tontine.objects.get(pk=reponse.data["id"])

    def inviter_et_accepter(self, tontine, utilisateur):
        reponse = self.api_awa.post(
            f"/api/v1/tontines/{tontine.pk}/invitations/", {"telephone": utilisateur.telephone}, format="json"
        )
        self.assertEqual(reponse.status_code, 201, reponse.data)
        reponse = client_pour(utilisateur).post(f"/api/v1/invitations/{reponse.data['code']}/accepter/")
        self.assertEqual(reponse.status_code, 201, reponse.data)

    def tontine_demarree(self):
        tontine = self.creer_tontine()
        self.inviter_et_accepter(tontine, self.bello)
        self.inviter_et_accepter(tontine, self.chantal)
        reponse = self.api_awa.post(f"/api/v1/tontines/{tontine.pk}/demarrer/")
        self.assertEqual(reponse.status_code, 200, reponse.data)
        tontine.refresh_from_db()
        return tontine

    # --- authentification ---------------------------------------------------------------

    def test_inscription_connexion_deconnexion(self):
        api = APIClient()
        reponse = api.post("/api/v1/auth/inscription/", {
            "telephone": "+237690000099", "nom_complet": "Dora", "password": "un-mot-de-passe-long"
        }, format="json")
        self.assertEqual(reponse.status_code, 201, reponse.data)
        reponse = api.post("/api/v1/auth/connexion/", {
            "telephone": "+237690000099", "password": "un-mot-de-passe-long"
        }, format="json")
        self.assertEqual(reponse.status_code, 200)
        refresh = reponse.data["refresh"]
        api.credentials(HTTP_AUTHORIZATION=f"Bearer {reponse.data['access']}")
        self.assertEqual(api.get("/api/v1/moi/").data["utilisateur"]["nom_complet"], "Dora")
        self.assertEqual(api.post("/api/v1/auth/deconnexion/", {"refresh": refresh}).status_code, 204)
        # Le jeton révoqué ne permet plus de prolonger la session.
        self.assertEqual(api.post("/api/v1/auth/refresh/", {"refresh": refresh}).status_code, 401)

    def test_telephone_mal_forme_refuse(self):
        reponse = APIClient().post("/api/v1/auth/inscription/", {
            "telephone": "690000099", "nom_complet": "X", "password": "un-mot-de-passe-long"
        }, format="json")
        self.assertEqual(reponse.status_code, 400)
        self.assertEqual(reponse.data["code"], "donnees_invalides")

    def test_api_refuse_sans_jeton(self):
        self.assertEqual(APIClient().get("/api/v1/tontines/").status_code, 401)

    # --- tontines et membres -------------------------------------------------------------

    def test_createur_devient_president(self):
        tontine = self.creer_tontine()
        membre = tontine.membres.get()
        self.assertEqual((membre.utilisateur, membre.role), (self.awa, "president"))
        self.assertEqual(list(membre.noms.values_list("position", flat=True)), [1])

    def test_non_membre_ne_voit_pas_la_tontine(self):
        tontine = self.creer_tontine()
        self.assertEqual(client_pour(self.bello).get(f"/api/v1/tontines/{tontine.pk}/").status_code, 404)

    def test_tontine_complete_refuse_un_membre_de_plus(self):
        tontine = self.creer_tontine(nb_places=2)
        self.inviter_et_accepter(tontine, self.bello)
        code = self.api_awa.post(
            f"/api/v1/tontines/{tontine.pk}/invitations/", {"telephone": self.chantal.telephone}, format="json"
        ).data["code"]
        reponse = client_pour(self.chantal).post(f"/api/v1/invitations/{code}/accepter/")
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "tontine_complete"))

    def test_seul_le_president_demarre(self):
        tontine = self.creer_tontine()
        self.inviter_et_accepter(tontine, self.bello)
        reponse = client_pour(self.bello).post(f"/api/v1/tontines/{tontine.pk}/demarrer/")
        self.assertEqual(reponse.status_code, 403)

    def test_ordre_de_passage(self):
        tontine = self.creer_tontine()
        self.inviter_et_accepter(tontine, self.bello)
        self.inviter_et_accepter(tontine, self.chantal)
        ids = list(tontine.noms.order_by("-position").values_list("pk", flat=True))
        reponse = self.api_awa.put(f"/api/v1/tontines/{tontine.pk}/ordre/", {"noms": ids}, format="json")
        self.assertEqual(reponse.status_code, 200, reponse.data)
        self.assertEqual([n["id"] for n in reponse.data["ordre"]], ids)
        self.assertEqual([n["nom_complet"] for n in reponse.data["ordre"]], ["Chantal", "Bello", "Awa"])

    # --- démarrage -----------------------------------------------------------------------

    def test_demarrage_genere_tours_et_cotisations(self):
        tontine = self.tontine_demarree()
        self.assertEqual(tontine.statut, "active")
        tours = list(tontine.tours.order_by("numero"))
        self.assertEqual([t.date_echeance for t in tours],
                         [date(2026, 11, 1), date(2026, 12, 1), date(2027, 1, 1)])
        self.assertEqual(Cotisation.objects.filter(tour__tontine=tontine).count(), 9)
        self.assertEqual(len({t.beneficiaire_id for t in tours}), 3)
        reponse = self.api_awa.post(f"/api/v1/tontines/{tontine.pk}/demarrer/")
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "deja_demarree"))

    def test_parametres_figes_apres_demarrage(self):
        tontine = self.tontine_demarree()
        reponse = self.api_awa.patch(f"/api/v1/tontines/{tontine.pk}/", {"montant_cotisation": 1}, format="json")
        self.assertEqual(reponse.status_code, 409)

    # --- paiements et remise -------------------------------------------------------------

    def test_paiement_especes_puis_remise(self):
        tontine = self.tontine_demarree()
        tour = tontine.tours.get(numero=1)
        cotisations = list(tour.cotisations.all())
        reponse = self.api_awa.post(f"/api/v1/tours/{tour.pk}/remise/")
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "cotisations_impayees"))

        for cotisation in cotisations:
            reponse = self.api_awa.post(f"/api/v1/cotisations/{cotisation.pk}/paiements/",
                                        {"montant": 10000, "moyen": "especes"}, format="json")
            self.assertEqual(reponse.status_code, 201, reponse.data)
        self.assertFalse(tour.cotisations.exclude(statut="payee").exists())

        reponse = self.api_awa.post(f"/api/v1/tours/{tour.pk}/remise/")
        self.assertEqual(reponse.status_code, 200, reponse.data)
        self.assertEqual((reponse.data["statut"], reponse.data["montant_remis"]), ("clos", 30000))

    def test_paiement_partiel_et_trop_eleve(self):
        tontine = self.tontine_demarree()
        cotisation = Cotisation.objects.filter(tour__tontine=tontine).first()
        url = f"/api/v1/cotisations/{cotisation.pk}/paiements/"
        self.api_awa.post(url, {"montant": 4000, "moyen": "especes"}, format="json")
        cotisation.refresh_from_db()
        self.assertEqual((cotisation.statut, cotisation.montant_paye), ("partielle", 4000))
        reponse = self.api_awa.post(url, {"montant": 7000, "moyen": "especes"}, format="json")
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "montant_trop_eleve"))

    def test_simple_membre_ne_saisit_pas_d_especes(self):
        tontine = self.tontine_demarree()
        cotisation = Cotisation.objects.filter(tour__tontine=tontine, membre__utilisateur=self.bello).first()
        reponse = client_pour(self.bello).post(f"/api/v1/cotisations/{cotisation.pk}/paiements/",
                                               {"montant": 10000, "moyen": "especes"}, format="json")
        self.assertEqual(reponse.status_code, 403)

    @override_settings(MOBILE_MONEY_WEBHOOK_SECRET=SECRET)
    def test_webhook_mobile_money_idempotent(self):
        tontine = self.tontine_demarree()
        cotisation = Cotisation.objects.filter(tour__tontine=tontine, membre__utilisateur=self.bello).first()
        reponse = client_pour(self.bello).post(f"/api/v1/cotisations/{cotisation.pk}/paiements/",
                                               {"moyen": "mtn_momo"}, format="json")
        self.assertEqual((reponse.status_code, reponse.data["statut"]), (201, "initie"))
        reference = Paiement.objects.get(pk=reponse.data["id"]).reference_externe

        corps = json.dumps({"reference_externe": reference, "reussi": True}).encode()
        signature = hmac.new(SECRET.encode(), corps, hashlib.sha256).hexdigest()
        envoyer = lambda sig: APIClient().post("/api/v1/webhooks/mobile-money/mtn/", corps,
                                               content_type="application/json", HTTP_X_SIGNATURE=sig)
        self.assertEqual(envoyer("fausse-signature").status_code, 403)
        premier, second = envoyer(signature), envoyer(signature)
        self.assertEqual((premier.status_code, premier.data["deja_traite"]), (200, False))
        self.assertEqual((second.status_code, second.data["deja_traite"]), (200, True))
        cotisation.refresh_from_db()
        self.assertEqual((cotisation.montant_paye, cotisation.statut), (10000, "payee"))

    # --- tâches quotidiennes et contraintes ---------------------------------------------

    def test_retards_et_penalites(self):
        tontine = self.tontine_demarree()
        traitees = marquer_retards(aujourd_hui=date(2026, 11, 2))
        self.assertEqual(traitees, 3)
        self.assertEqual(Penalite.objects.filter(cotisation__tour__tontine=tontine).count(), 3)
        self.assertEqual(marquer_retards(aujourd_hui=date(2026, 11, 2)), 0)
        self.assertEqual(tontine.tours.get(numero=2).statut, Tour.Statut.A_VENIR)

    def test_contraintes_postgresql(self):
        tontine = self.tontine_demarree()
        cotisation = Cotisation.objects.filter(tour__tontine=tontine).first()
        Paiement.objects.create(cotisation=cotisation, montant=1, moyen="mtn_momo", reference_externe="R1")
        cas = [
            lambda: Paiement.objects.create(cotisation=cotisation, montant=1, moyen="mtn_momo", reference_externe="R1"),
            lambda: Membre.objects.create(tontine=tontine, utilisateur=self.awa),
            lambda: Tour.objects.filter(tontine=tontine, numero=2).update(
                beneficiaire=tontine.tours.get(numero=1).beneficiaire),
            lambda: Utilisateur.objects.create_user("690000001", "Mauvais", "x"),
        ]
        for creer in cas:
            with self.subTest(), self.assertRaises(IntegrityError), transaction.atomic():
                creer()

    def test_fin_de_mois(self):
        self.assertEqual(ajouter_mois(date(2027, 1, 31), 1), date(2027, 2, 28))
        self.assertEqual(ajouter_mois(date(2026, 11, 30), 3), date(2027, 2, 28))
