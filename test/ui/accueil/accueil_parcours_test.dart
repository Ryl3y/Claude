// Parcours de l'étape 7, hors ligne sur une base en mémoire : accueil au
// premier lancement, chiffres du jour après des ventes, stock bas,
// « Nouvelle vente », état de la sauvegarde, rapports et périodes.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/core/heure_douala.dart';
import 'package:kassa/ui/widgets/widgets.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';

const _e = ' ';

Future<AppDeTest> _demarrer(WidgetTester tester) async {
  tester.view.physicalSize = const Size(412 * 3, 915 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final app = await AppDeTest.creer();
  await tester.pumpWidget(app.widget);
  await stabiliser(tester);
  return app;
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
    // Samedi 10 octobre 2026, 10 h 18 à Douala.
    HeureDouala.horloge = () => DateTime.utc(2026, 10, 10, 9, 18);
  });
  tearDownAll(() => HeureDouala.horloge = DateTime.now);

  testWidgets('premier lancement : invitation à ajouter des produits', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    expect(find.text('Samedi 10 octobre'), findsOneWidget);
    expect(find.text('Sur ce téléphone'), findsOneWidget);
    expect(find.text('Ventes du jour'), findsOneWidget);
    expect(find.text('Aucune vente · bénéfice 0${_e}F'), findsOneWidget);
    expect(find.text('Ajoutez vos produits pour commencer'), findsOneWidget);

    await _toucher(tester, find.text('Ajouter un produit'));
    expect(find.text('Nom du produit'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('chiffres du jour après une vente comptant et un crédit', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    final riz = await app.ajouterProduit(
      tester,
      nom: 'Riz',
      prixAchat: 3000,
      prixVente: 3500,
    );
    final awa = await app.ajouterClient(tester, nom: 'Awa');
    await app.vendreComptant(tester, produitId: riz, quantite: 2);
    await app.vendreACredit(tester, clientId: awa, produitId: riz);

    expect(find.text('Ajoutez vos produits pour commencer'), findsNothing);
    expect(find.text('10${_e}500${_e}FCFA'), findsOneWidget);
    expect(find.text('2 ventes · bénéfice 1${_e}500${_e}F'), findsOneWidget);
    expect(find.text('Doit${_e}3${_e}500${_e}FCFA'), findsOneWidget);
    expect(find.text('1 client'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('stock bas : alerte, puis « Voir le stock » filtré', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    await app.ajouterProduit(tester, nom: 'Riz', quantite: 20, seuil: 3);
    await app.ajouterProduit(
      tester,
      nom: 'Huile',
      quantite: 2,
      seuil: 4,
      unite: 'bouteilles',
    );
    expect(find.text('1 produit en stock bas'), findsOneWidget);
    expect(find.text('2 bouteilles'), findsOneWidget);

    await _toucher(tester, find.text('Voir le stock'));
    expect(find.text('Huile'), findsOneWidget);
    expect(find.text('Riz'), findsNothing);
    await app.fermer(tester);
  });

  testWidgets('« Nouvelle vente » ouvre l\'onglet Vendre', (tester) async {
    final app = await _demarrer(tester);
    await app.ajouterProduit(tester, nom: 'Riz');
    await _toucher(tester, find.widgetWithText(KassaButton, 'Nouvelle vente'));
    expect(find.text('Rechercher un produit'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('état de la sauvegarde : un toucher explique', (tester) async {
    final app = await _demarrer(tester);
    await tester.tap(find.text('Sur ce téléphone'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.textContaining('Vos données sont enregistrées sur ce téléphone.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 7));
    await app.fermer(tester);
  });

  testWidgets('rapports : jour, semaine, périodes passées, mois', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    final riz = await app.ajouterProduit(
      tester,
      nom: 'Riz',
      prixAchat: 3000,
      prixVente: 3500,
      unite: 'sacs',
    );
    await app.vendreComptant(tester, produitId: riz, quantite: 3);

    await _toucher(tester, find.text('Rapports'));
    expect(find.text('Aujourd\'hui'), findsOneWidget);
    expect(find.text('10${_e}500${_e}FCFA'), findsWidgets);
    expect(
      find.text('3 sacs vendus · bénéfice 1${_e}500${_e}F'),
      findsOneWidget,
    );
    final apres = find.widgetWithText(TextButton, 'Après');
    expect(tester.widget<TextButton>(apres).onPressed, isNull);

    await _toucher(tester, find.text('Semaine'));
    expect(find.text('Cette semaine'), findsOneWidget);
    await _toucher(tester, find.text('Avant'));
    expect(find.text('La semaine dernière'), findsOneWidget);
    expect(find.text('Aucune vente sur cette période.'), findsOneWidget);
    await _toucher(tester, find.text('Avant'));
    expect(find.text('Du 21 sept. au 27 sept.'), findsOneWidget);
    await _toucher(tester, find.text('Après'));
    await _toucher(tester, find.text('Après'));
    expect(find.text('Cette semaine'), findsOneWidget);

    await _toucher(tester, find.text('Mois'));
    expect(find.text('Ce mois-ci'), findsOneWidget);
    await _toucher(tester, find.text('Avant'));
    await _toucher(tester, find.text('Avant'));
    expect(find.text('Août 2026'), findsOneWidget);
    await app.fermer(tester);
  });
}
