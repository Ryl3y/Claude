# Mettre TONTINE+ en ligne

Tout tient dans `docker-compose.yml` : quatre conteneurs sur un seul serveur.

| Service | Rôle |
| --- | --- |
| `db` | PostgreSQL 16, données dans le volume `db` |
| `backend` | API Django servie par Gunicorn ; applique les migrations à chaque démarrage |
| `taches` | Lance `marquer_retards` toutes les heures (retards, pénalités, ouverture des tours) |
| `web` | Caddy : sert l'appli React, relaie `/api` et `/admin`, obtient et renouvelle le certificat HTTPS tout seul |

## Ce qu'il faut

- Un serveur Linux (VPS) avec 1 Go de mémoire au moins, Docker et Docker Compose installés.
  N'importe quel hébergeur convient. Choisir une région proche de vos membres améliore la vitesse.
- Un nom de domaine (par exemple `tontine.mondomaine.cm`) avec un enregistrement DNS **A** qui pointe
  vers l'adresse IP du serveur.
- Les ports 80 et 443 ouverts.

## Première mise en ligne

```sh
git clone https://github.com/Ryl3y/Claude.git && cd Claude/tontineplus
cp .env.production.example .env
nano .env        # DOMAINE, DJANGO_ALLOWED_HOSTS, DJANGO_SECRET_KEY, DB_PASSWORD, SMS, MTN…
docker compose up -d --build
docker compose exec backend python manage.py createsuperuser
```

Ouvrez `https://votre-domaine`. L'administration se trouve sur `https://votre-domaine/admin/`.

Pour générer la clé secrète et le mot de passe de la base :

```sh
python3 -c "import secrets; print(secrets.token_urlsafe(50))"
```

## Réglages à ne pas oublier

- **SMS** : `SMS_BACKEND=africastalking` et les identifiants Africa's Talking. En mode `console`,
  les codes ne partent pas : ils s'affichent dans `docker compose logs backend`.
- **Mobile Money** : laissez `MOBILE_MONEY_MODE=simulation` tant que les identifiants MTN de production
  ne sont pas validés. Ensuite, passez à `reel` avec `MTN_MOMO_ENVIRONNEMENT=mtncameroon` et
  `MTN_MOMO_DEVISE=XAF`.
  L'adresse de notification à déclarer chez MTN est `https://votre-domaine/api/v1/webhooks/mtn-momo/`.
- **Aperçu des liens partagés** : l'image d'aperçu (WhatsApp, Facebook) prend automatiquement
  l'adresse `https://DOMAINE/partage.png` à la construction.

## Au quotidien

| Action | Commande |
| --- | --- |
| Mettre à jour | `git pull && docker compose up -d --build` |
| Voir les journaux | `docker compose logs -f backend` |
| État des conteneurs | `docker compose ps` |
| Sauvegarder la base | `docker compose exec db pg_dump -U tontineplus tontineplus \| gzip > sauvegarde-$(date +%F).sql.gz` |
| Restaurer | `gunzip -c sauvegarde.sql.gz \| docker compose exec -T db psql -U tontineplus tontineplus` |

Faites une sauvegarde chaque jour et gardez-en une copie hors du serveur, par exemple avec une tâche cron.
Avec l'argent des membres en jeu, c'est indispensable.

## Sécurité déjà en place

- HTTPS obligatoire : HTTP est redirigé et l'en-tête HSTS est envoyé.
- Les en-têtes `X-Frame-Options`, `X-Content-Type-Options` et `Referrer-Policy` sont posés.
- Django tourne avec `DEBUG=false`, sous un utilisateur non privilégié.
- La base n'est jamais exposée sur Internet : seul le conteneur `web` ouvre des ports.
- Les secrets restent dans `.env`, qui n'est jamais versionné.

## Essai en local

Mettez `DOMAINE=localhost` et `DJANGO_ALLOWED_HOSTS=localhost` dans `.env`, puis lancez
`docker compose up -d --build` et ouvrez `https://localhost`. Le certificat local n'est pas reconnu
par le navigateur : acceptez l'avertissement.
