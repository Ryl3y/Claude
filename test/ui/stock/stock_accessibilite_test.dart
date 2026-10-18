// design:accessibility-review automatisé sur les écrans 9, 10 et 11 :
// zones de toucher (48 px), libellés lecteur d'écran, contrastes,
// en clair et en sombre, en français et en anglais ; texte à 200 %.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/ui/screens/stock/stock_screen.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';

/// [contraste] = false pour les formulaires : textContrastGuideline mesure
/// les textes d'aide et les unités des champs au mauvais endroit de l'écran
/// (coordonnées locales des nœuds dans la liste) et lit le fond de la barre
/// du haut. Ces couleurs (ink-muted sur surface / surface-raised) sont
/// vérifiées à 4,5:1 dans test/ui/contraste_test.dart, et les captures
/// test/goldens/goldens/stock_10_* et stock_11_* le montrent.
Future<void> _verifier(WidgetTester tester, {bool contraste = true}) async {
  // Laisse finir les fondus des champs (aide, unités) avant de mesurer.
  await tester.pump(const Duration(seconds: 1));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  if (contraste) {
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }
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
      'stock, produit, réappro — $langue ${sombre ? 'sombre' : 'clair'}',
      (tester) async {
        final semantique = tester.ensureSemantics();
        tester.view.physicalSize = const Size(412 * 3, 915 * 3);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.platformBrightnessTestValue = sombre
            ? Brightness.dark
            : Brightness.light;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        final app = await AppDeTest.creer(langue: langue);
        await tester.pumpWidget(app.widget);
        await stabiliser(tester);
        await app.ajouterProduit(tester, nom: 'Riz parfumé 5 kg', quantite: 2);
        await app.ajouterProduit(
          tester,
          nom: 'Savon Azur',
          quantite: 40,
          unite: 'pièces',
        );

        await tester.tap(find.text('Stock').last);
        await stabiliser(tester);
        await _verifier(tester); // écran 9

        await tester.tap(find.text('Savon Azur'));
        await stabiliser(tester);
        await _verifier(tester, contraste: false); // écran 10
        await tester.tap(find.byType(BackButton));
        await stabiliser(tester);
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(
          find
              .descendant(
                of: find.byType(LigneStock),
                matching: find.byType(TextButton),
              )
              .first,
        );
        await stabiliser(tester);
        await _verifier(tester, contraste: false); // écran 11

        await app.fermer(tester);
        semantique.dispose();
      },
    );
  }

  testWidgets('texte agrandi à 200 % sur un petit écran : aucun débordement', (
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
      quantite: 0,
      unite: 'paquets',
    );
    await tester.tap(find.text('Stock').last);
    await stabiliser(tester);
    await tester.tap(find.text('Spaghetti Panzani 500 g'));
    await stabiliser(tester);
    await tester.tap(find.byType(BackButton));
    await stabiliser(tester);
    await tester.tap(
      find
          .descendant(
            of: find.byType(LigneStock),
            matching: find.byType(TextButton),
          )
          .first,
    );
    await stabiliser(tester);
    expect(tester.takeException(), isNull);
    await app.fermer(tester);
  });
}
