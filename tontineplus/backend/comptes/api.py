from django.contrib.auth.password_validation import validate_password
from django.urls import path
from rest_framework import serializers, status
from rest_framework.decorators import api_view, permission_classes, throttle_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from tontines.models import Membre
from tontines.serializers import TontineSerializer

from . import otp
from .models import Utilisateur, valider_telephone


class InscriptionSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = Utilisateur
        fields = ["id", "telephone", "nom_complet", "email", "password"]

    def validate(self, donnees):
        validate_password(donnees["password"], Utilisateur(**{k: v for k, v in donnees.items() if k != "password"}))
        return donnees

    def create(self, donnees):
        return Utilisateur.objects.create_user(**donnees)


class UtilisateurSerializer(serializers.ModelSerializer):
    class Meta:
        model = Utilisateur
        fields = ["id", "telephone", "nom_complet", "email"]


@api_view(["POST"])
@permission_classes([AllowAny])
def inscription(request):
    entree = InscriptionSerializer(data=request.data)
    entree.is_valid(raise_exception=True)
    utilisateur = entree.save()
    jetons = RefreshToken.for_user(utilisateur)
    return Response(
        {"utilisateur": UtilisateurSerializer(utilisateur).data,
         "access": str(jetons.access_token), "refresh": str(jetons)},
        status=status.HTTP_201_CREATED,
    )


class DemandeCodeSerializer(serializers.Serializer):
    telephone = serializers.CharField(validators=[valider_telephone])


class VerificationCodeSerializer(DemandeCodeSerializer):
    code = serializers.RegexField(r"^[0-9]{6}$")
    nom_complet = serializers.CharField(required=False, allow_blank=True, max_length=150)


class LimiteSMS(ScopedRateThrottle):
    scope = "sms"


@api_view(["POST"])
@permission_classes([AllowAny])
@throttle_classes([LimiteSMS])
def demander_code(request):
    entree = DemandeCodeSerializer(data=request.data)
    entree.is_valid(raise_exception=True)
    otp.demander_code(entree.validated_data["telephone"])
    return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(["POST"])
@permission_classes([AllowAny])
@throttle_classes([LimiteSMS])
def verifier_code(request):
    entree = VerificationCodeSerializer(data=request.data)
    entree.is_valid(raise_exception=True)
    utilisateur = otp.verifier_code(**entree.validated_data)
    jetons = RefreshToken.for_user(utilisateur)
    return Response({"utilisateur": UtilisateurSerializer(utilisateur).data,
                     "access": str(jetons.access_token), "refresh": str(jetons)})


@api_view(["POST"])
def deconnexion(request):
    """Révoque le jeton de renouvellement : la session ne peut plus être prolongée."""
    try:
        RefreshToken(request.data.get("refresh", "")).blacklist()
    except TokenError:
        return Response({"code": "jeton_invalide", "message": "Jeton invalide."}, status=status.HTTP_400_BAD_REQUEST)
    return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(["GET"])
def moi(request):
    tontines = [
        {**TontineSerializer(m.tontine).data, "mon_role": m.role}
        for m in Membre.objects.filter(utilisateur=request.user, statut=Membre.Statut.ACTIF)
        .select_related("tontine").order_by("-tontine__cree_le")
    ]
    return Response({"utilisateur": UtilisateurSerializer(request.user).data, "tontines": tontines})


urlpatterns = [
    path("auth/inscription/", inscription, name="inscription"),
    path("auth/connexion/", TokenObtainPairView.as_view(), name="connexion"),
    path("auth/code/demande/", demander_code, name="code-demande"),
    path("auth/code/verification/", verifier_code, name="code-verification"),
    path("auth/refresh/", TokenRefreshView.as_view(), name="refresh"),
    path("auth/deconnexion/", deconnexion, name="deconnexion"),
    path("moi/", moi, name="moi"),
]
