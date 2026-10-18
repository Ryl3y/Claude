# TONTINE+ — front React

Interface web de TONTINE+, branchée sur l'API Django de `../backend`.

React 18 · React Router 7 · Vite 5 · Tailwind CSS 3

## Lancer en local

Le backend doit tourner sur <http://127.0.0.1:8000> (voir `../backend/README.md`).

```sh
npm install
npm run dev
```

Ouvrez l'adresse affichée (<http://localhost:5173>). En développement, Vite relaie
les appels `/api` vers Django : aucune configuration CORS n'est nécessaire.
Si Django tourne ailleurs : `VITE_BACKEND=http://127.0.0.1:8001 npm run dev`.

## Parcours disponibles

| Page | Route | Ce qu'on y fait |
| --- | --- | --- |
| Connexion | `/login` | Code reçu par SMS (crée le compte au premier passage) ou mot de passe ; la session survit au rechargement |
| Inscription par mot de passe | `/register` | Variante sans SMS |
| Tableau de bord | `/` | Mes tontines, leur statut et mon rôle |
| Création / modification | `/create-group`, `/group/:id/modifier` | Montant par nom, fréquence, nombre de places (noms), ordre, pénalité, date du 1er tour |
| Détail d'une tontine | `/group/:id` | Membres et leurs noms ; pour le président : invitations, + 1 nom / retrait d'un nom ou d'un membre, ordre de passage, trésorier, démarrage, annulation, journal, nouveau cycle ; calendrier des tours ; paiement de sa cotisation par Mobile Money ; encaissement des cotisations et pénalités en espèces et remise de la caisse (trésorier, président) |
| Invitation | `/invitation/:code` | Rejoindre une tontine (inscription ou connexion d'abord si besoin) |

Les boutons affichés dépendent du rôle, et le backend revérifie chaque droit.

## Sécurité de la session

Le jeton d'accès (15 min) reste en mémoire. Le jeton de renouvellement est gardé dans
`localStorage` pour que la session survive au rechargement. La déconnexion le révoque
côté serveur.

## Production

`npm run build` produit `dist/`, à servir par Nginx sur le même domaine que l'API
(`/api` relayé vers Django). Pour une API sur un autre domaine, définir `VITE_API_URL`
au moment du build et autoriser ce domaine côté Django (CORS).
