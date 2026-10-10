// Captures des écrans 5 (Accueil) et 14 (Rapports : jour et mois), en
// français et en anglais, clair et sombre.
// Régénérer : flutter test --update-goldens test/goldens
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kassa/app.dart';
import 'package:kassa/core/heure_douala.dart';
import 'package:kassa/domain/panier.dart';

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
    testWidgets('accueil $suffixe', (tester) async {
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
      final riz = await app.ajouterProduit(
        tester,
        nom: 'Riz parfumé 5 kg',
        quantite: 20,
        prixAchat: 3000,
        prixVente: 3500,
        unite: fr ? 'sacs' : 'bags',
      );
      final huile = await app.ajouterProduit(
        tester,
        nom: 'Huile Mayor 1 L',
        quantite: 2,
        seuil: 4,
        prixAchat: 1200,
        prixVente: 1500,
        unite: fr ? 'bouteilles' : 'bottles',
      );
      final savon = await app.ajouterProduit(
        tester,
        nom: 'Savon Azur',
        quantite: 40,
        prixAchat: 200,
        prixVente: 250,
        unite: fr ? 'pièces' : 'pieces',
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
      final brigitte = await app.ajouterClient(tester, nom: 'Maman Brigitte');
      final paul = await app.ajouterClient(tester, nom: 'Paul Ngando');
      for (final (id, q, mode) in [
        (riz, 3.0, ModeChoisi.especes),
        (savon, 6.0, ModeChoisi.momo),
        (huile, 2.0, ModeChoisi.orangeMoney),
        (riz, 1.0, ModeChoisi.especes),
      ]) {
        await app.vendreComptant(
          tester,
          produitId: id,
          quantite: q,
          mode: mode,
        );
      }
      await app.vendreACredit(
        tester,
        clientId: brigitte,
        produitId: riz,
        quantite: 2,
        avance: 2000,
      );
      await app.vendreACredit(tester, clientId: paul, produitId: savon);
      await tester.runAsync(
        () => app.clients.enregistrerVersement(
          clientId: brigitte,
          montant: 1000,
          mode: ModeChoisi.especes,
        ),
      );
      await stabiliser(tester);

      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/accueil_5_$suffixe.png'),
      );

      await _toucher(tester, find.text(fr ? 'Rapports' : 'Reports'));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/accueil_14_jour_$suffixe.png'),
      );
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await stabiliser(tester);
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/accueil_14_bas_$suffixe.png'),
      );

      await app.fermer(tester);
    });
  }
}
