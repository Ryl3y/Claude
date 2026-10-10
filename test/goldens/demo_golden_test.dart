// Captures de la page de démonstration des widgets (étape 3),
// en français et en anglais, en clair et en sombre.
// Régénérer : flutter test --update-goldens test/goldens
@Tags(['golden'])
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kassa/ui/screens/demo_widgets_screen.dart';

import '../aide_widgets.dart';

Future<void> _chargerIcones() async {
  final loader =
      FontLoader('packages/material_symbols_icons/MaterialSymbolsRounded')
        ..addFont(
          rootBundle.load(
            'packages/material_symbols_icons/lib/fonts/MaterialSymbolsRounded.ttf',
          ),
        );
  await loader.load();
}

void main() {
  setUpAll(() async {
    await preparerTestsWidgets();
    await _chargerIcones();
  });

  for (final (langue, sombre) in [
    ('fr', false),
    ('en', false),
    ('fr', true),
    ('en', true),
  ]) {
    final nom = 'demo_${langue}_${sombre ? 'sombre' : 'clair'}';
    testWidgets(nom, (tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(412 * 2, 2900 * 2);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        await appDeTest(
          const DemoWidgetsScreen(),
          langue: langue,
          sombre: sombre,
        ),
      );
      await tester.runAsync(() async {
        await GoogleFonts.pendingFonts();
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Un peu d'activité : deux produits au panier, 10 000 FCFA reçus.
      await tester.tap(find.textContaining('Riz'));
      await tester.pump();
      await tester.tap(find.textContaining('Riz'));
      await tester.pump();
      await tester.tap(find.textContaining('Savon'));
      await tester.pump();
      for (final touche in ['1', '000', '0']) {
        await tester.tap(find.text(touche).last);
        await tester.pump();
      }
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DemoWidgetsScreen),
        matchesGoldenFile('goldens/$nom.png'),
      );
    });
  }
}
