// Captures de l'écran d'aperçu (étape 1), en français/anglais, clair/sombre.
// Régénérer : flutter test --update-goldens test/goldens
@Tags(['golden'])
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kassa/app.dart';
import 'package:kassa/data/preferences/preferences_locales.dart';
import 'package:kassa/ui/state/langue.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _chargerIcones() async {
  final loader = FontLoader('packages/material_symbols_icons/MaterialSymbolsRounded')
    ..addFont(rootBundle.load(
        'packages/material_symbols_icons/lib/fonts/MaterialSymbolsRounded.ttf'));
  await loader.load();
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('fr');
    await initializeDateFormatting('en');
    await _chargerIcones();
  });

  for (final (langue, sombre) in [
    ('fr', false),
    ('en', false),
    ('fr', true),
  ]) {
    final nom = 'apercu_${langue}_${sombre ? 'sombre' : 'clair'}';
    testWidgets(nom, (tester) async {
      SharedPreferences.setMockInitialValues({'langue': langue});
      final prefs = await PreferencesLocales.ouvrir();

      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(412 * 2, 2000 * 2);
      tester.platformDispatcher.platformBrightnessTestValue =
          sombre ? Brightness.dark : Brightness.light;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(ProviderScope(
        overrides: [preferencesLocalesProvider.overrideWithValue(prefs)],
        child: const KassaApp(),
      ));
      await tester.runAsync(() async {
        await GoogleFonts.pendingFonts();
        // Laisse flutter_svg décoder les SVG.
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      await expectLater(find.byType(KassaApp), matchesGoldenFile('goldens/$nom.png'));
    });
  }
}
