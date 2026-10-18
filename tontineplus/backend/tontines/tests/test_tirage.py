"""Tirage au sort à chaque séance, postes du bureau et désignation votée à la majorité du bureau."""

from datetime import date
from unittest import mock

from django.test import TestCase
from rest_framework.test import APIClient

from comptes.models import Utilisateur
from tontines.models import JournalAudit, Membre, Tour
from tontines.services import accepter_invitation, creer_invitation, creer_tontine, demarrer_tontine


def client_pour(utilisateur):
    client = APIClient()
    client.force_authenticate(utilisateur)
    return client


class Base(TestCase):
    """Awa présidente, Bello trésorier, Chantal secrétaire, Dodo simple membre : 4 noms, 4 tours."""

    def setUp(self):
        self.awa = Utilisateur.objects.create_user("+237690000001", "Awa", "motdepasse-solide-1")
        self.tontine = creer_tontine(self.awa, nom="Famille", montant_cotisation=10000, frequence="mensuelle",
                                     nb_places=4, date_debut=date(2026, 11, 1))
        self.u, self.m = {"Awa": self.awa}, {"Awa": self.tontine.membres.get()}
        for i, nom in enumerate(["Bello", "Chantal", "Dodo"], start=2):
            self.u[nom] = Utilisateur.objects.create_user(f"+23769000000{i}", nom, f"motdepasse-solide-{i}")
            code = creer_invitation(self.tontine, self.awa, self.u[nom].telephone).code
            self.m[nom] = accepter_invitation(code, self.u[nom])
        self.api = {nom: client_pour(u) for nom, u in self.u.items()}
        self.url = f"/api/v1/tontines/{self.tontine.pk}"

    def nommer(self, nom, role):
        return self.api["Awa"].put(f"{self.url}/membres/{self.m[nom].pk}/role/", {"role": role}, format="json")

    def demarrer_avec_bureau(self):
        self.nommer("Bello", "tresorier")
        self.nommer("Chantal", "secretaire")
        demarrer_tontine(self.tontine, self.awa)

    def tour(self, numero):
        return self.tontine.tours.get(numero=numero)

    def nom_de(self, membre):
        return self.m[membre].noms.get().pk

    def tirer(self, numero, par="Awa"):
        return self.api[par].post(f"/api/v1/tours/{self.tour(numero).pk}/tirage/")

    def proposer(self, numero, beneficiaire, par="Awa"):
        return self.api[par].post(f"/api/v1/tours/{self.tour(numero).pk}/designations/",
                                  {"nom": self.nom_de(beneficiaire), "motif": "Frais d'hôpital"}, format="json")

    def voter(self, designation_id, par, approuve):
        return self.api[par].post(f"/api/v1/designations/{designation_id}/vote/", {"approuve": approuve},
                                  format="json")


class Bureau(Base):
    def test_tous_les_postes(self):
        postes = ["tresorier", "secretaire", "secretaire_adjoint", "censeur", "censeur_adjoint",
                  "commissaire", "commissaire_adjoint"]
        for poste in postes:
            self.assertEqual(self.nommer("Dodo", poste).status_code, 200, poste)
        self.assertEqual(Membre.objects.get(pk=self.m["Dodo"].pk).role, "commissaire_adjoint")

    def test_un_seul_titulaire_par_poste(self):
        self.nommer("Chantal", "secretaire")
        reponse = self.nommer("Dodo", "secretaire")
        roles = {m["nom_complet"]: m["role"] for m in reponse.data["membres"]}
        self.assertEqual((roles["Chantal"], roles["Dodo"]), ("membre", "secretaire"))

    def test_refus(self):
        self.assertEqual(self.nommer("Dodo", "president").status_code, 400)
        reponse = self.api["Bello"].put(f"{self.url}/membres/{self.m['Dodo'].pk}/role/", {"role": "censeur"},
                                        format="json")
        self.assertEqual(reponse.status_code, 403)


class Tirage(Base):
    def test_aucun_beneficiaire_au_demarrage(self):
        self.demarrer_avec_bureau()
        self.assertFalse(Tour.objects.filter(tontine=self.tontine, beneficiaire__isnull=False).exists())

    def test_un_membre_du_bureau_tire_au_sort(self):
        self.demarrer_avec_bureau()
        self.assertEqual(self.tirer(1, par="Dodo").status_code, 403)  # simple membre
        reponse = self.tirer(1, par="Chantal")  # secrétaire
        self.assertEqual(reponse.status_code, 200, reponse.data)
        self.assertIn(reponse.data["beneficiaire"], {"Awa", "Bello", "Chantal", "Dodo"})
        entree = JournalAudit.objects.get(action="tirage")
        self.assertEqual(len(entree.details["candidats"]), 4)

    def test_tirage_definitif_et_dans_l_ordre(self):
        self.demarrer_avec_bureau()
        self.assertEqual(self.tirer(2).data["code"], "tirage_dans_l_ordre")
        self.tirer(1)
        self.assertEqual(self.tirer(1).data["code"], "tour_attribue")

    def test_chaque_nom_ramasse_une_fois(self):
        self.demarrer_avec_bureau()
        for numero in range(1, 5):
            self.tirer(numero)
        gagnants = sorted(t.beneficiaire.membre.utilisateur.nom_complet for t in self.tontine.tours.all())
        self.assertEqual(gagnants, ["Awa", "Bello", "Chantal", "Dodo"])

    def test_le_tirage_exclut_les_noms_deja_servis(self):
        self.demarrer_avec_bureau()
        self.tirer(1)
        deja = self.tour(1).beneficiaire_id
        with mock.patch("tontines.services.secrets.SystemRandom.choice", side_effect=lambda c: c[0]) as choix:
            self.tirer(2)
        candidats = {n.pk for n in choix.call_args.args[0]}
        self.assertEqual(len(candidats), 3)
        self.assertNotIn(deja, candidats)


class Designation(Base):
    def setUp(self):
        super().setUp()
        self.demarrer_avec_bureau()  # bureau : Awa, Bello, Chantal → majorité 2

    def test_acceptee_a_la_majorite(self):
        reponse = self.proposer(1, "Dodo")
        self.assertEqual(reponse.status_code, 201, reponse.data)
        self.assertEqual((reponse.data["statut"], reponse.data["decompte"]),
                         ("en_attente", {"pour": 1, "contre": 0, "electeurs": 3, "majorite": 2}))
        self.assertIsNone(self.tour(1).beneficiaire_id)  # une seule voix ne suffit pas
        reponse = self.voter(reponse.data["id"], "Bello", True)
        self.assertEqual(reponse.data["statut"], "acceptee")
        self.assertEqual(self.tour(1).beneficiaire_id, self.nom_de("Dodo"))
        self.assertTrue(JournalAudit.objects.filter(action="designation_acceptee").exists())

    def test_refusee_quand_la_majorite_devient_impossible(self):
        designation = self.proposer(1, "Dodo").data["id"]
        self.assertEqual(self.voter(designation, "Bello", False).data["statut"], "en_attente")
        self.assertEqual(self.voter(designation, "Chantal", False).data["statut"], "refusee")
        self.assertIsNone(self.tour(1).beneficiaire_id)
        self.assertEqual(self.tirer(1).status_code, 200)  # on revient au tirage

    def test_le_membre_designe_ne_vote_pas(self):
        reponse = self.proposer(1, "Bello")  # Bello est au bureau mais concerné
        self.assertEqual(reponse.data["decompte"]["electeurs"], 2)
        self.assertEqual(self.voter(reponse.data["id"], "Bello", True).data["code"], "vote_non_autorise")
        self.assertEqual(self.voter(reponse.data["id"], "Chantal", True).data["statut"], "acceptee")

    def test_un_simple_membre_ne_propose_ni_ne_vote(self):
        self.assertEqual(self.proposer(1, "Dodo", par="Dodo").status_code, 403)
        designation = self.proposer(1, "Chantal").data["id"]
        self.assertEqual(self.voter(designation, "Dodo", True).status_code, 403)

    def test_une_seule_demande_et_un_seul_vote(self):
        designation = self.proposer(1, "Dodo").data["id"]
        self.assertEqual(self.proposer(1, "Chantal", par="Bello").data["code"], "designation_en_cours")
        self.assertEqual(self.voter(designation, "Awa", True).data["code"], "deja_vote")

    def test_le_tirage_rend_la_demande_caduque(self):
        designation = self.proposer(1, "Dodo").data["id"]
        self.tirer(1)
        self.assertEqual(self.voter(designation, "Bello", True).data["code"], "designation_close")
        statuts = {d["id"]: d["statut"] for d in self.api["Awa"].get(f"{self.url}/designations/").data}
        self.assertEqual(statuts[designation], "caduque")

    def test_designation_d_un_tour_futur(self):
        designation = self.proposer(3, "Dodo").data["id"]
        self.voter(designation, "Bello", True)
        for numero in (1, 2, 4):
            self.tirer(numero)
            self.assertNotEqual(self.tour(numero).beneficiaire_id, self.nom_de("Dodo"))
        self.assertEqual(self.tirer(3).data["code"], "tour_attribue")
        self.assertEqual(self.proposer(4, "Dodo").data["code"], "tour_attribue")

    def test_nom_deja_servi(self):
        self.tirer(1)
        gagnant = self.tour(1).beneficiaire.membre.utilisateur.nom_complet
        self.assertEqual(self.proposer(2, gagnant).data["code"], "nom_indisponible")

    def test_bureau_insuffisant(self):
        for nom in ("Bello", "Chantal"):
            self.nommer(nom, "membre")
        reponse = self.proposer(1, "Awa")  # seule au bureau et concernée : personne pour voter
        self.assertEqual(reponse.data["code"], "bureau_insuffisant")

    def test_visible_par_tous_votable_par_le_bureau(self):
        self.proposer(1, "Dodo")
        dodo = self.api["Dodo"].get(f"{self.url}/designations/").data[0]
        bello = self.api["Bello"].get(f"{self.url}/designations/").data[0]
        self.assertEqual((dodo["beneficiaire"], dodo["peut_voter"]), ("Dodo", False))
        self.assertEqual((bello["peut_voter"], bello["mon_vote"]), (True, None))
