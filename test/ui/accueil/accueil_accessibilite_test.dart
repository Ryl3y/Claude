// design:accessibility-review automatisé sur les écrans 5 (Accueil) et 14
// (Rapports) : zones de toucher, libellés lecteur d'écran, contrastes,
// clair/sombre, FR/EN, texte à 200 % sur petit écran.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/core/heure_douala.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';

Future<void> _verifier(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

Future<void> _toucher(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await stabiliser(tester);
}

/// Un produit en stock bas, une vente à crédit (dette et chiffres du jour).
Future<void> _donnees(WidgetTester tester, AppDeTest app) async {
  final riz = await app.ajouterProduit(
    tester,
    nom: 'Riz parfumé 5 kg',
    quantite: 3,
    seuil: 4,
  );
  final awa = await app.ajouterClient(tester, nom: 'Awa');
  await app.vendreACredit(tester, clientId: awa, produitId: riz, avance: 500);
}

void main() {
  setUpAll(() async {
    await preparerTestsWidgets();
    HeureDouala.horloge = () => DateTime.utc(2026, 10, 10, 9, 18);
  });
  tearDownAll(() => HeureDouala.horloge = DateTime.now);

  for (final (langue, sombre) in [
    ('fr', false),
    ('fr', true),
    ('en', false),
    ('en', true),
  ]) {
    testWidgets(
      'accueil et rapports — $langue ${sombre ? 'sombre' : 'clair'}',
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
        await _verifier(tester); // accueil vide
        await _donnees(tester, app);
        await _verifier(tester); // accueil avec chiffres et stock bas

        await _toucher(tester, find.text(fr ? 'Rapports' : 'Reports'));
        await _verifier(tester); // rapports du jour
        await _toucher(tester, find.text(fr ? 'Semaine' : 'Week'));
        await _toucher(tester, find.text(fr ? 'Avant' : 'Earlier'));
        await _verifier(tester); // période passée, vide

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
    await _donnees(tester, app);
    // Texte à 200 % : le lien est plus bas, pas encore construit.
    await tester.scrollUntilVisible(
      find.text('Rapports'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    await _toucher(tester, find.text('Rapports'));
    await _toucher(tester, find.text('Mois'));
    await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
    await stabiliser(tester);
    expect(tester.takeException(), isNull);
    await app.fermer(tester);
  });
}
