import 'package:drift/drift.dart';

import '../../core/identifiant.dart';
import '../../domain/calculs.dart';
import '../../domain/produit_saisie.dart';
import '../db/champs_synchro.dart';
import '../db/kassa_database.dart';
import '../db/tables.dart';

/// Produits, catégories et mouvements de stock (écrans 9, 10, 11).
///
/// Chaque écriture passe par [ChampsSynchro] (maj_le, synchro = false,
/// appareil_id). Le stock n'est jamais saisi directement : il est recalculé
/// depuis mouvements_stock après chaque mouvement.
class ProduitsRepository {
  ProduitsRepository(this._db, this._champs);

  final KassaDatabase _db;
  final ChampsSynchro _champs;

  // ---------------------------------------------------------------- Lecture

  /// Produits non supprimés, par ordre alphabétique.
  Stream<List<Produit>> surveillerProduits() =>
      (_db.select(_db.produits)
            ..where((p) => p.supprimeLe.isNull())
            ..orderBy([(p) => OrderingTerm.asc(p.nom.collate(Collate.noCase))]))
          .watch();

  /// Un produit (null s'il n'existe pas ou a été supprimé).
  Stream<Produit?> surveillerProduit(String id) => (_db.select(
    _db.produits,
  )..where((p) => p.id.equals(id) & p.supprimeLe.isNull())).watchSingleOrNull();

  /// Catégories non supprimées, par ordre alphabétique.
  Stream<List<Categorie>> surveillerCategories() =>
      (_db.select(_db.categories)
            ..where((c) => c.supprimeLe.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.nom.collate(Collate.noCase))]))
          .watch();

  /// Seuil d'alerte par défaut de la boutique (5 si aucune boutique).
  Future<double> seuilParDefaut() async {
    final boutique =
        await (_db.select(_db.boutiques)
              ..where((b) => b.supprimeLe.isNull())
              ..limit(1))
            .getSingleOrNull();
    return (boutique?.seuilAlerteDefaut ?? ReglesProduit.seuilAlerteParDefaut)
        .toDouble();
  }

  // ------------------------------------------------------------- Catégories

  Future<String> creerCategorie({
    required String nom,
    required String icone,
  }) async {
    final propre = nom.trim();
    if (propre.isEmpty) throw ArgumentError.value(nom, 'nom', 'vide');
    final id = Identifiant.nouveau();
    await _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: id,
            nom: propre,
            icone: icone,
            majLe: _champs.maintenant(),
            appareilId: _champs.appareilId,
          ),
        );
    return id;
  }

  // --------------------------------------------------------------- Produits

  /// Crée un produit. Une quantité de départ crée un mouvement « entree ».
  Future<String> creerProduit(ProduitSaisie s) {
    _verifier(s);
    return _db.transaction(() async {
      final id = Identifiant.nouveau();
      final instant = _champs.maintenant();
      await _db
          .into(_db.produits)
          .insert(
            ProduitsCompanion.insert(
              id: id,
              categorieId: Value(s.categorieId),
              nom: s.nom.trim(),
              prixAchat: s.prixAchat,
              prixVente: s.prixVente,
              unite: s.unite.trim(),
              seuilAlerte: s.seuilAlerte,
              photoLocale: Value(s.photoLocale),
              codeBarre: Value(s.codeBarre),
              majLe: instant,
              appareilId: _champs.appareilId,
            ),
          );
      if (s.quantite > 0) {
        await _mouvement(
          produitId: id,
          type: TypeMouvement.entree,
          quantite: s.quantite,
          prixAchat: s.prixAchat,
          instant: instant,
        );
      }
      await _db.recalculerStock(id);
      return id;
    });
  }

  /// Modifie un produit. [quantiteAffichee] est le stock montré à
  /// l'utilisateur à l'ouverture du formulaire : s'il l'a changé, un
  /// mouvement « correction » enregistre son écart. Un mouvement fait entre
  /// temps (réappro, vente sur un autre téléphone) n'est donc jamais annulé.
  Future<void> modifierProduit(
    String id,
    ProduitSaisie s, {
    required double quantiteAffichee,
  }) {
    _verifier(s, creation: false);
    return _db.transaction(() async {
      final instant = _champs.maintenant();
      final modifies =
          await (_db.update(
            _db.produits,
          )..where((p) => p.id.equals(id) & p.supprimeLe.isNull())).write(
            ProduitsCompanion(
              categorieId: Value(s.categorieId),
              nom: Value(s.nom.trim()),
              prixAchat: Value(s.prixAchat),
              prixVente: Value(s.prixVente),
              unite: Value(s.unite.trim()),
              seuilAlerte: Value(s.seuilAlerte),
              photoLocale: Value(s.photoLocale),
              codeBarre: Value(s.codeBarre),
              majLe: Value(instant),
              synchro: const Value(false),
              appareilId: Value(_champs.appareilId),
            ),
          );
      if (modifies == 0) throw StateError('Produit introuvable : $id');

      final ecart = Calculs.arrondirQuantite(s.quantite - quantiteAffichee);
      if (ecart != 0) {
        await _mouvement(
          produitId: id,
          type: TypeMouvement.correction,
          quantite: ecart,
          instant: instant,
        );
      }
      await _db.recalculerStock(id);
    });
  }

  /// Suppression logique : le produit n'est plus proposé, l'historique reste.
  /// Renvoie le chemin de la photo du produit (à effacer du téléphone).
  Future<String?> supprimerProduit(String id) async {
    final produit = await (_db.select(
      _db.produits,
    )..where((p) => p.id.equals(id) & p.supprimeLe.isNull())).getSingleOrNull();
    if (produit == null) throw StateError('Produit introuvable : $id');
    final suppression = _champs.suppression();
    await (_db.update(_db.produits)..where((p) => p.id.equals(id))).write(
      ProduitsCompanion(
        supprimeLe: suppression.supprimeLe,
        majLe: suppression.majLe,
        synchro: const Value(false),
        appareilId: Value(_champs.appareilId),
      ),
    );
    return produit.photoLocale;
  }

  /// Réappro : mouvement « entree » au prix d'achat donné. Un nouveau prix
  /// d'achat met aussi à jour le produit. Renvoie le nouveau stock.
  Future<double> reapprovisionner({
    required String produitId,
    required double quantite,
    int? nouveauPrixAchat,
  }) {
    if (quantite <= 0) {
      throw ArgumentError.value(quantite, 'quantite', 'doit être > 0');
    }
    if (nouveauPrixAchat != null && nouveauPrixAchat < 0) {
      throw ArgumentError.value(nouveauPrixAchat, 'nouveauPrixAchat');
    }
    return _db.transaction(() async {
      final produit =
          await (_db.select(_db.produits)
                ..where((p) => p.id.equals(produitId) & p.supprimeLe.isNull()))
              .getSingle();
      final instant = _champs.maintenant();
      final prix = nouveauPrixAchat ?? produit.prixAchat;
      await _mouvement(
        produitId: produitId,
        type: TypeMouvement.entree,
        quantite: quantite,
        prixAchat: prix,
        instant: instant,
      );
      if (prix != produit.prixAchat) {
        await (_db.update(
          _db.produits,
        )..where((p) => p.id.equals(produitId))).write(
          ProduitsCompanion(
            prixAchat: Value(prix),
            majLe: Value(instant),
            synchro: const Value(false),
            appareilId: Value(_champs.appareilId),
          ),
        );
      }
      return _db.recalculerStock(produitId);
    });
  }

  // ---------------------------------------------------------------- Interne

  void _verifier(ProduitSaisie s, {bool creation = true}) {
    final erreurs = ReglesProduit.verifier(s, creation: creation);
    if (erreurs.isNotEmpty) throw ArgumentError(erreurs.join(', '));
  }

  Future<void> _mouvement({
    required String produitId,
    required String type,
    required double quantite,
    required DateTime instant,
    int? prixAchat,
  }) => _db
      .into(_db.mouvementsStock)
      .insert(
        MouvementsStockCompanion.insert(
          id: Identifiant.nouveau(),
          produitId: produitId,
          type: type,
          quantite: quantite,
          prixAchatUnitaire: Value(prixAchat),
          dateMouvement: instant,
          majLe: instant,
          appareilId: _champs.appareilId,
        ),
      );
}
