// Point d'entrée du tableau de bord admin (Flutter web) :
//
//   flutter run -d chrome -t lib/admin/main_admin.dart \
//     --dart-define-from-file=config/kassa.json
//   flutter build web -t lib/admin/main_admin.dart \
//     --dart-define-from-file=config/kassa.json
//
// Mêmes réglages que l'app (URL Supabase et clé publiable, jamais de clé
// secrète) ; l'accès est contrôlé par le serveur (table admins).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';
import '../data/preferences/preferences_locales.dart';
import '../l10n/generated/app_localizations.dart';
import '../ui/state/langue.dart';
import '../ui/theme/kassa_theme.dart';
import 'admin_app.dart';
import 'donnees/auth_admin.dart';
import 'donnees/serveur_admin.dart';
import 'etat/etat_admin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting('fr');
  await initializeDateFormatting('en');
  final preferences = await PreferencesLocales.ouvrir();

  if (!ConfigServeur.serveurConfigure) {
    runApp(const _SansConfiguration());
    return;
  }
  await Supabase.initialize(
    url: ConfigServeur.supabaseUrl,
    publishableKey: ConfigServeur.supabaseClePubliable,
  );
  final client = Supabase.instance.client;
  runApp(
    ProviderScope(
      overrides: [
        preferencesLocalesProvider.overrideWithValue(preferences),
        authAdminProvider.overrideWithValue(SupabaseAuthAdmin(client)),
        serveurAdminProvider.overrideWithValue(SupabaseServeurAdmin(client)),
      ],
      child: const AdminApp(),
    ),
  );
}

/// Compilé sans les réglages du serveur : on le dit, sans rien d'autre.
class _SansConfiguration extends StatelessWidget {
  const _SansConfiguration();

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: KassaTheme.clair(),
    supportedLocales: languesKassa,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    localeListResolutionCallback: (langues, _) => resoudreLangue(langues),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(AppLocalizations.of(context).adminConfigMissing),
          ),
        ),
      ),
    ),
  );
}
