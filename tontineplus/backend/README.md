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
| POST | `auth/code/demande/` | Public | `{telephone}` : envoie un code à 6 chiffres par SMS (valable 5 min) |
| POST | `auth/code/verification/` | Public | `{telephone, code, nom_complet?}` → jetons ; crée le compte si le numéro est nouveau (erreur `nom_requis` tant que le nom manque) |
| POST | `auth/connexion/` | Public | `{telephone, password}` → jetons `access` (15 min) et `refresh` (30 j) |
| POST | `auth/refresh/` | Public | Nouveau jeton d'accès |
| POST | `auth/deconnexion/` | Connecté | Révoque le jeton `refresh` |
| GET | `moi/` | Connecté | Profil et tontines, avec mon rôle |
| GET, POST | `tontines/` | Connecté | Mes tontines ; création (le créateur devient président) |
| GET, PATCH | `tontines/{id}/` | Membre ; président | Détail ; modification tant qu'en brouillon |
| POST | `tontines/{id}/invitations/` | Président | `{telephone}` → code d'invitation |
| POST | `invitations/{code}/accepter/` | Invité | Rejoint la tontine |
| PUT | `tontines/{id}/ordre/` | Président | `{membres: [ids]}` ordre de passage |
| PUT | `tontines/{id}/membres/{membre}/role/` | Président | `{role: "tresorier" \| "membre"}` ; un seul trésorier à la fois |
| POST | `tontines/{id}/demarrer/` | Président | Génère tours et cotisations |
| GET | `tontines/{id}/tours/` | Membre | Calendrier, montants attendus et collectés |
| GET | `tontines/{id}/journal/` | Président | Journal d'audit |
| GET | `tours/{id}/cotisations/` | Membre | Qui a payé, qui doit |
| POST | `cotisations/{id}/paiements/` | Trésorier ou président (espèces) ; le membre lui-même (Mobile Money) | Espèces : `{moyen: "especes", montant}`. Mobile Money : `{moyen: "mtn_momo", telephone?}`, demande le reste dû au numéro |
| GET | `paiements/{id}/` | Payeur, trésorier, président | Statut du paiement, relu chez l'opérateur tant qu'il est en attente |
| POST | `tours/{id}/remise/` | Trésorier, président | Clôt le tour ; `{forcer: true}` réservé au président |
| POST, PUT | `webhooks/mtn-momo/` | MTN | Notification : le statut est relu chez MTN, le contenu n'est pas cru |
| POST | `webhooks/mobile-money/{fournisseur}/` | Fournisseur (signature HMAC `X-Signature`) | Confirme un paiement, de façon idempotente |

## Connexion par SMS

Par défaut (`SMS_BACKEND=console`), aucun SMS n'est envoyé : le message s'affiche dans le
terminal de `runserver`, avec le code. En production, `SMS_BACKEND=africastalking` et les
identifiants Africa's Talking. Protections : 1 code par minute et 5 par heure et par numéro,
5 essais par code, code stocké sous forme d'empreinte, 30 demandes par heure et par adresse IP.

## Mobile Money

Par défaut (`MOBILE_MONEY_MODE=simulation`), aucun opérateur n'est appelé : le paiement
réussit, sauf si le numéro payeur se termine par `99` (pour tester un refus).

En mode `reel`, MTN MoMo (API Collection) est branché :
1. créer un compte sur <https://momodeveloper.mtn.com>, s'abonner au produit *Collection* ;
2. créer l'utilisateur API et sa clé (bac à sable), les mettre dans `.env` ;
3. en production : `MTN_MOMO_ENVIRONNEMENT=mtncameroon`, `MTN_MOMO_DEVISE=XAF`, et l'URL
   de production fournie par MTN après validation du dossier.

Le crédit d'une cotisation n'a lieu qu'une fois le statut confirmé par MTN (relu par
`GET requesttopay`), jamais sur la seule foi d'une notification.
Orange Money n'est pas encore branché en mode réel.

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

33 tests couvrent l'authentification (mot de passe et code SMS), les droits par rôle, le
trésorier, le démarrage, les paiements en espèces et Mobile Money (dont les requêtes
envoyées à MTN, réseau simulé), la remise, les retards et les contraintes de la base.

## Pas encore fait

- Orange Money en mode réel.
- Le client MTN MoMo et l'envoi Africa's Talking suivent leur documentation publique mais
  n'ont pas encore été essayés avec de vrais identifiants (bac à sable).
- SMS d'invitation et de rappel avant échéance.
