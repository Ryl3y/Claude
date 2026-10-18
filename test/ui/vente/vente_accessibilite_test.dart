// design:accessibility-review automatisé sur les écrans 6, 7 et 8 :
// zones de toucher, libellés lecteur d'écran, contrastes (hors formulaires,
// voir stock_accessibilite_test.dart), clair/sombre, FR/EN, texte à 200 %.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';

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
      'vente, paiement, historique — $langue ${sombre ? 'sombre' : 'clair'}',
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
        final app = await AppDeTest.creer(langue: langue);
        await tester.pumpWidget(app.widget);
        await stabiliser(tester);
        await app.ajouterProduit(tester, nom: 'Riz parfumé 5 kg', quantite: 12);
        await app.ajouterProduit(
          tester,
          nom: 'Huile 1 L',
          quantite: 2,
          seuil: 4,
        );

        await tester.tap(find.text(fr ? 'Vendre' : 'Sell').last);
        await stabiliser(tester);
        await _toucher(tester, find.text('Riz parfumé 5 kg'));
        await _verifier(tester); // écran 6

        await _toucher(tester, find.text(fr ? 'Encaisser' : 'Collect payment'));
        await _verifier(tester); // écran 7 (espèces)
        await _toucher(tester, find.text(fr ? 'Crédit' : 'Credit'));
        await _verifier(tester); // écran 7 (crédit)
        await _toucher(tester, find.text(fr ? 'Espèces' : 'Cash'));
        await _toucher(
          tester,
          find.textContaining(fr ? 'Encaisser 3' : 'Collect 3'),
        );

        await _toucher(tester, find.text(fr ? 'Historique' : 'History'));
        await _verifier(tester); // écran 8 (liste)
        await _toucher(tester, find.textContaining(fr ? 'N°1 · ' : '#1 · '));
        await _verifier(tester); // écran 8 (détail)

        await app.fermer(tester);
        semantique.dispose();
      },
    );
  }

  testWidgets('texte à 200 % sur petit écran : aucun débordement', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final app = await AppDeTest.creer();
    await tester.pumpWidget(app.widget);
    await stabiliser(tester);
    await app.ajouterProduit(
      tester,
      nom: 'Spaghetti Panzani 500 g',
      quantite: 30,
    );
    await tester.tap(find.text('Vendre').last);
    await stabiliser(tester);
    await _toucher(tester, find.text('Spaghetti Panzani 500 g'));
    await _toucher(tester, find.text('Encaisser'));
    await _toucher(tester, find.text('Crédit'));
    await _toucher(tester, find.text('Espèces'));
    await _toucher(tester, find.textContaining('Encaisser 3'));
    await _toucher(tester, find.text('Historique'));
    await _toucher(tester, find.textContaining('N°1'));
    expect(tester.takeException(), isNull);
    await app.fermer(tester);
  });
}
