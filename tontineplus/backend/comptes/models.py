from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.core.validators import RegexValidator
from django.db import models

valider_telephone = RegexValidator(
    r"^\+[0-9]{8,15}$", "Numéro au format international, par exemple +237690000000."
)


class GestionnaireUtilisateurs(BaseUserManager):
    use_in_migrations = True

    def create_user(self, telephone, nom_complet, password=None, **extra):
        if not telephone:
            raise ValueError("Le numéro de téléphone est obligatoire.")
        utilisateur = self.model(telephone=telephone, nom_complet=nom_complet, **extra)
        utilisateur.set_password(password)
        utilisateur.save(using=self._db)
        return utilisateur

    def create_superuser(self, telephone, nom_complet, password=None, **extra):
        extra.setdefault("is_staff", True)
        extra.setdefault("is_superuser", True)
        return self.create_user(telephone, nom_complet, password, **extra)


class Utilisateur(AbstractBaseUser, PermissionsMixin):
    """Compte identifié par son numéro de téléphone (pas de nom d'utilisateur)."""

    telephone = models.CharField(max_length=16, unique=True, validators=[valider_telephone])
    nom_complet = models.CharField(max_length=150)
    email = models.EmailField(unique=True, null=True, blank=True)
    is_active = models.BooleanField("actif", default=True)
    is_staff = models.BooleanField("accès à l'administration", default=False)
    cree_le = models.DateTimeField(auto_now_add=True)

    objects = GestionnaireUtilisateurs()

    USERNAME_FIELD = "telephone"
    REQUIRED_FIELDS = ["nom_complet"]

    class Meta:
        db_table = "utilisateurs"
        verbose_name = "utilisateur"
        constraints = [
            models.CheckConstraint(
                condition=models.Q(telephone__regex=r"^\+[0-9]{8,15}$"),
                name="utilisateurs_telephone_format",
            ),
        ]

    def __str__(self):
        return f"{self.nom_complet} ({self.telephone})"


class CodeSMS(models.Model):
    """Code de connexion à usage unique envoyé par SMS. Seule son empreinte est stockée."""

    telephone = models.CharField(max_length=16, validators=[valider_telephone])
    empreinte = models.CharField(max_length=64)
    essais = models.PositiveSmallIntegerField(default=0)
    cree_le = models.DateTimeField(auto_now_add=True)
    expire_le = models.DateTimeField()
    utilise_le = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "codes_sms"
        verbose_name = "code SMS"
        indexes = [models.Index(fields=["telephone", "-cree_le"], name="codes_sms_telephone_idx")]

    def __str__(self):
        return f"{self.telephone} ({self.cree_le:%Y-%m-%d %H:%M})"
