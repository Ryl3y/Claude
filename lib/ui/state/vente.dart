import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/kassa_database.dart';
import '../../data/providers.dart';
import '../../domain/panier.dart';

/// Panier de la vente en cours, partagé entre Nouvelle vente et Paiement.
final panierProvider = NotifierProvider<PanierController, Panier>(
  PanierController.new,
);

class PanierController extends Notifier<Panier> {
  @override
  Panier build() => const Panier();

  /// Ajoute [quantite] du produit (1 par défaut : un toucher sur la carte).
  void ajouter(Produit p, {double quantite = 1}) => state = state.ajouter(
    LignePanier(
      produitId: p.id,
      nom: p.nom,
      unite: p.unite,
      prixUnitaire: p.prixVente,
      prixAchatUnitaire: p.prixAchat,
      quantite: quantite,
      stockDisponible: p.quantite,
    ),
  );

  /// Fixe la quantité (appui long) ; 0 retire le produit.
  void fixer(Produit p, double quantite) {
    if (state.quantiteDe(p.id) == 0) {
      if (quantite > 0) ajouter(p, quantite: quantite);
      return;
    }
    state = state.fixerQuantite(p.id, quantite);
  }

  void changerQuantite(String produitId, double quantite) =>
      state = state.fixerQuantite(produitId, quantite);

  void retirer(String produitId) => state = state.retirer(produitId);

  void remplacer(Panier panier) => state = panier;

  void vider() => state = const Panier();
}

/// Clients non supprimés (choix du client d'une vente à crédit).
final clientsProvider = StreamProvider<List<Client>>(
  (ref) => ref.watch(clientsRepositoryProvider).surveillerClients(),
);
