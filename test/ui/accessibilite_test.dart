// Revue d'accessibilité automatique de la page de démonstration :
// zones de toucher (48 px), libellés pour lecteur d'écran, contrastes,
// texte agrandi par le téléphone. En clair et en sombre, en français et en anglais.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/ui/screens/demo_widgets_screen.dart';

import '../aide_widgets.dart';

void main() {
  setUpAll(preparerTestsWidgets);

  for (final (langue, sombre) in [
    ('fr', false),
    ('fr', true),
    ('en', false),
    ('en', true),
  ]) {
    final cas = '$langue ${sombre ? 'sombre' : 'clair'}';

    testWidgets('démo $cas : zones de toucher, libellés, contrastes', (
      tester,
    ) async {
      final semantique = tester.ensureSemantics();
      tester.view.physicalSize = const Size(412 * 3, 915 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        await appDeTest(
          const DemoWidgetsScreen(),
          langue: langue,
          sombre: sombre,
        ),
      );
      await tester.pumpAndSettle();

      // Parcourt toute la page, écran par écran.
      final defilement = find.byType(Scrollable).first;
      for (var i = 0; i < 8; i++) {
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await tester.drag(defilement, const Offset(0, -700));
        await tester.pumpAndSettle();
      }
      semantique.dispose();
    });
  }

  testWidgets('texte agrandi à 200 % : aucun débordement', (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      await appDeTest(const DemoWidgetsScreen(), echelleTexte: 2),
    );
    await tester.pumpAndSettle();
    final defilement = find.byType(Scrollable).first;
    for (var i = 0; i < 20; i++) {
      await tester.drag(defilement, const Offset(0, -600));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('écran étroit (320 px) : aucun débordement', (tester) async {
    tester.view.physicalSize = const Size(320 * 2, 640 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      await appDeTest(const DemoWidgetsScreen(), langue: 'en'),
    );
    await tester.pumpAndSettle();
    final defilement = find.byType(Scrollable).first;
    for (var i = 0; i < 12; i++) {
      await tester.drag(defilement, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
