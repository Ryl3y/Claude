"""Modèle de données TONTINE+.

Montants en FCFA entiers (le franc CFA n'a pas de centimes) : PositiveBigIntegerField.
Les règles critiques sont doublées par des contraintes PostgreSQL.
"""

from django.conf import settings
from django.db import models
from django.db.models import Q


class Tontine(models.Model):
    class Frequence(models.TextChoices):
        HEBDOMADAIRE = "hebdomadaire"
        QUINZAINE = "quinzaine"
        MENSUELLE = "mensuelle"

    class ModeAttribution(models.TextChoices):
        ORDRE_FIXE = "ordre_fixe", "ordre fixe"
        TIRAGE_AU_SORT = "tirage_au_sort", "tirage au sort"
        ENCHERE = "enchere", "enchère"

    class Statut(models.TextChoices):
        BROUILLON = "brouillon"
        ACTIVE = "active"
        TERMINEE = "terminee", "terminée"
        ANNULEE = "annulee", "annulée"

    nom = models.CharField(max_length=120)
    description = models.TextField(blank=True)
    montant_cotisation = models.PositiveBigIntegerField(help_text="En FCFA")
    frequence = models.CharField(max_length=16, choices=Frequence.choices)
    mode_attribution = models.CharField(
        max_length=16, choices=ModeAttribution.choices, default=ModeAttribution.ORDRE_FIXE
    )
    # Une place = un « nom » : un membre peut en tenir plusieurs. Nombre de tours = nombre de noms.
    nb_places = models.PositiveSmallIntegerField("nombre de places (noms)")
    penalite_retard = models.PositiveBigIntegerField(default=0, help_text="En FCFA")
    date_debut = models.DateField(null=True, blank=True)
    statut = models.CharField(max_length=12, choices=Statut.choices, default=Statut.BROUILLON)
    cree_par = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="tontines_creees"
    )
    cree_le = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "tontines"
        ordering = ["-cree_le"]
        constraints = [
            models.CheckConstraint(condition=Q(montant_cotisation__gt=0), name="tontines_montant_positif"),
            models.CheckConstraint(
                condition=Q(nb_places__gte=2, nb_places__lte=100),
                name="tontines_nb_places_2_100",
            ),
            models.CheckConstraint(
                condition=Q(frequence__in=["hebdomadaire", "quinzaine", "mensuelle"]),
                name="tontines_frequence_valide",
            ),
            models.CheckConstraint(
                condition=Q(mode_attribution__in=["ordre_fixe", "tirage_au_sort", "enchere"]),
                name="tontines_mode_valide",
            ),
            models.CheckConstraint(
                condition=Q(statut__in=["brouillon", "active", "terminee", "annulee"]),
                name="tontines_statut_valide",
            ),
        ]

    def __str__(self):
        return self.nom


class Membre(models.Model):
    class Role(models.TextChoices):
        PRESIDENT = "president", "président"
        TRESORIER = "tresorier", "trésorier"
        MEMBRE = "membre"

    class Statut(models.TextChoices):
        INVITE = "invite", "invité"
        ACTIF = "actif"
        EXCLU = "exclu"
        SORTI = "sorti"

    tontine = models.ForeignKey(Tontine, on_delete=models.CASCADE, related_name="membres")
    utilisateur = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="adhesions"
    )
    role = models.CharField(max_length=10, choices=Role.choices, default=Role.MEMBRE)
    statut = models.CharField(max_length=8, choices=Statut.choices, default=Statut.ACTIF)
    rejoint_le = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "membres"
        ordering = ["id"]
        constraints = [
            models.UniqueConstraint(fields=["tontine", "utilisateur"], name="membres_une_adhesion"),
            models.CheckConstraint(
                condition=Q(role__in=["president", "tresorier", "membre"]), name="membres_role_valide"
            ),
        ]

    def __str__(self):
        return f"{self.utilisateur} — {self.tontine}"


class Nom(models.Model):
    """Une place dans l'ordre de passage. Un membre a au moins un nom ; avec deux noms,
    il cotise deux fois à chaque tour et ramasse la caisse deux fois dans le cycle."""

    tontine = models.ForeignKey(Tontine, on_delete=models.CASCADE, related_name="noms")
    membre = models.ForeignKey(Membre, on_delete=models.CASCADE, related_name="noms")
    position = models.PositiveSmallIntegerField(null=True, blank=True)

    class Meta:
        db_table = "noms"
        ordering = ["position", "id"]
        verbose_name = "nom"
        constraints = [
            models.UniqueConstraint(fields=["tontine", "position"], name="noms_position_unique"),
            models.CheckConstraint(condition=Q(position__gt=0), name="noms_position_positive"),
        ]
        indexes = [models.Index(fields=["membre"], name="noms_membre_idx")]

    def __str__(self):
        return f"{self.membre.utilisateur.nom_complet} — n° {self.position}"


class Invitation(models.Model):
    tontine = models.ForeignKey(Tontine, on_delete=models.CASCADE, related_name="invitations")
    telephone = models.CharField(max_length=16)
    code = models.CharField(max_length=32, unique=True)
    invite_par = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT)
    expire_le = models.DateTimeField()
    acceptee_le = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "invitations"

    def __str__(self):
        return f"{self.telephone} → {self.tontine}"


class Tour(models.Model):
    """Une séance : tous les membres cotisent, un nom (donc son membre) ramasse la caisse."""

    class Statut(models.TextChoices):
        A_VENIR = "a_venir", "à venir"
        OUVERT = "ouvert"
        CLOS = "clos"

    tontine = models.ForeignKey(Tontine, on_delete=models.CASCADE, related_name="tours")
    numero = models.PositiveSmallIntegerField()
    date_echeance = models.DateField()
    beneficiaire = models.ForeignKey(
        Nom, on_delete=models.PROTECT, null=True, blank=True, related_name="tours_gagnes"
    )
    statut = models.CharField(max_length=8, choices=Statut.choices, default=Statut.A_VENIR)
    montant_remis = models.PositiveBigIntegerField(null=True, blank=True)
    remis_le = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "tours"
        ordering = ["tontine", "numero"]
        constraints = [
            models.UniqueConstraint(fields=["tontine", "numero"], name="tours_numero_unique"),
            # Chaque nom ramasse une seule fois par cycle.
            models.UniqueConstraint(fields=["tontine", "beneficiaire"], name="tours_un_gain_par_nom"),
            models.CheckConstraint(condition=Q(numero__gt=0), name="tours_numero_positif"),
            models.CheckConstraint(
                condition=Q(statut__in=["a_venir", "ouvert", "clos"]), name="tours_statut_valide"
            ),
        ]
        indexes = [
            models.Index(
                fields=["date_echeance"], condition=~Q(statut="clos"), name="tours_echeance_ouverts_idx"
            ),
        ]

    def __str__(self):
        return f"{self.tontine} — tour {self.numero}"


class Cotisation(models.Model):
    """Ce qu'un membre doit pour un tour : montant de la cotisation × son nombre de noms."""

    class Statut(models.TextChoices):
        DUE = "due"
        PARTIELLE = "partielle"
        PAYEE = "payee", "payée"
        EN_RETARD = "en_retard", "en retard"

    tour = models.ForeignKey(Tour, on_delete=models.CASCADE, related_name="cotisations")
    membre = models.ForeignKey(Membre, on_delete=models.PROTECT, related_name="cotisations")
    montant_du = models.PositiveBigIntegerField()
    montant_paye = models.PositiveBigIntegerField(default=0)
    statut = models.CharField(max_length=10, choices=Statut.choices, default=Statut.DUE)
    soldee_le = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "cotisations"
        ordering = ["tour", "membre"]
        constraints = [
            models.UniqueConstraint(fields=["tour", "membre"], name="cotisations_une_par_tour"),
            models.CheckConstraint(condition=Q(montant_du__gt=0), name="cotisations_montant_du_positif"),
            models.CheckConstraint(
                condition=Q(statut__in=["due", "partielle", "payee", "en_retard"]),
                name="cotisations_statut_valide",
            ),
        ]
        indexes = [
            models.Index(fields=["tour"], condition=~Q(statut="payee"), name="cotisations_impayees_idx"),
        ]

    @property
    def reste_a_payer(self):
        return max(self.montant_du - self.montant_paye, 0)

    def __str__(self):
        return f"{self.membre.utilisateur} — tour {self.tour.numero}"


class Paiement(models.Model):
    class Moyen(models.TextChoices):
        ESPECES = "especes", "espèces"
        MTN_MOMO = "mtn_momo", "MTN MoMo"
        ORANGE_MONEY = "orange_money", "Orange Money"

    class Statut(models.TextChoices):
        INITIE = "initie", "initié"
        REUSSI = "reussi", "réussi"
        ECHOUE = "echoue", "échoué"

    cotisation = models.ForeignKey(Cotisation, on_delete=models.PROTECT, related_name="paiements")
    montant = models.PositiveBigIntegerField()
    moyen = models.CharField(max_length=14, choices=Moyen.choices)
    # Unique : un même callback Mobile Money rejoué ne crédite qu'une fois.
    reference_externe = models.CharField(max_length=100, unique=True, null=True, blank=True)
    telephone_payeur = models.CharField(max_length=16, blank=True)
    statut = models.CharField(max_length=8, choices=Statut.choices, default=Statut.INITIE)
    enregistre_par = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, null=True, blank=True
    )
    cree_le = models.DateTimeField(auto_now_add=True)
    confirme_le = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "paiements"
        ordering = ["-cree_le"]
        constraints = [
            models.CheckConstraint(condition=Q(montant__gt=0), name="paiements_montant_positif"),
            models.CheckConstraint(
                condition=Q(moyen__in=["especes", "mtn_momo", "orange_money"]), name="paiements_moyen_valide"
            ),
            models.CheckConstraint(
                condition=Q(statut__in=["initie", "reussi", "echoue"]), name="paiements_statut_valide"
            ),
        ]

    def __str__(self):
        return f"{self.montant} FCFA ({self.get_moyen_display()})"


class Penalite(models.Model):
    cotisation = models.ForeignKey(Cotisation, on_delete=models.CASCADE, related_name="penalites")
    montant = models.PositiveBigIntegerField()
    motif = models.CharField(max_length=200)
    payee = models.BooleanField(default=False)
    cree_le = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "penalites"
        constraints = [
            models.CheckConstraint(condition=Q(montant__gt=0), name="penalites_montant_positif"),
        ]

    def __str__(self):
        return f"{self.montant} FCFA — {self.motif}"


class JournalAudit(models.Model):
    tontine = models.ForeignKey(
        Tontine, on_delete=models.SET_NULL, null=True, blank=True, related_name="journal"
    )
    acteur = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True
    )
    action = models.CharField(max_length=50)
    details = models.JSONField(default=dict, blank=True)
    cree_le = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "journal_audit"
        ordering = ["-cree_le"]
        verbose_name = "entrée du journal"
        verbose_name_plural = "journal d'audit"
        indexes = [models.Index(fields=["tontine", "-cree_le"], name="journal_tontine_date_idx")]

    def __str__(self):
        return f"{self.cree_le:%Y-%m-%d %H:%M} {self.action}"
