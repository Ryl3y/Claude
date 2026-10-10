// design:accessibility-review automatisé sur l'écran 15 (Réglages), l'offre
// et le paiement Kassa Pro, et la feuille « essai terminé » : zones de
// toucher, libellés lecteur d'écran, contrastes, clair/sombre, FR/EN,
// texte à 200 % sur petit écran.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/core/heure_douala.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';
import '../../data/faux_abonnement.dart';

Future<void> _verifier(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

Finder _defilement() => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .first;

Future<void> _toucher(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(f, 200, scrollable: _defilement());
  }
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await stabiliser(tester);
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
      'réglages et Kassa Pro — $langue ${sombre ? 'sombre' : 'clair'}',
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
          abonnement: FauxAbonnement(),
          abonnementGarde: ('gratuit', '2026-10-09'),
        );
        await tester.pumpWidget(app.widget);
        await stabiliser(tester);
        await _verifier(tester); // accueil : essai terminé

        await _toucher(tester, find.text(fr ? 'Nouvelle vente' : 'New sale'));
        await _verifier(tester); // feuille « essai terminé »
        await _toucher(tester, find.text(fr ? 'Plus tard' : 'Later'));

        await _toucher(tester, find.text(fr ? 'Réglages' : 'Settings'));
        await _verifier(tester); // réglages, haut
        await tester.drag(_defilement(), const Offset(0, -2000));
        await stabiliser(tester);
        await _verifier(tester); // réglages, bas
        await _toucher(tester, find.text(fr ? 'Se déconnecter' : 'Log out'));
        await _verifier(tester); // confirmation
        await _toucher(tester, find.text(fr ? 'Annuler' : 'Cancel'));

        await tester.drag(_defilement(), const Offset(0, 2000));
        await stabiliser(tester);
        await _toucher(tester, find.text(fr ? 'Passer à Pro' : 'Go Pro'));
        await _verifier(tester); // offre et paiement
        await _toucher(
          tester,
          find.textContaining(RegExp(fr ? r'^Payer 5' : r'^Pay 5')),
        );
        await _verifier(tester); // attente de validation
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(seconds: 3));
        }
        await stabiliser(tester);
        await _verifier(tester); // pas de réponse : message

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

    final app = await AppDeTest.creer(
      abonnement: FauxAbonnement(),
      abonnementGarde: ('gratuit', '2026-10-09'),
    );
    await tester.pumpWidget(app.widget);
    await stabiliser(tester);
    expect(tester.takeException(), isNull);
    await _toucher(tester, find.text('Nouvelle vente'));
    expect(tester.takeException(), isNull);
    await _toucher(tester, find.text('Plus tard'));
    await _toucher(tester, find.text('Réglages'));
    await tester.drag(_defilement(), const Offset(0, -3000));
    await stabiliser(tester);
    expect(tester.takeException(), isNull);
    await tester.drag(_defilement(), const Offset(0, 3000));
    await stabiliser(tester);
    await _toucher(tester, find.text('Passer à Pro'));
    await tester.drag(_defilement(), const Offset(0, -3000));
    await stabiliser(tester);
    expect(tester.takeException(), isNull);
    await app.fermer(tester);
  });
}
