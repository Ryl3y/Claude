"""Plusieurs noms par membre.

La position de passage passe du membre à un « nom » ; un membre existant reçoit
un nom à sa position actuelle, et les tours déjà générés pointent vers ce nom.
"""

import django.db.models.deletion
from django.db import migrations, models
from django.db.models import Max, Q


def creer_noms(apps, schema_editor):
    Membre = apps.get_model("tontines", "Membre")
    Nom = apps.get_model("tontines", "Nom")
    Tour = apps.get_model("tontines", "Tour")
    for membre in Membre.objects.exclude(statut__in=["exclu", "sorti"]).order_by("tontine_id", "position_tour", "id"):
        position = membre.position_tour
        if position is None:
            position = (Nom.objects.filter(tontine_id=membre.tontine_id).aggregate(m=Max("position"))["m"] or 0) + 1
        Nom.objects.create(tontine_id=membre.tontine_id, membre_id=membre.pk, position=position)
    for tour in Tour.objects.exclude(beneficiaire__isnull=True):
        tour.beneficiaire_nom = Nom.objects.filter(membre_id=tour.beneficiaire_id).first()
        tour.save(update_fields=["beneficiaire_nom"])


class Migration(migrations.Migration):
    dependencies = [
        ("tontines", "0002_paiement_telephone_payeur"),
    ]

    operations = [
        migrations.CreateModel(
            name="Nom",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("position", models.PositiveSmallIntegerField(blank=True, null=True)),
                ("membre", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE,
                                             related_name="noms", to="tontines.membre")),
                ("tontine", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE,
                                              related_name="noms", to="tontines.tontine")),
            ],
            options={
                "verbose_name": "nom",
                "db_table": "noms",
                "ordering": ["position", "id"],
                "indexes": [models.Index(fields=["membre"], name="noms_membre_idx")],
                "constraints": [
                    models.UniqueConstraint(fields=("tontine", "position"), name="noms_position_unique"),
                    models.CheckConstraint(condition=Q(position__gt=0), name="noms_position_positive"),
                ],
            },
        ),
        migrations.AddField(
            model_name="tour",
            name="beneficiaire_nom",
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.PROTECT,
                                    related_name="+", to="tontines.nom"),
        ),
        migrations.RunPython(creer_noms, migrations.RunPython.noop),
        migrations.RemoveConstraint(model_name="tour", name="tours_un_gain_par_membre"),
        migrations.RemoveField(model_name="tour", name="beneficiaire"),
        migrations.RenameField(model_name="tour", old_name="beneficiaire_nom", new_name="beneficiaire"),
        migrations.AlterField(
            model_name="tour",
            name="beneficiaire",
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.PROTECT,
                                    related_name="tours_gagnes", to="tontines.nom"),
        ),
        migrations.AddConstraint(
            model_name="tour",
            constraint=models.UniqueConstraint(fields=("tontine", "beneficiaire"), name="tours_un_gain_par_nom"),
        ),
        migrations.RemoveConstraint(model_name="membre", name="membres_position_unique"),
        migrations.RemoveConstraint(model_name="membre", name="membres_position_positive"),
        migrations.RemoveField(model_name="membre", name="position_tour"),
        migrations.AlterModelOptions(name="membre", options={"ordering": ["id"]}),
        migrations.RemoveConstraint(model_name="tontine", name="tontines_nb_membres_2_100"),
        migrations.RenameField(model_name="tontine", old_name="nb_membres_max", new_name="nb_places"),
        migrations.AlterField(
            model_name="tontine",
            name="nb_places",
            field=models.PositiveSmallIntegerField(verbose_name="nombre de places (noms)"),
        ),
        migrations.AddConstraint(
            model_name="tontine",
            constraint=models.CheckConstraint(condition=Q(nb_places__gte=2, nb_places__lte=100),
                                              name="tontines_nb_places_2_100"),
        ),
    ]
