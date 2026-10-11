// Captures du tableau de bord admin (ordinateur et petit écran), français
// clair et anglais sombre.
// Régénérer : flutter test --update-goldens test/goldens
@Tags(['golden'])
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kassa/admin/admin_app.dart';
import 'package:kassa/core/heure_douala.dart';

import '../admin/aide_admin.dart';
import '../aide_app.dart' show stabiliser;
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

Future<void> _toucher(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await stabiliser(tester);
}

void main() {
  setUpAll(() async {
    await preparerTestsWidgets();
    await _chargerIcones();
    HeureDouala.horloge = () => DateTime.utc(2026, 10, 10, 8, 18);
  });
  tearDownAll(() => HeureDouala.horloge = DateTime.now);

  for (final (langue, sombre) in [('fr', false), ('en', true)]) {
    final suffixe = '${langue}_${sombre ? 'sombre' : 'clair'}';
    final fr = langue == 'fr';

    Future<void> ouvrir(
      WidgetTester tester, {
      bool connecte = true,
      Size taille = const Size(1280, 860),
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = taille;
      tester.platformDispatcher.platformBrightnessTestValue = sombre
          ? Brightness.dark
          : Brightness.light;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpWidget(
        await adminDeTest(
          auth: FauxAuthAdmin(dejaConnecte: connecte),
          serveur: FauxServeurAdmin(),
          langue: langue,
        ),
      );
      await tester.runAsync(() async => GoogleFonts.pendingFonts());
      await stabiliser(tester);
    }

    Future<void> capturer(WidgetTester tester, String nom) => expectLater(
      find.byType(AdminApp),
      matchesGoldenFile('goldens/admin_${nom}_$suffixe.png'),
    );

    testWidgets('admin connexion $suffixe', (tester) async {
      await ouvrir(tester, connecte: false);
      await capturer(tester, 'connexion');
    });

    testWidgets('admin écrans $suffixe', (tester) async {
      await ouvrir(tester);
      await capturer(tester, 'tableau_bord');
      await _toucher(tester, find.text(fr ? 'Boutiques' : 'Shops').first);
      await _toucher(tester, find.text('Beauté Divine'));
      await capturer(tester, 'boutiques');
      await _toucher(tester, find.text(fr ? 'Paiements' : 'Payments').first);
      await capturer(tester, 'paiements');
      await _toucher(tester, find.text(fr ? 'Carte' : 'Map').first);
      await capturer(tester, 'carte');
      await _toucher(tester, find.text(fr ? 'Lieux' : 'Places').first);
      await capturer(tester, 'lieux');
    });

    testWidgets('admin petit écran $suffixe', (tester) async {
      await ouvrir(tester, taille: const Size(412, 915));
      await capturer(tester, 'mobile');
    });
  }
}
