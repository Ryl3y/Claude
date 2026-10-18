from rest_framework import serializers

from comptes.models import valider_telephone

from .models import Cotisation, Invitation, JournalAudit, Membre, Paiement, Tontine, Tour


class MembreSerializer(serializers.ModelSerializer):
    nom_complet = serializers.CharField(source="utilisateur.nom_complet", read_only=True)
    telephone = serializers.CharField(source="utilisateur.telephone", read_only=True)

    class Meta:
        model = Membre
        fields = ["id", "nom_complet", "telephone", "role", "position_tour", "statut", "rejoint_le"]


class TontineSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tontine
        fields = [
            "id", "nom", "description", "montant_cotisation", "frequence", "mode_attribution",
            "nb_membres_max", "penalite_retard", "date_debut", "statut", "cree_le",
        ]
        read_only_fields = ["statut", "cree_le"]

    def validate_montant_cotisation(self, valeur):
        if valeur <= 0:
            raise serializers.ValidationError("Le montant doit être positif.")
        return valeur

    def validate_nb_membres_max(self, valeur):
        if not 2 <= valeur <= 100:
            raise serializers.ValidationError("Entre 2 et 100 membres.")
        return valeur


class TontineDetailSerializer(TontineSerializer):
    membres = MembreSerializer(many=True, read_only=True)

    class Meta(TontineSerializer.Meta):
        fields = TontineSerializer.Meta.fields + ["membres"]


class InvitationSerializer(serializers.ModelSerializer):
    telephone = serializers.CharField(validators=[valider_telephone])

    class Meta:
        model = Invitation
        fields = ["id", "telephone", "code", "expire_le", "acceptee_le"]
        read_only_fields = ["code", "expire_le", "acceptee_le"]


class OrdreSerializer(serializers.Serializer):
    membres = serializers.ListField(child=serializers.IntegerField(), allow_empty=False)


class TourSerializer(serializers.ModelSerializer):
    beneficiaire = serializers.CharField(source="beneficiaire.utilisateur.nom_complet", read_only=True)
    montant_attendu = serializers.IntegerField(read_only=True)
    montant_collecte = serializers.IntegerField(read_only=True)
    nb_impayes = serializers.IntegerField(read_only=True)

    class Meta:
        model = Tour
        fields = [
            "id", "numero", "date_echeance", "beneficiaire", "statut", "montant_remis", "remis_le",
            "montant_attendu", "montant_collecte", "nb_impayes",
        ]


class CotisationSerializer(serializers.ModelSerializer):
    membre = serializers.CharField(source="membre.utilisateur.nom_complet", read_only=True)
    reste_a_payer = serializers.IntegerField(read_only=True)

    class Meta:
        model = Cotisation
        fields = ["id", "membre", "montant_du", "montant_paye", "reste_a_payer", "statut", "soldee_le"]


class PaiementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Paiement
        fields = ["id", "montant", "moyen", "reference_externe", "statut", "cree_le", "confirme_le"]
        read_only_fields = ["statut", "cree_le", "confirme_le"]

    def validate(self, donnees):
        if donnees["moyen"] != Paiement.Moyen.ESPECES and not donnees.get("reference_externe"):
            raise serializers.ValidationError(
                {"reference_externe": "Obligatoire pour un paiement Mobile Money."}
            )
        return donnees


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
