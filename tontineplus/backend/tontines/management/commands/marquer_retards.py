from django.core.management.base import BaseCommand

from tontines.services import marquer_retards


class Command(BaseCommand):
    help = "Passe en retard les cotisations échues, crée les pénalités et ouvre les tours proches. À lancer chaque jour."

    def handle(self, *args, **options):
        nombre = marquer_retards()
        self.stdout.write(self.style.SUCCESS(f"{nombre} cotisation(s) passée(s) en retard."))
