// design:accessibility-review automatisé sur les écrans 12 et 13, plus
// l'encaissement et le reçu : zones de toucher, libellés lecteur d'écran,
// contrastes (hors formulaires, voir stock_accessibilite_test.dart),
// clair/sombre, FR/EN, texte à 200 % sur petit écran.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/ui/widgets/widgets.dart';

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

Future<void> _taper(WidgetTester tester, String chiffres) async {
  // Texte à 200 % : le pavé est plus bas dans la liste, pas encore construit.
  if (find.byType(NumPad).evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      find.byType(NumPad),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  for (final c in chiffres.split('')) {
    final touche = find.descendant(
      of: find.byType(NumPad),
      matching: find.text(c),
    );
    await tester.ensureVisible(touche);
    await tester.pump();
    await tester.tap(touche);
    await tester.pump();
  }
  await stabiliser(tester);
}

/// Deux clients : Maman Brigitte doit 7 000 FCFA, Aïcha est à jour.
Future<void> _donnees(WidgetTester tester, AppDeTest app) async {
  final riz = await app.ajouterProduit(tester, nom: 'Riz', prixVente: 3500);
  final brigitte = await app.ajouterClient(
    tester,
    nom: 'Maman Brigitte',
    telephone: '690000001',
  );
  await app.ajouterClient(tester, nom: 'Aïcha Bello');
  await app.vendreACredit(
    tester,
    clientId: brigitte,
    produitId: riz,
    quantite: 2,
  );
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
      'clients, fiche, encaissement — $langue ${sombre ? 'sombre' : 'clair'}',
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
        await _donnees(tester, app);

        await ouvrirClients(tester, libelle: fr ? 'Clients' : 'Customers');
        await _verifier(tester); // écran 12

        await _toucher(tester, find.text('Maman Brigitte'));
        await _verifier(tester); // écran 13

        await _toucher(tester, find.text(fr ? 'Encaisser' : 'Collect payment'));
        await _taper(tester, '5000');
        await _verifier(tester); // encaissement
        await _taper(tester, '0'); // 50 000 : plus que la dette
        await _verifier(tester);
        await tester.longPress(
          find.descendant(
            of: find.byType(NumPad),
            matching: find.text(fr ? 'Effacer' : 'Delete'),
          ),
        );
        await _taper(tester, '5000');
        await _toucher(
          tester,
          find.textContaining(fr ? 'Encaisser 5' : 'Collect 5'),
        );
        await _verifier(tester); // reçu

        await _toucher(tester, find.text(fr ? 'Terminer' : 'Done'));
        await _toucher(tester, find.text(fr ? 'Modifier' : 'Edit'));
        await _verifier(tester, contraste: false); // formulaire

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
    await ouvrirClients(tester);
    await _toucher(tester, find.text('Maman Brigitte'));
    await _toucher(tester, find.text('Encaisser'));
    await _taper(tester, '5000');
    await _toucher(tester, find.textContaining('Encaisser 5'));
    await _toucher(tester, find.text('Terminer'));
    await _toucher(tester, find.text('Modifier'));
    expect(tester.takeException(), isNull);
    await app.fermer(tester);
  });
}
