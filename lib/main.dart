import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config.dart';
import 'data/firebase/services_firebase.dart';
import 'data/preferences/preferences_locales.dart';
import 'data/providers.dart';
import 'ui/state/langue.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // L'app doit marcher sans internet : la police vient des fichiers embarqués.
  GoogleFonts.config.allowRuntimeFetching = false;

  await initializeDateFormatting('fr');
  await initializeDateFormatting('en');
  // Notifications et rapports de plantage, si Firebase est configuré.
  await ServicesFirebase.demarrer();

  // Serveur de sauvegarde : réglages donnés à la compilation, jamais dans
  // le code (voir core/config.dart). Sans eux, l'app reste hors ligne.
  if (ConfigServeur.serveurConfigure) {
    await Supabase.initialize(
      url: ConfigServeur.supabaseUrl,
      publishableKey: ConfigServeur.supabaseClePubliable,
    );
  }
  final preferences = await PreferencesLocales.ouvrir();
  final appareilId = await preferences.appareilId();

  runApp(
    ProviderScope(
      overrides: [
        preferencesLocalesProvider.overrideWithValue(preferences),
        appareilIdProvider.overrideWithValue(appareilId),
      ],
      child: const KassaApp(),
    ),
  );
}
