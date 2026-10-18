import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kassa/data/preferences/preferences_locales.dart';
import 'package:kassa/l10n/generated/app_localizations.dart';
import 'package:kassa/ui/state/langue.dart';
import 'package:kassa/ui/theme/kassa_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prépare l'environnement des tests de widgets (polices locales, dates).
Future<void> preparerTestsWidgets() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting('fr');
  await initializeDateFormatting('en');
}

/// Place [enfant] dans une app Kassa minimale (thème, traductions, Riverpod).
Future<Widget> appDeTest(
  Widget enfant, {
  String langue = 'fr',
  bool sombre = false,
  double echelleTexte = 1,
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({'langue': langue});
  final prefs = await PreferencesLocales.ouvrir();
  return ProviderScope(
    overrides: [
      preferencesLocalesProvider.overrideWithValue(prefs),
      ...overrides,
    ],
    child: MaterialApp(
      theme: sombre ? KassaTheme.sombre() : KassaTheme.clair(),
      locale: Locale(langue),
      supportedLocales: languesKassa,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(echelleTexte)),
        child: child!,
      ),
      home: Scaffold(body: enfant),
    ),
  );
}

/// Les libellés lus par le lecteur d'écran, fusionnés pour un widget.
String libelleDe(WidgetTester tester, Finder finder) =>
    tester.getSemantics(finder).label;
