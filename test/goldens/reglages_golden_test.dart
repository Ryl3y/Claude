// Captures de l'étape 9 : écran 15 (Réglages), offre et paiement Kassa Pro,
// rappel de fin d'essai sur l'accueil. Français et anglais, clair et sombre.
// Régénérer : flutter test --update-goldens test/goldens
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kassa/app.dart';
import 'package:kassa/core/heure_douala.dart';

import '../aide_app.dart';
import '../aide_widgets.dart';
import '../data/faux_abonnement.dart';

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
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
  }
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

  for (final (langue, sombre) in [
    ('fr', false),
    ('en', false),
    ('fr', true),
    ('en', true),
  ]) {
    final suffixe = '${langue}_${sombre ? 'sombre' : 'clair'}';
    final fr = langue == 'fr';

    Future<AppDeTest> ouvrir(
      WidgetTester tester, {
      (String, String)? abonnementGarde,
    }) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(412 * 2, 915 * 2);
      tester.platformDispatcher.platformBrightnessTestValue = sombre
          ? Brightness.dark
          : Brightness.light;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final app = await AppDeTest.creer(
        langue: langue,
        abonnement: FauxAbonnement(),
        abonnementGarde: abonnementGarde,
      );
      await tester.pumpWidget(app.widget);
      await tester.runAsync(() async => GoogleFonts.pendingFonts());
      await stabiliser(tester);
      return app;
    }

    testWidgets('réglages $suffixe', (tester) async {
      final app = await ouvrir(tester);
      await _toucher(tester, find.text(fr ? 'Réglages' : 'Settings'));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/reglages_15_$suffixe.png'),
      );
      await _toucher(tester, find.text(fr ? 'Modifier' : 'Edit'));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/reglages_boutique_$suffixe.png'),
      );
      await app.fermer(tester);
    });

    testWidgets('fin d\'essai et paiement $suffixe', (tester) async {
      final app = await ouvrir(
        tester,
        abonnementGarde: ('gratuit', '2026-10-12'),
      );
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/reglages_accueil_essai_$suffixe.png'),
      );
      await _toucher(tester, find.text(fr ? 'Passer à Pro' : 'Go Pro'));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/reglages_pro_$suffixe.png'),
      );
      await _toucher(
        tester,
        find.textContaining(RegExp(fr ? r'^Payer 5' : r'^Pay 5')),
      );
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/reglages_pro_attente_$suffixe.png'),
      );
      // Fin de l'attente (3 minutes) avant de fermer.
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(seconds: 3));
      }
      await app.fermer(tester);
    });

    testWidgets('essai terminé $suffixe', (tester) async {
      final app = await ouvrir(
        tester,
        abonnementGarde: ('gratuit', '2026-10-09'),
      );
      await _toucher(tester, find.text(fr ? 'Nouvelle vente' : 'New sale'));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/reglages_essai_termine_$suffixe.png'),
      );
      await app.fermer(tester);
    });
  }
}
