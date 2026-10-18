from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import exception_handler

from .services import ErreurMetier


def gestionnaire_erreurs(exc, context):
    """Renvoie toutes les erreurs au format {code, message}, plus {champs} pour la validation."""
    if isinstance(exc, ErreurMetier):
        return Response({"code": exc.code, "message": exc.message}, status=status.HTTP_409_CONFLICT)
    reponse = exception_handler(exc, context)
    if reponse is None:
        return None
    if isinstance(reponse.data, dict) and set(reponse.data) == {"detail"}:
        detail = reponse.data["detail"]
        reponse.data = {"code": getattr(detail, "code", "erreur"), "message": str(detail)}
    else:
        reponse.data = {"code": "donnees_invalides", "message": "Données invalides.", "champs": reponse.data}
    return reponse
