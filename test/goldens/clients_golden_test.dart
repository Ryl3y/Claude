// Captures des écrans 12 (Clients), 13 (Fiche client), de l'encaissement,
// du reçu et du formulaire, en français et en anglais, clair et sombre.
// Régénérer : flutter test --update-goldens test/goldens
@Tags(['golden'])
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kassa/app.dart';
import 'package:kassa/core/heure_douala.dart';
import 'package:kassa/domain/panier.dart';
import 'package:kassa/ui/widgets/widgets.dart';

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

Future<void> _taper(WidgetTester tester, String chiffres) async {
  for (final c in chiffres.split('')) {
    await tester.tap(
      find.descendant(of: find.byType(NumPad), matching: find.text(c)),
    );
    await tester.pump();
  }
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
    testWidgets('clients $suffixe', (tester) async {
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
        prixVente: 3500,
      );
      final huile = await app.ajouterProduit(
        tester,
        nom: 'Huile Mayor 1 L',
        prixVente: 1500,
      );
      final brigitte = await app.ajouterClient(
        tester,
        nom: 'Maman Brigitte',
        telephone: '6 90 00 00 01',
      );
      final paul = await app.ajouterClient(
        tester,
        nom: 'Paul Ngando',
        telephone: '6 77 12 34 56',
      );
      await app.ajouterClient(tester, nom: 'Aïcha Bello');
      await app.vendreACredit(
        tester,
        clientId: brigitte,
        produitId: riz,
        quantite: 4,
        avance: 1500,
      );
      await app.vendreACredit(
        tester,
        clientId: paul,
        produitId: huile,
        quantite: 2,
      );
      await tester.runAsync(
        () => app.clients.enregistrerVersement(
          clientId: brigitte,
          montant: 2000,
          mode: ModeChoisi.momo,
        ),
      );
      await stabiliser(tester);

      await ouvrirClients(tester, libelle: fr ? 'Clients' : 'Customers');
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/clients_12_$suffixe.png'),
      );

      await _toucher(tester, find.text('Maman Brigitte'));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/clients_13_$suffixe.png'),
      );

      await _toucher(tester, find.text(fr ? 'Encaisser' : 'Collect payment'));
      await _taper(tester, '5000');
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/clients_encaisser_$suffixe.png'),
      );

      await _toucher(
        tester,
        find.textContaining(fr ? 'Encaisser 5' : 'Collect 5'),
      );
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/clients_recu_$suffixe.png'),
      );

      await _toucher(tester, find.text(fr ? 'Terminer' : 'Done'));
      await _toucher(tester, find.text(fr ? 'Modifier' : 'Edit'));
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(KassaApp),
        matchesGoldenFile('goldens/clients_form_$suffixe.png'),
      );

      await app.fermer(tester);
    });
  }
}
