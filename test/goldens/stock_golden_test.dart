// Captures des écrans 9 (Stock), 10 (Produit) et 11 (Réappro),
// en français et en anglais, en clair et en sombre.
// Régénérer : flutter test --update-goldens test/goldens
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kassa/app.dart';
import 'package:kassa/ui/screens/stock/stock_screen.dart';

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

void main() {
  setUpAll(() async {
    await preparerTestsWidgets();
    await _chargerIcones();
  });

  for (final (langue, sombre) in [
    ('fr', false),
    ('en', false),
    ('fr', true),
    ('en', true),
  ]) {
    final suffixe = '${langue}_${sombre ? 'sombre' : 'clair'}';
    testWidgets('stock $suffixe', (tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(412 * 2, 915 * 2);
      tester.platformDispatcher.platformBrightnessTestValue = sombre
          ? Brightness.dark
          : Brightness.light;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final app = await AppDeTest.creer(langue: langue);
      await tester.pumpWidget(app.widget);
      await tester.runAsync(() async {
        await GoogleFonts.pendingFonts();
      });
      await stabiliser(tester);
      final epicerie = await tester.runAsync(
        () => app.produits.creerCategorie(
          nom: langue == 'fr' ? 'Épicerie' : 'Groceries',
          icone: 'grocery',
        ),
      );
      await app.ajouterProduit(
        tester,
        nom: 'Huile Mayor 1 L',
        quantite: 2,
        seuil: 4,
        prixAchat: 1200,
        prixVente: 1500,
        unite: langue == 'fr' ? 'bouteilles' : 'bottles',
        categorieId: epicerie,
      );
      await app.ajouterProduit(
        tester,
        nom: 'Lait concentré',
        quantite: 24,
        seuil: 6,
        prixAchat: 500,
        prixVente: 650,
        unite: langue == 'fr' ? 'boîtes' : 'cans',
        categorieId: epicerie,
      );
      await app.ajouterProduit(
        tester,
        nom: 'Riz parfumé 5 kg',
        quantite: 12,
        prixAchat: 3000,
        prixVente: 3500,
        unite: langue == 'fr' ? 'sacs' : 'bags',
        categorieId: epicerie,
      );
      await app.ajouterProduit(
        tester,
        nom: 'Savon Azur',
        quantite: 40,
        seuil: 10,
        prixAchat: 200,
        prixVente: 250,
        unite: langue == 'fr' ? 'pièces' : 'pieces',
      );
      await app.ajouterProduit(
        tester,
        nom: 'Spaghetti Panzani 500 g',
        quantite: 0,
        seuil: 5,
        prixAchat: 320,
        prixVente: 400,
        unite: langue == 'fr' ? 'paquets' : 'packs',
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

      await tester.tap(find.text('Stock').last);
      await stabiliser(tester);
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/stock_9_$suffixe.png'),
      );

      await tester.tap(find.text('Lait concentré'));
      await stabiliser(tester);
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/stock_10_$suffixe.png'),
      );
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
      await tester.enterText(find.byType(TextFormField).first, '24');
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/stock_11_$suffixe.png'),
      );

      await app.fermer(tester);
    });
  }
}
