// Captures des écrans 1 à 4 (bienvenue, connexion, code SMS, création de
// la boutique, code PIN), en français et en anglais, clair et sombre.
// Régénérer : flutter test --update-goldens test/goldens
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kassa/app.dart';
import 'package:kassa/core/heure_douala.dart';
import 'package:kassa/ui/widgets/widgets.dart';

import '../aide_app.dart';
import '../aide_widgets.dart';
import '../data/faux_auth.dart';
import '../data/faux_lieux.dart';
import '../data/synchro/faux_serveur.dart';
import '../ui/aide_lieu.dart';

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

  for (final (langue, sombre) in [
    ('fr', false),
    ('en', false),
    ('fr', true),
    ('en', true),
  ]) {
    final suffixe = '${langue}_${sombre ? 'sombre' : 'clair'}';
    testWidgets('inscription $suffixe', (tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(412 * 2, 915 * 2);
      tester.platformDispatcher.platformBrightnessTestValue = sombre
          ? Brightness.dark
          : Brightness.light;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final fr = langue == 'fr';

      final app = await AppDeTest.creer(
        langue: langue,
        compte: false,
        pinAuDemarrage: true,
        auth: FauxAuth(),
        serveur: FauxServeur(),
        lieux: FauxLieux(),
      );
      await tester.pumpWidget(app.widget);
      await tester.runAsync(() async => GoogleFonts.pendingFonts());
      await stabiliser(tester);
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/inscription_1_$suffixe.png'),
      );

      await _toucher(tester, find.text(fr ? 'Commencer' : 'Get started'));
      await tester.enterText(find.byType(TextField), '6 77 12 34 56');
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/inscription_2_$suffixe.png'),
      );

      await _toucher(
        tester,
        find.text(fr ? 'Recevoir le code' : 'Get the code'),
      );
      await tester.enterText(find.byType(TextField), '000000');
      await stabiliser(tester);
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/inscription_2_code_$suffixe.png'),
      );

      await tester.enterText(find.byType(TextField), '123456');
      await stabiliser(tester);
      await stabiliser(tester);
      await tester.enterText(
        find.widgetWithText(TextField, fr ? 'Nom de la boutique' : 'Shop name'),
        'Chez Maman Brigitte',
      );
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/inscription_3_$suffixe.png'),
      );

      // Lieu : listes officielles, village choisi, quartier proposé.
      await choisirArrondissement(
        tester,
        fr ? 'Ouest' : 'West',
        'Menoua',
        'Dschang',
        anglais: !fr,
      );
      await saisirLieu(
        tester,
        fr ? 'Ville ou village' : 'Town or village',
        'dsch',
        choix: 'Dschang',
      );
      final quartier = find.widgetWithText(
        TextField,
        fr ? 'Quartier' : 'Neighbourhood',
      );
      await tester.ensureVisible(quartier);
      await tester.tap(quartier);
      await tester.enterText(quartier, 'ha');
      await stabiliser(tester);
      await tester.ensureVisible(find.text('Haoussa'));
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/inscription_3_lieu_$suffixe.png'),
      );
      await app.fermer(tester);

      final app2 = await AppDeTest.creer(langue: langue, pinAuDemarrage: true);
      await tester.pumpWidget(app2.widget);
      await stabiliser(tester);
      for (final c in '000'.split('')) {
        await tester.tap(
          find.descendant(of: find.byType(NumPad), matching: find.text(c)),
        );
        await tester.pump();
      }
      await tester.tap(
        find.descendant(of: find.byType(NumPad), matching: find.text('0')),
      );
      await stabiliser(tester);
      await stabiliser(tester);
      await stabiliser(tester);
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/inscription_4_$suffixe.png'),
      );
      await app2.fermer(tester);
    });
  }
}
