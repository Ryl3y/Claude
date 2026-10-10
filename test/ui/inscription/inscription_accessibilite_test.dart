// design:accessibility-review automatisé sur les écrans 1 à 4 : zones de
// toucher, libellés lecteur d'écran, contrastes (hors formulaires),
// clair/sombre, FR/EN, texte à 200 % sur petit écran.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/ui/widgets/widgets.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';
import '../../data/faux_auth.dart';
import '../../data/synchro/faux_serveur.dart';

Future<void> _verifier(WidgetTester tester, {bool contraste = true}) async {
  await tester.pump(const Duration(seconds: 1));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  if (contraste) {
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }
}

Future<void> _toucher(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await stabiliser(tester);
}

void main() {
  setUpAll(preparerTestsWidgets);

  for (final (langue, sombre) in [
    ('fr', false),
    ('fr', true),
    ('en', false),
    ('en', true),
  ]) {
    testWidgets(
      'inscription et code PIN — $langue ${sombre ? 'sombre' : 'clair'}',
      (tester) async {
        final semantique = tester.ensureSemantics();
        tester.view.physicalSize = const Size(412 * 3, 915 * 3);
        tester.view.devicePixelRatio = 3;
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
        );
        await tester.pumpWidget(app.widget);
        await stabiliser(tester);
        await _verifier(tester); // écran 1

        await _toucher(tester, find.text(fr ? 'Commencer' : 'Get started'));
        await _verifier(tester, contraste: false); // écran 2 (numéro)
        await tester.enterText(find.byType(TextField), '677123456');
        await _toucher(
          tester,
          find.text(fr ? 'Recevoir le code' : 'Get the code'),
        );
        await _verifier(tester, contraste: false); // écran 2 (code)
        await tester.enterText(find.byType(TextField), '123456');
        await stabiliser(tester);
        await stabiliser(tester);
        await _verifier(tester, contraste: false); // écran 3
        await app.fermer(tester);
        semantique.dispose();
      },
    );

    testWidgets('code PIN — $langue ${sombre ? 'sombre' : 'clair'}', (
      tester,
    ) async {
      final semantique = tester.ensureSemantics();
      tester.view.physicalSize = const Size(412 * 3, 915 * 3);
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.platformBrightnessTestValue = sombre
          ? Brightness.dark
          : Brightness.light;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final app = await AppDeTest.creer(
        langue: langue,
        pinAuDemarrage: true,
        auth: FauxAuth(),
        serveur: FauxServeur(),
      );
      await tester.pumpWidget(app.widget);
      await stabiliser(tester);
      await _verifier(tester); // écran 4
      for (final c in '0000'.split('')) {
        await tester.tap(
          find.descendant(of: find.byType(NumPad), matching: find.text(c)),
        );
        await tester.pump();
      }
      await stabiliser(tester);
      await stabiliser(tester);
      await _verifier(tester); // écran 4 avec message d'erreur
      await app.fermer(tester);
      semantique.dispose();
    });
  }

  testWidgets('texte à 200 % sur petit écran : aucun débordement', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final app = await AppDeTest.creer(
      compte: false,
      pinAuDemarrage: true,
      auth: FauxAuth(),
      serveur: FauxServeur(),
    );
    await tester.pumpWidget(app.widget);
    await stabiliser(tester);
    expect(tester.takeException(), isNull);
    await _toucher(tester, find.text('Commencer'));
    await tester.enterText(find.byType(TextField), '677123456');
    await _toucher(tester, find.text('Recevoir le code'));
    await tester.enterText(find.byType(TextField), '123456');
    await stabiliser(tester);
    await stabiliser(tester);
    expect(find.text('Votre boutique'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await app.fermer(tester);

    final app2 = await AppDeTest.creer(pinAuDemarrage: true);
    await tester.pumpWidget(app2.widget);
    await stabiliser(tester);
    expect(find.text('Entrez votre code PIN'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await app2.fermer(tester);
  });
}
