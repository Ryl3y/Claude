// Parcours de l'étape 5, hors ligne sur une base en mémoire :
// vente espèces (en 3 touchers), quantité au doigt (vrac), vente à crédit
// avec création du client, montant insuffisant, historique et annulation.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/db/tables.dart';
import 'package:kassa/ui/widgets/widgets.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';

Future<AppDeTest> _demarrer(WidgetTester tester, {String langue = 'fr'}) async {
  tester.view.physicalSize = const Size(412 * 3, 915 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final app = await AppDeTest.creer(langue: langue);
  await tester.pumpWidget(app.widget);
  await stabiliser(tester);
  return app;
}

Future<void> _ouvrirVendre(WidgetTester tester) async {
  await tester.tap(find.text('Vendre').last);
  await stabiliser(tester);
}

Future<void> _toucher(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await stabiliser(tester);
}

void main() {
  setUpAll(preparerTestsWidgets);

  testWidgets('aucun produit : message qui renvoie vers le Stock', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    await _ouvrirVendre(tester);
    expect(find.text('Aucun produit à vendre'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('vente espèces au montant exact : 3 touchers', (tester) async {
    final app = await _demarrer(tester);
    final riz = await app.ajouterProduit(tester, nom: 'Riz 5 kg', quantite: 10);
    await _ouvrirVendre(tester);

    await _toucher(tester, find.text('Riz 5 kg')); // 1
    await _toucher(tester, find.text('Encaisser')); // 2
    expect(find.text('Paiement'), findsOneWidget);
    await _toucher(tester, find.text('Encaisser 3 500 FCFA')); // 3

    expect(find.text('Vente n°1 enregistrée : 3 500 FCFA.'), findsOneWidget);
    final vente = await tester.runAsync(
      () => app.db.select(app.db.ventes).getSingle(),
    );
    expect(vente!.modePaiement, ModePaiement.especes);
    expect(vente.total, 3500);
    final produit = await tester.runAsync(
      () => (app.db.select(
        app.db.produits,
      )..where((p) => p.id.equals(riz))).getSingle(),
    );
    expect(produit!.quantite, 9);
    // Le panier est vidé pour la vente suivante.
    expect(
      find.text(
        'Touchez un produit pour l\'ajouter. Appui long pour choisir la quantité.',
      ),
      findsOneWidget,
    );
    await app.fermer(tester);
  });

  testWidgets('espèces : monnaie à rendre, montant insuffisant bloqué', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    await app.ajouterProduit(tester, nom: 'Riz', quantite: 10);
    await _ouvrirVendre(tester);
    await _toucher(tester, find.text('Riz'));
    await _toucher(tester, find.text('Riz'));
    await _toucher(tester, find.text('Encaisser'));

    // 7 000 à payer ; le client donne 5 000 : il manque 2 000.
    for (final touche in ['5', '000']) {
      await _toucher(tester, find.text(touche).last);
    }
    expect(find.textContaining('Il manque 2 000 FCFA'), findsOneWidget);
    final bouton = find.widgetWithText(KassaButton, 'Encaisser 7 000 FCFA');
    expect(tester.widget<KassaButton>(bouton).onPressed, isNull);

    // Puis 10 000 : monnaie 3 000.
    await _toucher(tester, find.text('10 000 F'));
    expect(find.text('Monnaie à rendre'), findsOneWidget);
    expect(find.text('3 000 FCFA'), findsOneWidget);
    await _toucher(tester, bouton);
    expect(
      find.text('Vente n°1 enregistrée. Rendez 3 000 FCFA.'),
      findsOneWidget,
    );
    await app.fermer(tester);
  });

  testWidgets('appui long : quantité en vrac avec la virgule', (tester) async {
    final app = await _demarrer(tester);
    await app.ajouterProduit(
      tester,
      nom: 'Sucre en vrac',
      quantite: 5,
      unite: 'kg',
      prixVente: 900,
      prixAchat: 750,
    );
    await _ouvrirVendre(tester);
    await tester.longPress(find.text('Sucre en vrac'));
    await stabiliser(tester);
    expect(find.text('Quantité de Sucre en vrac'), findsOneWidget);
    for (final touche in ['1', ',', '5']) {
      await _toucher(tester, find.text(touche).last);
    }
    expect(find.text('1,5 kg'), findsOneWidget);
    await _toucher(tester, find.text('Mettre au panier'));
    expect(find.textContaining('1 350 FCFA'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('vente à crédit : nouveau client, avance, dette enregistrée', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    await app.ajouterProduit(tester, nom: 'Riz', quantite: 10);
    await _ouvrirVendre(tester);
    await _toucher(tester, find.text('Riz'));
    await _toucher(tester, find.text('Riz'));
    await _toucher(tester, find.text('Encaisser'));
    await _toucher(tester, find.text('Crédit'));

    // Sans client : l'écran dit quoi faire.
    await _toucher(tester, find.text('Vendre à crédit'));
    expect(
      find.text('Choisissez le client qui prend à crédit.'),
      findsOneWidget,
    );

    await _toucher(tester, find.text('Choisir le client'));
    await _toucher(tester, find.text('Nouveau client'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nom du client'),
      'Maman Brigitte',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Téléphone (facultatif)'),
      '690000001',
    );
    await _toucher(tester, find.text('Ajouter le client'));
    expect(find.text('Maman Brigitte'), findsOneWidget);

    // Avance de 2 000 : reste 5 000.
    for (final touche in ['2', '000']) {
      await _toucher(tester, find.text(touche).last);
    }
    expect(find.text('Reste à payer'), findsOneWidget);
    await _toucher(tester, find.text('Vendre à crédit'));
    expect(find.text('Vente n°1 enregistrée : 7 000 FCFA.'), findsOneWidget);

    final client = await tester.runAsync(
      () => app.db.select(app.db.clients).getSingle(),
    );
    expect(client!.soldeDette, 5000);
    expect(client.telephone, '690000001');
    final vente = await tester.runAsync(
      () => app.db.select(app.db.ventes).getSingle(),
    );
    expect(vente!.modePaiement, ModePaiement.credit);
    expect(vente.resteAPayer, 5000);
    await app.fermer(tester);
  });

  testWidgets('historique puis annulation : stock remis', (tester) async {
    final app = await _demarrer(tester);
    final riz = await app.ajouterProduit(tester, nom: 'Riz', quantite: 10);
    await _ouvrirVendre(tester);
    await _toucher(tester, find.text('Riz'));
    await _toucher(tester, find.text('Encaisser'));
    await _toucher(tester, find.text('Encaisser 3 500 FCFA'));

    await _toucher(tester, find.text('Historique'));
    expect(find.text('Aujourd\'hui'), findsOneWidget);
    expect(find.textContaining('N°1 · '), findsOneWidget);
    await _toucher(tester, find.textContaining('N°1 · '));
    expect(find.text('Vente n°1'), findsOneWidget);

    await _toucher(tester, find.text('Annuler la vente'));
    expect(find.text('Annuler la vente n°1 ?'), findsOneWidget);
    await _toucher(tester, find.text('Annuler la vente').last);
    expect(
      find.text('Vente n°1 annulée. Le stock a été remis.'),
      findsOneWidget,
    );
    expect(find.text('Annulée'), findsOneWidget);
    expect(find.widgetWithText(KassaButton, 'Annuler la vente'), findsNothing);

    final produit = await tester.runAsync(
      () => (app.db.select(
        app.db.produits,
      )..where((p) => p.id.equals(riz))).getSingle(),
    );
    expect(produit!.quantite, 10);
    await app.fermer(tester);
  });

  testWidgets('en anglais : mêmes parcours traduits', (tester) async {
    final app = await _demarrer(tester, langue: 'en');
    await app.ajouterProduit(tester, nom: 'Rice', quantite: 10);
    await tester.tap(find.text('Sell').last);
    await stabiliser(tester);
    await _toucher(tester, find.text('Rice'));
    await _toucher(tester, find.text('Collect payment'));
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Collect 3,500 FCFA'), findsOneWidget);
    await app.fermer(tester);
  });
}
