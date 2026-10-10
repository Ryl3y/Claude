// Captures des écrans 6 (Nouvelle vente), 7 (Paiement espèces et crédit)
// et 8 (Historique, détail), en français et en anglais, clair et sombre.
// Régénérer : flutter test --update-goldens test/goldens
@Tags(['golden'])
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kassa/app.dart';
import 'package:kassa/core/heure_douala.dart';

import '../aide_app.dart';
import '../aide_widgets.dart';

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
    // Heure figée : la vente affiche toujours « 9 h 18 ».
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
    testWidgets('vente $suffixe', (tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(412 * 2, 915 * 2);
      tester.platformDispatcher.platformBrightnessTestValue = sombre
          ? Brightness.dark
          : Brightness.light;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final fr = langue == 'fr';

      final app = await AppDeTest.creer(langue: langue);
      await tester.pumpWidget(app.widget);
      await tester.runAsync(() async => GoogleFonts.pendingFonts());
      await stabiliser(tester);
      await app.ajouterProduit(
        tester,
        nom: 'Huile Mayor 1 L',
        quantite: 2,
        seuil: 4,
        prixAchat: 1200,
        prixVente: 1500,
        unite: fr ? 'bouteilles' : 'bottles',
      );
      await app.ajouterProduit(
        tester,
        nom: 'Lait concentré',
        quantite: 24,
        seuil: 6,
        prixAchat: 500,
        prixVente: 650,
        unite: fr ? 'boîtes' : 'cans',
      );
      await app.ajouterProduit(
        tester,
        nom: 'Riz parfumé 5 kg',
        quantite: 12,
        prixAchat: 3000,
        prixVente: 3500,
        unite: fr ? 'sacs' : 'bags',
      );
      await app.ajouterProduit(
        tester,
        nom: 'Savon Azur',
        quantite: 40,
        seuil: 10,
        prixAchat: 200,
        prixVente: 250,
        unite: fr ? 'pièces' : 'pieces',
      );
      await app.ajouterProduit(
        tester,
        nom: 'Spaghetti Panzani 500 g',
        quantite: 30,
        seuil: 5,
        prixAchat: 320,
        prixVente: 400,
        unite: fr ? 'paquets' : 'packs',
      );
      await app.ajouterProduit(
        tester,
        nom: 'Sucre en vrac',
        quantite: 1.5,
        seuil: 2,
        prixAchat: 750,
        prixVente: 900,
        unite: 'kg',
      );

      await tester.tap(find.text(fr ? 'Vendre' : 'Sell').last);
      await stabiliser(tester);
      await _toucher(tester, find.text('Riz parfumé 5 kg'));
      await _toucher(tester, find.text('Riz parfumé 5 kg'));
      await _toucher(tester, find.text('Savon Azur'));
      await tester.pump(const Duration(seconds: 5)); // la bulle d'aide se ferme
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/vente_6_$suffixe.png'),
      );

      await _toucher(tester, find.text(fr ? 'Encaisser' : 'Collect payment'));
      await _toucher(tester, find.text(fr ? '10 000 F' : '10,000 F'));
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/vente_7_especes_$suffixe.png'),
      );

      await _toucher(tester, find.text(fr ? 'Crédit' : 'Credit'));
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/vente_7_credit_$suffixe.png'),
      );

      await _toucher(tester, find.text(fr ? 'Espèces' : 'Cash'));
      await _toucher(
        tester,
        find.textContaining(fr ? 'Encaisser 7' : 'Collect 7'),
      );
      await tester.pump(const Duration(seconds: 5));
      await _toucher(tester, find.text(fr ? 'Historique' : 'History'));
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/vente_8_$suffixe.png'),
      );

      await _toucher(tester, find.textContaining(fr ? 'N°1 · ' : '#1 · '));
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/vente_8_detail_$suffixe.png'),
      );

      await app.fermer(tester);
    });
  }
}
