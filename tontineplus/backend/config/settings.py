"""Configuration Django de TONTINE+.

Tous les secrets et paramètres propres à une machine sont lus dans
l'environnement (fichier .env en local, jamais versionné).
"""

import os
from datetime import timedelta
from pathlib import Path

from django.core.exceptions import ImproperlyConfigured
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")


def env(nom, defaut=None):
    valeur = os.environ.get(nom, defaut)
    if valeur is None:
        raise ImproperlyConfigured(f"Variable d'environnement manquante : {nom}")
    return valeur


DEBUG = env("DJANGO_DEBUG", "false").lower() == "true"
CLE_DE_DEV = "dev-uniquement-cle-locale-non-secrete-a-ne-pas-utiliser-en-production"
SECRET_KEY = env("DJANGO_SECRET_KEY", CLE_DE_DEV if DEBUG else None)
ALLOWED_HOSTS = [h for h in env("DJANGO_ALLOWED_HOSTS", "localhost,127.0.0.1").split(",") if h]

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "rest_framework",
    "rest_framework_simplejwt.token_blacklist",
    "comptes",
    "tontines",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": env("DB_NAME", "tontineplus"),
        "USER": env("DB_USER", "postgres"),
        "PASSWORD": env("DB_PASSWORD"),
        "HOST": env("DB_HOST", "localhost"),
        "PORT": env("DB_PORT", "5432"),
        "CONN_MAX_AGE": 60,
    }
}

AUTH_USER_MODEL = "comptes.Utilisateur"

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

LANGUAGE_CODE = "fr-fr"
TIME_ZONE = "Africa/Douala"
USE_I18N = True
USE_TZ = True

STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": ["rest_framework.permissions.IsAuthenticated"],
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.CursorPagination",
    "PAGE_SIZE": 50,
    "EXCEPTION_HANDLER": "tontines.erreurs.gestionnaire_erreurs",
    # Limite par adresse IP des routes de code SMS (en plus des limites par numéro).
    "DEFAULT_THROTTLE_RATES": {"sms": "30/hour"},
}

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=15),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=30),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": True,
}

# Secret partagé avec les fournisseurs Mobile Money pour signer les webhooks.
MOBILE_MONEY_WEBHOOK_SECRET = env("MOBILE_MONEY_WEBHOOK_SECRET", "")

# SMS : "console" (écrit dans les logs) ou "africastalking".
SMS_BACKEND = env("SMS_BACKEND", "console")
AFRICASTALKING_USERNAME = env("AFRICASTALKING_USERNAME", "sandbox")
AFRICASTALKING_API_KEY = env("AFRICASTALKING_API_KEY", "")
AFRICASTALKING_EXPEDITEUR = env("AFRICASTALKING_EXPEDITEUR", "")

# Mobile Money : "simulation" (aucun appel réseau) ou "reel".
MOBILE_MONEY_MODE = env("MOBILE_MONEY_MODE", "simulation")
MTN_MOMO_BASE_URL = env("MTN_MOMO_BASE_URL", "https://sandbox.momodeveloper.mtn.com")
MTN_MOMO_ENVIRONNEMENT = env("MTN_MOMO_ENVIRONNEMENT", "sandbox")  # mtncameroon en production
MTN_MOMO_DEVISE = env("MTN_MOMO_DEVISE", "EUR")  # le bac à sable n'accepte que EUR ; XAF en production
MTN_MOMO_SUBSCRIPTION_KEY = env("MTN_MOMO_SUBSCRIPTION_KEY", "")
MTN_MOMO_API_USER = env("MTN_MOMO_API_USER", "")
MTN_MOMO_API_KEY = env("MTN_MOMO_API_KEY", "")
MTN_MOMO_CALLBACK_URL = env("MTN_MOMO_CALLBACK_URL", "")

if not DEBUG:
    SECURE_SSL_REDIRECT = True
    SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
    SECURE_HSTS_SECONDS = 60 * 60 * 24 * 30
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
