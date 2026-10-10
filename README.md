# Kassa

Application Android (Flutter) de gestion pour petits commerces au Cameroun :
ventes, stock et dettes clients, même sans internet.

## Pile technique

Flutter (Android 8+) · Riverpod · go_router · drift (SQLite, source principale) ·
Supabase (Auth SMS, RLS, Edge Functions) · Firebase (Cloud Messaging et Crashlytics uniquement) ·
synchronisation maison drift ↔ Supabase · français (défaut) et anglais.

## Structure

```
lib/
  core/      outils communs : montants FCFA, heure de Douala, identifiants UUID
  data/      accès aux données : préférences locales (langue), puis drift et synchro
  domain/    règles métier pures (total, bénéfice, stock, solde_dette)
  ui/
    theme/   ThemeData + ThemeExtension<KassaTokens> (charte graphique)
    brand/   logo (symbole, nom « kassa »)
    state/   providers Riverpod (langue…)
    screens/ écrans
    router.dart
  l10n/      app_fr.arb, app_en.arb (+ generated/)
assets/
  fonts/     Plus Jakarta Sans embarquée (google_fonts sans téléchargement)
  logo/      SVG exacts du logo
  icon/      sources de l'icône d'app (flutter_launcher_icons)
```

## Commandes

```sh
flutter pub get
flutter gen-l10n                     # après une modification des .arb
dart run flutter_launcher_icons      # après une modification de l'icône
flutter test                         # tests unitaires + captures
flutter test --update-goldens test/goldens   # régénérer les captures
flutter run
```
