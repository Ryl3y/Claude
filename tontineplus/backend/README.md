# TONTINE+ — backend Django

API REST et interface d'administration de TONTINE+, sur PostgreSQL.
Django gère le schéma de la base : les tables sont créées et modifiées par les migrations.

## Pile

Python 3.12+ · Django 5.2 · Django REST Framework · SimpleJWT · psycopg 3 · PostgreSQL 16

## Installation sur votre PC

1. **Base vide.** Les migrations Django créent elles-mêmes les tables. Si vous avez déjà
   exécuté `tontineplus_init.sql`, recréez la base vide (psql ou pgAdmin) :

   ```sql
   DROP DATABASE IF EXISTS tontineplus;
   CREATE DATABASE tontineplus;
   ```

2. **Environnement Python** (dans ce dossier `backend/`) :

   ```sh
   python -m venv .venv
   .venv\Scripts\activate          # Windows
   source .venv/bin/activate       # macOS / Linux
   pip install -r requirements.txt
   ```

3. **Configuration** : copiez `.env.example` en `.env`, puis renseignez au moins
   `DB_PASSWORD` (le mot de passe PostgreSQL). Le fichier `.env` n'est jamais versionné.

4. **Création des tables et du compte administrateur** :

   ```sh
   python manage.py migrate
   python manage.py createsuperuser     # demande téléphone (+2376...), nom, mot de passe
   python manage.py runserver
   ```

5. Ouvrez <http://127.0.0.1:8000/admin/> pour gérer la base depuis le navigateur.

## Ce que contient la base

| Table | Rôle |
| --- | --- |
| `utilisateurs` | Comptes, identifiés par le numéro de téléphone |
| `tontines` | Montant (FCFA), fréquence, mode d'attribution, statut |
| `membres` | Adhésion d'un utilisateur à une tontine, rôle et position de passage |
| `invitations` | Codes d'invitation valables 7 jours |
| `tours` | Une séance : date d'échéance, bénéficiaire, remise de la caisse |
| `cotisations` | Ce que chaque membre doit à chaque tour |
| `paiements` | Espèces ou Mobile Money ; `reference_externe` unique (anti double crédit) |
| `penalites` | Pénalités de retard |
| `journal_audit` | Trace de chaque action sensible |

Les règles critiques sont aussi des contraintes PostgreSQL : un membre ne rejoint qu'une
fois, ne ramasse qu'une fois par cycle, et un même paiement Mobile Money ne crédite qu'une fois.

## API (`/api/v1/`)

Authentification : en-tête `Authorization: Bearer <access>`. Erreurs au format `{code, message}`.

| Méthode | Route | Qui | Effet |
| --- | --- | --- | --- |
| POST | `auth/inscription/` | Public | Crée le compte, renvoie les jetons |
| POST | `auth/connexion/` | Public | `{telephone, password}` → jetons `access` (15 min) et `refresh` (30 j) |
| POST | `auth/refresh/` | Public | Nouveau jeton d'accès |
| POST | `auth/deconnexion/` | Connecté | Révoque le jeton `refresh` |
| GET | `moi/` | Connecté | Profil et tontines, avec mon rôle |
| GET, POST | `tontines/` | Connecté | Mes tontines ; création (le créateur devient président) |
| GET, PATCH | `tontines/{id}/` | Membre ; président | Détail ; modification tant qu'en brouillon |
| POST | `tontines/{id}/invitations/` | Président | `{telephone}` → code d'invitation |
| POST | `invitations/{code}/accepter/` | Invité | Rejoint la tontine |
| PUT | `tontines/{id}/ordre/` | Président | `{membres: [ids]}` ordre de passage |
| POST | `tontines/{id}/demarrer/` | Président | Génère tours et cotisations |
| GET | `tontines/{id}/tours/` | Membre | Calendrier, montants attendus et collectés |
| GET | `tontines/{id}/journal/` | Président | Journal d'audit |
| GET | `tours/{id}/cotisations/` | Membre | Qui a payé, qui doit |
| POST | `cotisations/{id}/paiements/` | Trésorier (espèces) ; membre (Mobile Money) | `{montant, moyen, reference_externe?}` |
| POST | `tours/{id}/remise/` | Trésorier, président | Clôt le tour ; `{forcer: true}` réservé au président |
| POST | `webhooks/mobile-money/{fournisseur}/` | Fournisseur (signature HMAC `X-Signature`) | Confirme un paiement, de façon idempotente |

## Tâche quotidienne

```sh
python manage.py marquer_retards
```

Passe en retard les cotisations échues, crée les pénalités et ouvre les tours à J-3.
À planifier une fois par jour (Planificateur de tâches Windows ou cron).

## Tests

Ils tournent sur un vrai PostgreSQL (l'utilisateur doit pouvoir créer une base de test) :

```sh
python manage.py test
```

17 tests couvrent l'authentification, les droits par rôle, le démarrage, les paiements,
la remise, le webhook rejoué, les retards et les contraintes de la base.

## Pas encore fait

- Connexion par code SMS (OTP) : la connexion se fait pour l'instant par mot de passe.
- Appels réels aux API MTN MoMo et Orange Money (seul le webhook de confirmation existe).
- Envoi des SMS d'invitation et de rappel.
