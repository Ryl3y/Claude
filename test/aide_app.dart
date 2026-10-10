import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/app.dart';
import 'package:kassa/data/db/champs_synchro.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/preferences/preferences_locales.dart';
import 'package:kassa/data/providers.dart';
import 'package:kassa/data/repositories/produits_repository.dart';
import 'package:kassa/domain/produit_saisie.dart';
import 'package:kassa/ui/state/langue.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/aide_base.dart';

/// L'app Kassa complète sur une base en mémoire.
class AppDeTest {
  AppDeTest._(this.db, this.widget);

  final KassaDatabase db;
  final Widget widget;

  ProduitsRepository get produits =>
      ProduitsRepository(db, ChampsSynchro(appareilId: 'tel-test'));

  static Future<AppDeTest> creer({String langue = 'fr'}) async {
    SharedPreferences.setMockInitialValues({'langue': langue});
    final prefs = await PreferencesLocales.ouvrir();
    final db = baseEnMemoire();
    return AppDeTest._(
      db,
      ProviderScope(
        overrides: [
          preferencesLocalesProvider.overrideWithValue(prefs),
          appareilIdProvider.overrideWithValue('tel-test'),
          kassaDatabaseProvider.overrideWithValue(db),
        ],
        child: const KassaApp(),
      ),
    );
  }

  /// Ajoute un produit directement en base.
  Future<String> ajouterProduit(
    WidgetTester tester, {
    required String nom,
    double quantite = 10,
    double seuil = 3,
    int prixAchat = 3000,
    int prixVente = 3500,
    String unite = 'sacs',
    String? categorieId,
  }) async {
    final id = await tester.runAsync(
      () => produits.creerProduit(
        ProduitSaisie(
          nom: nom,
          categorieId: categorieId,
          prixAchat: prixAchat,
          prixVente: prixVente,
          quantite: quantite,
          unite: unite,
          seuilAlerte: seuil,
        ),
      ),
    );
    await stabiliser(tester);
    return id!;
  }

  /// Ferme la base à la fin du test.
  Future<void> fermer(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(db.close);
  }
}

/// Laisse la base (vraie attente) et les animations (temps simulé) avancer.
/// Remplace pumpAndSettle, qui ne voit pas les requêtes drift et ne se
/// termine jamais avec un curseur qui clignote ou un indicateur de chargement.
Future<void> stabiliser(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Va sur l'onglet Stock.
Future<void> ouvrirStock(WidgetTester tester) async {
  await tester.tap(find.text('Stock').last);
  await stabiliser(tester);
}
