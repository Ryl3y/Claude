import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/kassa_database.dart';
import '../../data/providers.dart';
import '../../domain/calculs.dart';

/// Produits non supprimés, mis à jour en direct.
final produitsProvider = StreamProvider<List<Produit>>(
  (ref) => ref.watch(produitsRepositoryProvider).surveillerProduits(),
);

/// Catégories non supprimées, mises à jour en direct.
final categoriesProvider = StreamProvider<List<Categorie>>(
  (ref) => ref.watch(produitsRepositoryProvider).surveillerCategories(),
);

/// Nombre de produits au seuil d'alerte ou en dessous (pastille de l'onglet Stock).
final alertesStockProvider = Provider<int>((ref) {
  final produits = ref.watch(produitsProvider).value ?? const <Produit>[];
  return produits
      .where(
        (p) => Calculs.stockBas(quantite: p.quantite, seuil: p.seuilAlerte),
      )
      .length;
});
