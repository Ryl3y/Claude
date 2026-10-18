from rest_framework import serializers

from comptes.models import valider_telephone

from .models import Cotisation, Invitation, JournalAudit, Membre, Nom, Paiement, Penalite, Tontine, Tour


class MembreSerializer(serializers.ModelSerializer):
    nom_complet = serializers.CharField(source="utilisateur.nom_complet", read_only=True)
    telephone = serializers.CharField(source="utilisateur.telephone", read_only=True)
    positions = serializers.SerializerMethodField(help_text="Positions de passage de ses noms")

    class Meta:
        model = Membre
        fields = ["id", "tontine", "nom_complet", "telephone", "role", "statut", "positions", "rejoint_le"]
        read_only_fields = fields

    def get_positions(self, membre):
        return sorted(nom.position for nom in membre.noms.all() if nom.position)


class NomSerializer(serializers.ModelSerializer):
    """Une place de l'ordre de passage ; `rang` = 1er, 2e… nom du même membre."""

    membre_id = serializers.IntegerField(read_only=True)
    nom_complet = serializers.CharField(source="membre.utilisateur.nom_complet", read_only=True)
    rang = serializers.SerializerMethodField()

    class Meta:
        model = Nom
        fields = ["id", "position", "membre_id", "nom_complet", "rang"]
        read_only_fields = fields

    def get_rang(self, nom):
        positions = sorted(n.position for n in nom.membre.noms.all() if n.position)
        return positions.index(nom.position) + 1 if nom.position in positions else 1


class TontineSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tontine
        fields = [
            "id", "nom", "description", "montant_cotisation", "frequence", "mode_attribution",
            "nb_places", "penalite_retard", "date_debut", "statut", "cree_le",
        ]
        read_only_fields = ["statut", "cree_le"]

    def validate_montant_cotisation(self, valeur):
        if valeur <= 0:
            raise serializers.ValidationError("Le montant doit être positif.")
        return valeur

    def validate_nb_places(self, valeur):
        if not 2 <= valeur <= 100:
            raise serializers.ValidationError("Entre 2 et 100 places.")
        return valeur


class TontineDetailSerializer(TontineSerializer):
    membres = serializers.SerializerMethodField()
    ordre = serializers.SerializerMethodField(help_text="Les noms dans l'ordre de passage")

    class Meta(TontineSerializer.Meta):
        fields = TontineSerializer.Meta.fields + ["membres", "ordre"]

    def get_membres(self, tontine):
        actifs = [m for m in tontine.membres.all() if m.statut == Membre.Statut.ACTIF]
        return MembreSerializer(actifs, many=True).data

    def get_ordre(self, tontine):
        noms = sorted((n for n in tontine.noms.all() if n.position), key=lambda n: n.position)
        return NomSerializer(noms, many=True).data


class InvitationSerializer(serializers.ModelSerializer):
    telephone = serializers.CharField(validators=[valider_telephone])

    class Meta:
        model = Invitation
        fields = ["id", "telephone", "code", "expire_le", "acceptee_le"]
        read_only_fields = ["code", "expire_le", "acceptee_le"]


class OrdreSerializer(serializers.Serializer):
    noms = serializers.ListField(child=serializers.IntegerField(), allow_empty=False)


class TourSerializer(serializers.ModelSerializer):
    beneficiaire = serializers.CharField(source="beneficiaire.membre.utilisateur.nom_complet", read_only=True)
    beneficiaire_membre_id = serializers.IntegerField(source="beneficiaire.membre_id", read_only=True)
    montant_attendu = serializers.IntegerField(read_only=True)
    montant_collecte = serializers.IntegerField(read_only=True)
    nb_impayes = serializers.IntegerField(read_only=True)

    class Meta:
        model = Tour
        fields = [
            "id", "numero", "date_echeance", "beneficiaire", "beneficiaire_membre_id", "statut",
            "montant_remis", "remis_le",
            "montant_attendu", "montant_collecte", "nb_impayes",
        ]


class PenaliteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Penalite
        fields = ["id", "montant", "motif", "payee", "cree_le"]
        read_only_fields = fields


class CotisationSerializer(serializers.ModelSerializer):
    membre_id = serializers.IntegerField(read_only=True)
    membre = serializers.CharField(source="membre.utilisateur.nom_complet", read_only=True)
    nb_noms = serializers.SerializerMethodField()
    reste_a_payer = serializers.IntegerField(read_only=True)
    penalites = PenaliteSerializer(many=True, read_only=True)

    class Meta:
        model = Cotisation
        fields = ["id", "membre_id", "membre", "nb_noms", "montant_du", "montant_paye", "reste_a_payer",
                  "statut", "soldee_le", "penalites"]

    def get_nb_noms(self, cotisation):
        return max(cotisation.montant_du // cotisation.tour.tontine.montant_cotisation, 1)


class PaiementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Paiement
        fields = ["id", "cotisation", "montant", "moyen", "telephone_payeur", "statut", "cree_le", "confirme_le"]
        read_only_fields = fields


class PaiementEntreeSerializer(serializers.Serializer):
    """Espèces : montant obligatoire. Mobile Money : le reste dû est demandé au numéro indiqué."""

    moyen = serializers.ChoiceField(choices=Paiement.Moyen.choices)
    montant = serializers.IntegerField(min_value=1, required=False)
    telephone = serializers.CharField(validators=[valider_telephone], required=False)

    def validate(self, donnees):
        if donnees["moyen"] == Paiement.Moyen.ESPECES and "montant" not in donnees:
            raise serializers.ValidationError({"montant": "Obligatoire pour un paiement en espèces."})
        return donnees


class RoleSerializer(serializers.Serializer):
    role = serializers.ChoiceField(choices=[Membre.Role.TRESORIER, Membre.Role.MEMBRE])


class WebhookSerializer(serializers.Serializer):
    reference_externe = serializers.CharField()
    reussi = serializers.BooleanField()


class RemiseSerializer(serializers.Serializer):
    forcer = serializers.BooleanField(default=False)


class JournalSerializer(serializers.ModelSerializer):
    acteur = serializers.CharField(source="acteur.nom_complet", default=None, read_only=True)

    class Meta:
        model = JournalAudit
        fields = ["id", "action", "acteur", "details", "cree_le"]
