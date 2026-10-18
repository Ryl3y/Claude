from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.forms import UserChangeForm, UserCreationForm

from .models import CodeSMS, Utilisateur


class FormulaireCreation(UserCreationForm):
    class Meta:
        model = Utilisateur
        fields = ["telephone", "nom_complet"]


class FormulaireModification(UserChangeForm):
    class Meta:
        model = Utilisateur
        fields = "__all__"


@admin.register(Utilisateur)
class UtilisateurAdmin(UserAdmin):
    add_form = FormulaireCreation
    form = FormulaireModification
    ordering = ["-cree_le"]
    list_display = ["telephone", "nom_complet", "email", "is_active", "is_staff", "cree_le"]
    list_filter = ["is_active", "is_staff"]
    search_fields = ["telephone", "nom_complet", "email"]
    readonly_fields = ["cree_le", "last_login"]
    fieldsets = [
        (None, {"fields": ["telephone", "password"]}),
        ("Identité", {"fields": ["nom_complet", "email"]}),
        ("Droits", {"fields": ["is_active", "is_staff", "is_superuser", "groups", "user_permissions"]}),
        ("Dates", {"fields": ["cree_le", "last_login"]}),
    ]
    add_fieldsets = [
        (None, {"classes": ["wide"], "fields": ["telephone", "nom_complet", "password1", "password2"]}),
    ]


@admin.register(CodeSMS)
class CodeSMSAdmin(admin.ModelAdmin):
    """Lecture seule : le code lui-même n'est jamais stocké, seulement son empreinte."""

    list_display = ["telephone", "cree_le", "expire_le", "essais", "utilise_le"]
    search_fields = ["telephone"]
    exclude = ["empreinte"]

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False
