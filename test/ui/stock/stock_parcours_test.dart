// Parcours de l'étape 4 : liste du stock, ajout, modification, réappro,
// suppression, filtres et recherche — tout hors ligne, sur une base en mémoire.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/db/tables.dart';
import 'package:kassa/ui/screens/stock/stock_screen.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';

/// Saisit du texte dans le champ qui porte ce libellé (en le faisant défiler).
Future<void> saisir(WidgetTester tester, String libelle, String texte) async {
  final champ = find.widgetWithText(TextFormField, libelle);
  await tester.ensureVisible(champ);
  await tester.pump();
  await tester.enterText(champ, texte);
  await tester.pump();
}

void main() {
  setUpAll(preparerTestsWidgets);

  Future<AppDeTest> demarrer(
    WidgetTester tester, {
    String langue = 'fr',
  }) async {
    tester.view.physicalSize = const Size(412 * 3, 915 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final app = await AppDeTest.creer(langue: langue);
    await tester.pumpWidget(app.widget);
    await stabiliser(tester);
    return app;
  }

  testWidgets('stock vide : message qui dit quoi faire', (tester) async {
    final app = await demarrer(tester);
    await ouvrirStock(tester);
    expect(find.text('Aucun produit pour l\'instant'), findsOneWidget);
    expect(find.text('Ajouter un produit'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('ajouter un produit : il apparaît dans la liste avec son stock', (
    tester,
  ) async {
    final app = await demarrer(tester);
    await ouvrirStock(tester);
    await tester.tap(find.text('Ajouter un produit'));
    await stabiliser(tester);
    expect(find.text('Nouveau produit'), findsOneWidget);

    await saisir(tester, 'Nom du produit', 'Savon Azur');
    await saisir(tester, 'Prix d\'achat', '200');
    await saisir(tester, 'Prix de vente', '250');
    await saisir(tester, 'Quantité en stock', '40');
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'pièce'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'pièce'));
    await stabiliser(tester);
    await tester.tap(find.text('Ajouter un produit'));
    await stabiliser(tester);

    expect(find.text('Produit ajouté.'), findsOneWidget);
    expect(find.text('Savon Azur'), findsOneWidget);
    expect(find.text('Stock : 40 pièce'), findsOneWidget);
    final mouvements = await tester.runAsync(
      () => app.db.select(app.db.mouvementsStock).get(),
    );
    expect(mouvements!.single.type, TypeMouvement.entree);
    await app.fermer(tester);
  });

  testWidgets('formulaire incomplet : chaque champ dit quoi corriger', (
    tester,
  ) async {
    final app = await demarrer(tester);
    await ouvrirStock(tester);
    await tester.tap(find.text('Ajouter un produit'));
    await stabiliser(tester);
    await tester.tap(find.text('Ajouter un produit'));
    await stabiliser(tester);
    expect(find.text('Saisissez le nom du produit.'), findsOneWidget);
    expect(
      find.text('Saisissez un prix en francs, sans virgule.'),
      findsNWidgets(2),
    );
    expect(find.text('Choisissez ou saisissez une unité.'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('vente à perte : avertissement non bloquant', (tester) async {
    final app = await demarrer(tester);
    await ouvrirStock(tester);
    await tester.tap(find.text('Ajouter un produit'));
    await stabiliser(tester);
    await saisir(tester, 'Prix d\'achat', '1000');
    await saisir(tester, 'Prix de vente', '800');
    await stabiliser(tester);
    expect(
      find.textContaining('vous perdez 200 FCFA par unité'),
      findsOneWidget,
    );
    await app.fermer(tester);
  });

  testWidgets(
    'parcours réappro : quantité reçue + nouveau prix → mouvement entree',
    (tester) async {
      final app = await demarrer(tester);
      final id = await app.ajouterProduit(
        tester,
        nom: 'Riz 5 kg',
        quantite: 2,
        seuil: 3,
      );
      await ouvrirStock(tester);

      expect(find.text('Stock : 2 sacs'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LigneStock),
          matching: find.text('Stock bas'),
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(LigneStock),
          matching: find.text('Réappro'),
        ),
      );
      await stabiliser(tester);
      expect(find.text('Stock actuel : 2 sacs'), findsOneWidget);

      await saisir(tester, 'Quantité reçue', '10');
      await saisir(tester, 'Prix d\'achat', '3200');
      await stabiliser(tester);
      expect(find.text('Nouveau stock : 12 sacs'), findsOneWidget);

      await tester.tap(find.text('Ajouter au stock'));
      await stabiliser(tester);

      expect(find.text('Stock mis à jour : 12 sacs.'), findsOneWidget);
      expect(find.text('Stock : 12 sacs'), findsOneWidget);
      final produit = await tester.runAsync(
        () => (app.db.select(
          app.db.produits,
        )..where((p) => p.id.equals(id))).getSingle(),
      );
      expect(produit!.quantite, 12);
      expect(produit.prixAchat, 3200);
      final mouvements = await tester.runAsync(
        () => app.db.select(app.db.mouvementsStock).get(),
      );
      expect(mouvements!.last.type, TypeMouvement.entree);
      expect(mouvements.last.quantite, 10);
      expect(mouvements.last.prixAchatUnitaire, 3200);
      await app.fermer(tester);
    },
  );

  testWidgets('réappro sans produit choisi : on choisit dans la liste', (
    tester,
  ) async {
    final app = await demarrer(tester);
    await app.ajouterProduit(tester, nom: 'Huile 1 L', unite: 'bouteilles');
    await ouvrirStock(tester);
    await tester.tap(
      find.descendant(of: find.byType(AppBar), matching: find.text('Réappro')),
    );
    await stabiliser(tester);
    expect(find.text('Choisissez le produit reçu.'), findsOneWidget);
    await tester.tap(find.text('Huile 1 L'));
    await stabiliser(tester);
    expect(find.text('Stock actuel : 10 bouteilles'), findsOneWidget);
    await tester.tap(find.text('Ajouter au stock'));
    await stabiliser(tester);
    expect(
      find.text('Saisissez la quantité reçue, plus grande que 0.'),
      findsOneWidget,
    );
    await app.fermer(tester);
  });

  testWidgets('modifier la quantité : correction enregistrée', (tester) async {
    final app = await demarrer(tester);
    await app.ajouterProduit(
      tester,
      nom: 'Sucre en vrac',
      unite: 'kg',
      quantite: 5,
    );
    await ouvrirStock(tester);
    await tester.tap(find.text('Sucre en vrac'));
    await stabiliser(tester);
    expect(find.text('Modifier le produit'), findsOneWidget);
    await saisir(tester, 'Quantité en stock', '3,5');
    await tester.tap(find.text('Enregistrer'));
    await stabiliser(tester);
    expect(find.text('Modifications enregistrées.'), findsOneWidget);
    expect(find.text('Stock : 3,5 kg'), findsOneWidget);
    final mouvements = await tester.runAsync(
      () => app.db.select(app.db.mouvementsStock).get(),
    );
    expect(mouvements!.last.type, TypeMouvement.correction);
    expect(mouvements.last.quantite, -1.5);
    await app.fermer(tester);
  });

  testWidgets(
    'supprimer un produit : confirmation, puis disparition de la liste',
    (tester) async {
      final app = await demarrer(tester);
      await app.ajouterProduit(tester, nom: 'Spaghetti');
      await ouvrirStock(tester);
      await tester.tap(find.text('Spaghetti'));
      await stabiliser(tester);
      await tester.scrollUntilVisible(
        find.text('Supprimer le produit'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pump();
      await tester.tap(find.text('Supprimer le produit'));
      await stabiliser(tester);
      expect(find.text('Supprimer Spaghetti ?'), findsOneWidget);
      await tester.tap(find.text('Garder'));
      await stabiliser(tester);
      await tester.tap(find.text('Supprimer le produit'));
      await stabiliser(tester);
      await tester.tap(find.text('Supprimer'));
      await stabiliser(tester);
      expect(find.text('Spaghetti a été supprimé.'), findsOneWidget);
      expect(find.widgetWithText(LigneStock, 'Spaghetti'), findsNothing);
      await app.fermer(tester);
    },
  );

  testWidgets(
    'filtre stock bas, recherche sans accents, pastille de l\'onglet',
    (tester) async {
      final app = await demarrer(tester);
      await app.ajouterProduit(tester, nom: 'Épices', quantite: 1, seuil: 2);
      await app.ajouterProduit(tester, nom: 'Riz', quantite: 20, seuil: 2);
      await ouvrirStock(tester);

      expect(find.text('1'), findsOneWidget); // pastille or de l'onglet Stock
      await tester.tap(find.text('Stock bas (1)'));
      await stabiliser(tester);
      expect(find.widgetWithText(LigneStock, 'Épices'), findsOneWidget);
      expect(find.widgetWithText(LigneStock, 'Riz'), findsNothing);

      await tester.tap(find.text('Tous'));
      await tester.enterText(find.byType(TextField).first, 'epi');
      await stabiliser(tester);
      expect(find.widgetWithText(LigneStock, 'Épices'), findsOneWidget);
      expect(find.widgetWithText(LigneStock, 'Riz'), findsNothing);

      await tester.enterText(find.byType(TextField).first, 'xyz');
      await stabiliser(tester);
      expect(
        find.textContaining('Aucun produit ne correspond à « xyz »'),
        findsOneWidget,
      );
      await app.fermer(tester);
    },
  );

  testWidgets('en anglais : mêmes écrans traduits', (tester) async {
    final app = await demarrer(tester, langue: 'en');
    await app.ajouterProduit(tester, nom: 'Rice', quantite: 1.5, unite: 'kg');
    await tester.tap(find.text('Stock').last);
    await stabiliser(tester);
    expect(find.text('Stock: 1.5 kg'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LigneStock),
        matching: find.text('Low stock'),
      ),
      findsOneWidget,
    );
    expect(find.text('Add product'), findsOneWidget);
    expect(find.text('Restock'), findsWidgets);
    await app.fermer(tester);
  });
}
