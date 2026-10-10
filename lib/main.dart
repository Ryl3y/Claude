import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/preferences/preferences_locales.dart';
import 'ui/state/langue.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // L'app doit marcher sans internet : la police vient des fichiers embarqués.
  GoogleFonts.config.allowRuntimeFetching = false;

  await initializeDateFormatting('fr');
  await initializeDateFormatting('en');
  final preferences = await PreferencesLocales.ouvrir();

  runApp(
    ProviderScope(
      overrides: [
        preferencesLocalesProvider.overrideWithValue(preferences),
      ],
      child: const KassaApp(),
    ),
  );
}
