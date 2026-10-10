import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/db/tables.dart';

/// Base en mémoire, recréée pour chaque test.
KassaDatabase baseEnMemoire() => KassaDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

final maintenant = DateTime.utc(2026, 10, 10, 9);
const appareil = 'appareil-test';

String uuid(int n) => '00000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';

/// Jeu de données minimal : une boutique, son propriétaire,
/// une catégorie, un produit et un client.
class Donnees {
  static final boutiqueId = uuid(1);
  static final utilisateurId = uuid(2);
  static final categorieId = uuid(3);
  static final produitId = uuid(4);
  static final clientId = uuid(5);

  static Future<void> inserer(KassaDatabase db) async {
    await db.into(db.boutiques).insert(BoutiquesCompanion.insert(
          id: boutiqueId,
          nom: 'Chez Maman Brigitte',
          telephone: '237690000000',
          ville: 'Douala',
          quartier: 'Akwa',
          typeCommerce: 'alimentation',
          seuilAlerteDefaut: 5,
          creeLe: maintenant,
          majLe: maintenant,
          appareilId: appareil,
        ));
    await db.into(db.utilisateurs).insert(UtilisateursCompanion.insert(
          id: utilisateurId,
          boutiqueId: boutiqueId,
          nom: 'Brigitte',
          telephone: '237690000000',
          codePin: 'hache',
          majLe: maintenant,
          appareilId: appareil,
        ));
    await db.into(db.categories).insert(CategoriesCompanion.insert(
          id: categorieId,
          nom: 'Épicerie',
          icone: 'grocery',
          majLe: maintenant,
          appareilId: appareil,
        ));
    await db.into(db.produits).insert(ProduitsCompanion.insert(
          id: produitId,
          categorieId: Value(categorieId),
          nom: 'Riz 5 kg',
          prixAchat: 3000,
          prixVente: 3500,
          unite: 'sac',
          seuilAlerte: 2,
          majLe: maintenant,
          appareilId: appareil,
        ));
    await db.into(db.clients).insert(ClientsCompanion.insert(
          id: clientId,
          nom: 'Maman Brigitte',
          telephone: const Value('237690000001'),
          majLe: maintenant,
          appareilId: appareil,
        ));
  }

  static Future<void> mouvement(KassaDatabase db, int n, double quantite,
      {String type = TypeMouvement.entree, DateTime? supprimeLe, String? reference}) {
    return db.into(db.mouvementsStock).insert(MouvementsStockCompanion.insert(
          id: uuid(100 + n),
          produitId: produitId,
          type: type,
          quantite: quantite,
          referenceId: Value(reference),
          dateMouvement: maintenant,
          majLe: maintenant,
          supprimeLe: Value(supprimeLe),
          appareilId: appareil,
        ));
  }

  static Future<void> vente(KassaDatabase db, int n,
      {required int total,
      required int paye,
      String mode = ModePaiement.credit,
      bool annulee = false,
      String? clientId}) {
    return db.into(db.ventes).insert(VentesCompanion.insert(
          id: uuid(200 + n),
          numero: n,
          clientId: Value(clientId ?? Donnees.clientId),
          utilisateurId: utilisateurId,
          total: total,
          montantPaye: paye,
          resteAPayer: total - paye,
          modePaiement: mode,
          benefice: 0,
          dateVente: maintenant,
          annulee: Value(annulee),
          majLe: maintenant,
          appareilId: appareil,
        ));
  }

  static Future<void> versement(KassaDatabase db, int n, int montant, {DateTime? supprimeLe}) {
    return db.into(db.versementsDette).insert(VersementsDetteCompanion.insert(
          id: uuid(300 + n),
          clientId: clientId,
          montant: montant,
          modePaiement: ModePaiement.especes,
          dateVersement: maintenant,
          majLe: maintenant,
          supprimeLe: Value(supprimeLe),
          appareilId: appareil,
        ));
  }
}
