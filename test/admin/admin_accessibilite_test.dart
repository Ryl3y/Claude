// design:accessibility-review automatisé sur l'admin : zones de toucher,
// libellés lecteur d'écran, contrastes, clair/sombre, FR/EN, ordinateur et
// petit écran, texte agrandi.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../aide_app.dart' show stabiliser;
import '../aide_widgets.dart';
import 'aide_admin.dart';

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

void main() {
  setUpAll(preparerTestsWidgets);

  for (final (langue, sombre, bureau) in [
    ('fr', false, true),
    ('en', true, true),
    ('fr', true, false),
    ('en', false, false),
  ]) {
    final fr = langue == 'fr';
    testWidgets('admin — $langue ${sombre ? 'sombre' : 'clair'} '
        '${bureau ? 'ordinateur' : 'petit écran'}', (tester) async {
      final semantique = tester.ensureSemantics();
      // Densité 3 comme un vrai téléphone : à densité 1, le lissage des
      // petits textes fausse la mesure du contraste.
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = bureau
          ? const Size(1280 * 3, 860 * 3)
          : const Size(412 * 3, 915 * 3);
      tester.platformDispatcher.platformBrightnessTestValue = sombre
          ? Brightness.dark
          : Brightness.light;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(
        await adminDeTest(
          auth: FauxAuthAdmin(),
          serveur: FauxServeurAdmin(),
          langue: langue,
        ),
      );
      await stabiliser(tester);
      await _verifier(tester); // connexion
      await tester.enterText(
        find.byType(TextField).first,
        FauxAuthAdmin.emailAdmin,
      );
      await tester.enterText(
        find.byType(TextField).last,
        FauxAuthAdmin.motDePasse,
      );
      await _toucher(tester, find.text(fr ? 'Se connecter' : 'Log in'));
      await _verifier(tester); // tableau de bord

      await _toucher(tester, find.text(fr ? 'Boutiques' : 'Shops').last);
      await _verifier(tester); // liste
      await _toucher(tester, find.text('Chez Awa'));
      await _verifier(tester); // fiche
      await _toucher(tester, find.text(fr ? 'Offrir des jours' : 'Give days'));
      await _verifier(tester); // dialogue
      await _toucher(tester, find.text(fr ? 'Annuler' : 'Cancel'));
      if (!bureau) {
        await tester.tap(find.byType(BackButton));
        await stabiliser(tester);
      }

      await _toucher(tester, find.text(fr ? 'Paiements' : 'Payments').last);
      await _verifier(tester);
      await _toucher(tester, find.text(fr ? 'Carte' : 'Map').last);
      await _verifier(tester);
      semantique.dispose();
    });
  }

  testWidgets('texte à 200 % sur petit écran : aucun débordement', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 740);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      await adminDeTest(
        auth: FauxAuthAdmin(dejaConnecte: true),
        serveur: FauxServeurAdmin(),
      ),
    );
    await stabiliser(tester);
    expect(tester.takeException(), isNull);
    for (final onglet in ['Boutiques', 'Paiements', 'Carte']) {
      await _toucher(tester, find.text(onglet).last);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
      await stabiliser(tester);
      expect(tester.takeException(), isNull, reason: onglet);
    }
  });
}
