from rest_framework.exceptions import PermissionDenied

from .models import Membre


def adhesion(tontine, utilisateur):
    return Membre.objects.filter(
        tontine=tontine, utilisateur=utilisateur, statut=Membre.Statut.ACTIF
    ).first()


def exiger_role(tontine, utilisateur, *roles):
    """Vérifie côté serveur que l'utilisateur est membre actif, avec l'un des rôles donnés."""
    membre = adhesion(tontine, utilisateur)
    if membre is None:
        raise PermissionDenied("Vous n'êtes pas membre de cette tontine.")
    if roles and membre.role not in roles:
        raise PermissionDenied("Votre rôle ne permet pas cette action.")
    return membre
