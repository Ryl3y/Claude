"""Administration Django : interface web pour consulter et gérer toute la base."""

from django.contrib import admin

from .models import (
    Cotisation, Designation, Invitation, JournalAudit, Membre, Nom, Paiement, Penalite, Tontine, Tour,
    VoteDesignation,
)


class MembreInline(admin.TabularInline):
    model = Membre
    extra = 0
    autocomplete_fields = ["utilisateur"]
    fields = ["utilisateur", "role", "statut"]


class NomInline(admin.TabularInline):
    """Ordre de passage : un membre peut avoir plusieurs noms."""

    model = Nom
    extra = 0
    fields = ["position", "membre"]
    raw_id_fields = ["membre"]


class TourInline(admin.TabularInline):
    model = Tour
    extra = 0
    fields = ["numero", "date_echeance", "beneficiaire", "statut", "montant_remis", "remis_le"]
    readonly_fields = fields
    can_delete = False
    show_change_link = True


@admin.register(Tontine)
class TontineAdmin(admin.ModelAdmin):
    list_display = ["nom", "montant_cotisation", "frequence", "nb_places", "statut", "cree_par", "cree_le"]
    list_filter = ["statut", "frequence"]
    search_fields = ["nom", "cree_par__telephone", "cree_par__nom_complet"]
    autocomplete_fields = ["cree_par"]
    inlines = [MembreInline, NomInline, TourInline]


@admin.register(Membre)
class MembreAdmin(admin.ModelAdmin):
    list_display = ["utilisateur", "tontine", "role", "statut"]
    list_filter = ["role", "statut"]
    search_fields = ["utilisateur__telephone", "utilisateur__nom_complet", "tontine__nom"]
    autocomplete_fields = ["utilisateur", "tontine"]


@admin.register(Invitation)
class InvitationAdmin(admin.ModelAdmin):
    list_display = ["telephone", "tontine", "invite_par", "expire_le", "acceptee_le"]
    search_fields = ["telephone", "tontine__nom", "code"]
    autocomplete_fields = ["tontine", "invite_par"]


class CotisationInline(admin.TabularInline):
    model = Cotisation
    extra = 0
    fields = ["membre", "montant_du", "montant_paye", "statut", "soldee_le"]
    readonly_fields = fields
    can_delete = False
    show_change_link = True


@admin.register(Tour)
class TourAdmin(admin.ModelAdmin):
    list_display = ["tontine", "numero", "date_echeance", "beneficiaire", "statut", "montant_remis"]
    list_filter = ["statut"]
    search_fields = ["tontine__nom"]
    raw_id_fields = ["beneficiaire"]
    inlines = [CotisationInline]


class PaiementInline(admin.TabularInline):
    model = Paiement
    extra = 0
    fields = ["montant", "moyen", "reference_externe", "statut", "cree_le"]
    readonly_fields = fields
    can_delete = False


@admin.register(Cotisation)
class CotisationAdmin(admin.ModelAdmin):
    list_display = ["membre", "tour", "montant_du", "montant_paye", "statut"]
    list_filter = ["statut"]
    search_fields = ["membre__utilisateur__telephone", "tour__tontine__nom"]
    raw_id_fields = ["tour", "membre"]
    inlines = [PaiementInline]


@admin.register(Paiement)
class PaiementAdmin(admin.ModelAdmin):
    """Lecture seule : un paiement ne se corrige pas à la main, il passe par l'API."""

    list_display = ["cotisation", "montant", "moyen", "statut", "reference_externe", "cree_le"]
    list_filter = ["moyen", "statut"]
    search_fields = ["reference_externe", "cotisation__membre__utilisateur__telephone"]

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False


@admin.register(Penalite)
class PenaliteAdmin(admin.ModelAdmin):
    list_display = ["cotisation", "montant", "motif", "payee", "cree_le"]
    list_filter = ["payee"]
    raw_id_fields = ["cotisation"]


@admin.register(JournalAudit)
class JournalAuditAdmin(admin.ModelAdmin):
    list_display = ["cree_le", "tontine", "acteur", "action"]
    list_filter = ["action"]
    search_fields = ["tontine__nom", "acteur__telephone"]

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False


class VoteInline(admin.TabularInline):
    model = VoteDesignation
    extra = 0
    fields = ["membre", "approuve", "cree_le"]
    readonly_fields = fields
    can_delete = False


@admin.register(Designation)
class DesignationAdmin(admin.ModelAdmin):
    """Lecture seule : une désignation passe par le vote du bureau, pas par l'administration."""

    list_display = ["tour", "nom", "statut", "propose_par", "cree_le", "decide_le"]
    list_filter = ["statut"]
    inlines = [VoteInline]

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False
