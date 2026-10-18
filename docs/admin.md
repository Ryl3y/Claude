# Kassa Admin : tableau de bord de l'équipe

Application Flutter web, dans le même dépôt que l'app (`lib/admin/`). Elle montre les chiffres clés, les boutiques, les paiements Notch Pay et la carte des zones couvertes. Elle permet aussi d'offrir des jours d'essai ou de Pro, et chaque geste est tracé.

## Lancer et construire

```sh
# Sur ton ordinateur, avec Chrome :
flutter run -d chrome -t lib/admin/main_admin.dart --dart-define-from-file=config/kassa.json

# Version à mettre en ligne (dossier build/web) :
flutter build web -t lib/admin/main_admin.dart --dart-define-from-file=config/kassa.json
```

`config/kassa.json` est le même fichier que pour l'app : l'URL Supabase et la clé publiable. Ce fichier n'est jamais dans le dépôt, et l'admin n'utilise jamais la clé secrète.

## Créer un compte admin

1. Ouvre le tableau de bord Supabase du projet Kassa. Va dans **Authentication > Users > Add user > Create new user**. Saisis l'e-mail et un mot de passe solide, puis coche « Auto Confirm User ».
2. Dans le **SQL Editor**, ajoute ce compte à la liste des admins :

   ```sql
   insert into public.admins (utilisateur_id, email)
   select id, email from auth.users where email = 'ton-email@exemple.com';
   ```

3. Pour retirer un admin :

   ```sql
   delete from public.admins where email = 'ton-email@exemple.com';
   ```

Un compte qui n'est pas dans `admins` ne peut rien lire : le serveur vérifie la liste à chaque appel.

## Réglages conseillés

- **Inscriptions par e-mail :** dans Authentication > Providers > Email, désactive « Allow new users to sign up ». Les admins sont créés à la main, et l'app des commerçants passe par le SMS.
- **Double authentification (MFA) :** active-la pour les comptes admin si possible.

## Mise en ligne

Le dossier `build/web` est un site statique. Tu peux l'héberger sur n'importe quel hébergeur de sites statiques (à choisir). L'adresse doit rester discrète : la page demande `noindex` aux moteurs de recherche. Le vrai contrôle d'accès reste toutefois sur le serveur.

## Lieux (villages et quartiers)

À la création de la boutique, le commerçant choisit Région → Département →
Arrondissement (découpage officiel OCHA, embarqué dans l'app, marche sans
internet), puis sa ville ou son village (liste OpenStreetMap, ~11 300 noms)
et son quartier. S'il ne trouve pas son nom, il l'ajoute : il est proposé
tout de suite aux suivants (même nom sans accents ni majuscules = même lieu ;
un même nom de quartier peut exister dans plusieurs villages).

L'écran **Lieux** de l'admin liste ces ajouts : **Corriger** une faute (les
boutiques qui l'utilisent suivent) ou **Retirer** un doublon. Un village de
la liste OSM ne peut pas être retiré.

Licence : la liste des villages vient d'OpenStreetMap (ODbL). L'app affiche
« © contributeurs OpenStreetMap » sous le champ, et la liste enrichie reste
sous la même licence (on peut la partager, pas la fermer).

Ordre de mise en ligne : appliquer d'abord les migrations `*_lieux*` sur
Supabase, **puis** publier cette version de l'app (sinon l'envoi des
boutiques échoue : colonnes inconnues).
