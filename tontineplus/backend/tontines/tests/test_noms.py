"""Plusieurs noms par membre, retrait, annulation, modification, pénalités et nouveau cycle."""

from datetime import date

from django.test import TestCase
from rest_framework.test import APIClient

from comptes.models import Utilisateur
from tontines.models import Cotisation, Membre, Penalite, Tontine
from tontines.services import (
    accepter_invitation, creer_invitation, creer_tontine, demarrer_tontine, enregistrer_paiement,
    marquer_retards, remettre_caisse, tirer_au_sort,
)


def client_pour(utilisateur):
    client = APIClient()
    client.force_authenticate(utilisateur)
    return client


class Base(TestCase):
    def setUp(self):
        self.awa = Utilisateur.objects.create_user("+237690000001", "Awa", "motdepasse-solide-1")
        self.bello = Utilisateur.objects.create_user("+237690000002", "Bello", "motdepasse-solide-2")
        self.tontine = creer_tontine(self.awa, nom="Famille", montant_cotisation=10000, frequence="mensuelle",
                                     nb_places=3, penalite_retard=500, date_debut=date(2026, 11, 1))
        self.membre_bello = accepter_invitation(creer_invitation(self.tontine, self.awa, "+237690000002").code,
                                                self.bello)
        self.api = client_pour(self.awa)
        self.url = f"/api/v1/tontines/{self.tontine.pk}"

    def ajouter_nom(self, membre, client=None):
        return (client or self.api).post(f"{self.url}/membres/{membre.pk}/noms/")


class PlusieursNoms(Base):
    def test_un_membre_a_deux_noms_cotise_double_et_ramasse_deux_fois(self):
        reponse = self.ajouter_nom(self.membre_bello)
        self.assertEqual(reponse.status_code, 200, reponse.data)
        bello = next(m for m in reponse.data["membres"] if m["nom_complet"] == "Bello")
        self.assertEqual(bello["positions"], [2, 3])
        self.assertEqual([(n["nom_complet"], n["rang"]) for n in reponse.data["noms"]],
                         [("Awa", 1), ("Bello", 1), ("Bello", 2)])

        self.api.post(f"{self.url}/demarrer/")
        for tour in self.api.get(f"{self.url}/tours/").data:
            self.assertEqual(self.api.post(f"/api/v1/tours/{tour['id']}/tirage/").status_code, 200)
        tours = self.api.get(f"{self.url}/tours/").data
        self.assertEqual(sorted(t["beneficiaire"] for t in tours), ["Awa", "Bello", "Bello"])
        noms = {n["id"] for n in self.api.get(f"{self.url}/").data["noms"]}
        self.assertEqual({t["beneficiaire_nom_id"] for t in tours}, noms)  # chaque nom servi une fois
        self.assertEqual({t["montant_attendu"] for t in tours}, {30000})  # 3 noms × 10 000

        cotisations = self.api.get(f"/api/v1/tours/{tours[0]['id']}/cotisations/").data
        self.assertEqual({c["membre"]: (c["nb_noms"], c["montant_du"]) for c in cotisations},
                         {"Awa": (1, 10000), "Bello": (2, 20000)})

        for c in cotisations:
            self.api.post(f"/api/v1/cotisations/{c['id']}/paiements/",
                          {"moyen": "especes", "montant": c["montant_du"]}, format="json")
        reponse = self.api.post(f"/api/v1/tours/{tours[0]['id']}/remise/")
        self.assertEqual(reponse.data["montant_remis"], 30000)

    def test_places_limitees(self):
        self.ajouter_nom(self.membre_bello)  # 3 noms sur 3 places
        reponse = self.ajouter_nom(self.membre_bello)
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "tontine_complete"))
        chantal = Utilisateur.objects.create_user("+237690000003", "Chantal", "motdepasse-solide-3")
        code = creer_invitation(self.tontine, self.awa, chantal.telephone).code
        reponse = client_pour(chantal).post(f"/api/v1/invitations/{code}/accepter/")
        self.assertEqual(reponse.data["code"], "tontine_complete")

    def test_retirer_un_nom_renumerote(self):
        self.ajouter_nom(self.membre_bello)
        premier_nom_bello = self.membre_bello.noms.order_by("position").first()
        reponse = self.api.delete(f"{self.url}/noms/{premier_nom_bello.pk}/")
        self.assertEqual(reponse.status_code, 200, reponse.data)
        self.assertEqual([n["position"] for n in reponse.data["noms"]], [1, 2])
        dernier = self.membre_bello.noms.get()
        reponse = self.api.delete(f"{self.url}/noms/{dernier.pk}/")
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "dernier_nom"))

    def test_un_membre_seul_avec_plusieurs_noms_ne_suffit_pas(self):
        self.api.delete(f"{self.url}/membres/{self.membre_bello.pk}/")
        self.ajouter_nom(self.tontine.membres.get(role="president"))
        reponse = self.api.post(f"{self.url}/demarrer/")
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "membres_insuffisants"))

    def test_penalite_par_nom(self):
        self.ajouter_nom(self.membre_bello)
        demarrer_tontine(self.tontine, self.awa)
        marquer_retards(aujourd_hui=date(2026, 11, 2))
        penalites = {p.cotisation.membre.utilisateur.nom_complet: p.montant for p in Penalite.objects.all()}
        self.assertEqual(penalites, {"Awa": 500, "Bello": 1000})

    def test_seul_le_president_gere_les_noms(self):
        reponse = self.ajouter_nom(self.membre_bello, client=client_pour(self.bello))
        self.assertEqual(reponse.status_code, 403)

    def test_noms_figes_apres_demarrage(self):
        demarrer_tontine(self.tontine, self.awa)
        reponse = self.ajouter_nom(self.membre_bello)
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "tontine_demarree"))


class GestionDesMembres(Base):
    def test_retirer_puis_reinviter(self):
        reponse = self.api.delete(f"{self.url}/membres/{self.membre_bello.pk}/")
        self.assertEqual(reponse.status_code, 200, reponse.data)
        self.assertEqual([m["nom_complet"] for m in reponse.data["membres"]], ["Awa"])
        self.assertEqual(client_pour(self.bello).get(f"{self.url}/").status_code, 404)

        code = creer_invitation(self.tontine, self.awa, self.bello.telephone).code
        reponse = client_pour(self.bello).post(f"/api/v1/invitations/{code}/accepter/")
        self.assertEqual(reponse.status_code, 201, reponse.data)
        self.assertEqual(Membre.objects.get(pk=self.membre_bello.pk).statut, "actif")

    def test_le_president_ne_peut_pas_etre_retire(self):
        president = self.tontine.membres.get(role="president")
        reponse = self.api.delete(f"{self.url}/membres/{president.pk}/")
        self.assertEqual(reponse.data["code"], "role_president")


class CycleDeVie(Base):
    def test_modifier_en_brouillon(self):
        reponse = self.api.patch(f"{self.url}/", {"montant_cotisation": 15000, "nb_places": 4}, format="json")
        self.assertEqual((reponse.status_code, reponse.data["montant_cotisation"]), (200, 15000))
        reponse = self.api.patch(f"{self.url}/", {"nb_places": 1}, format="json")
        self.assertEqual(reponse.status_code, 400)
        self.ajouter_nom(self.membre_bello)
        reponse = self.api.patch(f"{self.url}/", {"nb_places": 2}, format="json")
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "places_insuffisantes"))
        reponse = client_pour(self.bello).patch(f"{self.url}/", {"nom": "Pirate"}, format="json")
        self.assertEqual(reponse.status_code, 403)

    def test_annuler(self):
        reponse = self.api.post(f"{self.url}/annuler/")
        self.assertEqual((reponse.status_code, reponse.data["statut"]), (200, "annulee"))
        reponse = self.api.post(f"{self.url}/demarrer/")
        self.assertEqual(reponse.status_code, 409)

    def test_pas_d_annulation_apres_demarrage(self):
        demarrer_tontine(self.tontine, self.awa)
        self.assertEqual(self.api.post(f"{self.url}/annuler/").status_code, 409)

    def test_fin_puis_nouveau_cycle(self):
        self.ajouter_nom(self.membre_bello)
        self.api.put(f"{self.url}/membres/{self.membre_bello.pk}/role/", {"role": "tresorier"}, format="json")
        demarrer_tontine(self.tontine, self.awa)
        self.assertEqual(self.api.post(f"{self.url}/nouveau-cycle/").data["code"], "cycle_en_cours")
        for tour in self.tontine.tours.order_by("numero"):
            tirer_au_sort(tour, self.awa)
            for cotisation in tour.cotisations.all():
                enregistrer_paiement(cotisation, self.awa, cotisation.montant_du, "especes")
            remettre_caisse(tour, self.awa)
        self.tontine.refresh_from_db()
        self.assertEqual(self.tontine.statut, "terminee")

        reponse = self.api.post(f"{self.url}/nouveau-cycle/")
        self.assertEqual(reponse.status_code, 201, reponse.data)
        self.assertEqual(reponse.data["statut"], "brouillon")
        self.assertNotEqual(reponse.data["id"], self.tontine.pk)
        self.assertEqual({m["nom_complet"]: (m["role"], m["positions"]) for m in reponse.data["membres"]},
                         {"Awa": ("president", [1]), "Bello": ("tresorier", [2, 3])})


class Penalites(Base):
    def setUp(self):
        super().setUp()
        demarrer_tontine(self.tontine, self.awa)
        marquer_retards(aujourd_hui=date(2026, 11, 2))
        self.penalite = Penalite.objects.get(cotisation__membre=self.membre_bello)

    def test_visible_dans_la_cotisation(self):
        tour = self.tontine.tours.get(numero=1)
        cotisations = client_pour(self.bello).get(f"/api/v1/tours/{tour.pk}/cotisations/").data
        bello = next(c for c in cotisations if c["membre"] == "Bello")
        self.assertEqual(bello["statut"], "en_retard")
        self.assertEqual([(p["montant"], p["payee"]) for p in bello["penalites"]], [(500, False)])

    def test_encaisser(self):
        url = f"/api/v1/penalites/{self.penalite.pk}/payer/"
        self.assertEqual(client_pour(self.bello).post(url).status_code, 403)
        reponse = self.api.post(url)
        self.assertEqual((reponse.status_code, reponse.data["payee"]), (200, True))
        self.assertEqual(self.api.post(url).data["code"], "penalite_payee")

    def test_cotisation_en_retard_reste_payable(self):
        cotisation = Cotisation.objects.get(tour__numero=1, membre=self.membre_bello)
        reponse = self.api.post(f"/api/v1/cotisations/{cotisation.pk}/paiements/",
                                {"moyen": "especes", "montant": 10000}, format="json")
        self.assertEqual(reponse.status_code, 201)
        cotisation.refresh_from_db()
        self.assertEqual(cotisation.statut, "payee")

    def test_pas_de_remise_forcee_d_une_caisse_vide(self):
        tour = self.tontine.tours.get(numero=1)
        tirer_au_sort(tour, self.awa)
        reponse = self.api.post(f"/api/v1/tours/{tour.pk}/remise/", {"forcer": True}, format="json")
        self.assertEqual((reponse.status_code, reponse.data["code"]), (409, "caisse_vide"))
