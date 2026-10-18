import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/calculs.dart';
import 'tables.dart';

part 'kassa_database.g.dart';

/// Base locale SQLite (drift) : la source principale des données.
/// Tout s'écrit d'abord ici ; la synchronisation envoie ensuite vers Supabase.
@DriftDatabase(
  tables: [
    Boutiques,
    Utilisateurs,
    Categories,
    Produits,
    Clients,
    Ventes,
    LignesVente,
    VersementsDette,
    MouvementsStock,
  ],
)
class KassaDatabase extends _$KassaDatabase {
  /// Pour les tests : `KassaDatabase(NativeDatabase.memory())`.
  KassaDatabase(super.e);

  /// Base de l'app, dans le dossier des documents du téléphone.
  KassaDatabase.ouvrir() : super(driftDatabase(name: 'kassa'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, de, vers) async {
      // v2 : lieu guidé de la boutique (arrondissement, localité, quartier).
      if (de < 2) {
        await m.addColumn(boutiques, boutiques.arrondissement);
        await m.addColumn(boutiques, boutiques.localiteId);
        await m.addColumn(boutiques, boutiques.quartierId);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Tables dans l'ordre d'envoi vers Supabase (dépendances d'abord).
  /// `utilisateurs` n'y figure pas : le compte est créé en ligne à l'inscription.
  List<TableInfo<Table, Object?>> get ordreSynchro => [
    boutiques,
    categories,
    produits,
    clients,
    ventes,
    lignesVente,
    versementsDette,
    mouvementsStock,
  ];

  // ---------------------------------------------------------------------------
  // Calculs recalculés depuis l'historique (jamais saisis à la main).
  // ---------------------------------------------------------------------------

  /// Stock d'un produit : somme des mouvements non supprimés.
  Future<double> calculerStock(String produitId) async {
    final somme = mouvementsStock.quantite.sum();
    final requete = selectOnly(mouvementsStock)
      ..addColumns([somme])
      ..where(
        mouvementsStock.produitId.equals(produitId) &
            mouvementsStock.supprimeLe.isNull(),
      );
    final resultat = await requete.map((r) => r.read(somme)).getSingle();
    return Calculs.arrondirQuantite(resultat ?? 0);
  }

  /// Dette d'un client : reste à payer des ventes non annulées et non
  /// supprimées − versements non supprimés.
  Future<int> calculerSoldeDette(String clientId) async {
    final restes = ventes.resteAPayer.sum();
    final requeteVentes = selectOnly(ventes)
      ..addColumns([restes])
      ..where(
        ventes.clientId.equals(clientId) &
            ventes.annulee.equals(false) &
            ventes.supprimeLe.isNull(),
      );
    final totalRestes =
        await requeteVentes.map((r) => r.read(restes)).getSingle() ?? 0;

    final montants = versementsDette.montant.sum();
    final requeteVersements = selectOnly(versementsDette)
      ..addColumns([montants])
      ..where(
        versementsDette.clientId.equals(clientId) &
            versementsDette.supprimeLe.isNull(),
      );
    final totalVersements =
        await requeteVersements.map((r) => r.read(montants)).getSingle() ?? 0;

    return Calculs.soldeDette(
      restesAPayer: [totalRestes],
      versements: [totalVersements],
    );
  }

  /// Met à jour `produits.quantite` depuis les mouvements.
  ///
  /// C'est une valeur dérivée : elle ne change ni `maj_le` ni `synchro`,
  /// sinon chaque recalcul déclencherait un nouvel envoi. Chaque téléphone
  /// la recalcule lui-même après une synchronisation.
  Future<double> recalculerStock(String produitId) async {
    final stock = await calculerStock(produitId);
    await (update(produits)..where((p) => p.id.equals(produitId))).write(
      ProduitsCompanion(quantite: Value(stock)),
    );
    return stock;
  }

  /// Met à jour `clients.solde_dette` (valeur dérivée, comme le stock).
  Future<int> recalculerSoldeDette(String clientId) async {
    final solde = await calculerSoldeDette(clientId);
    await (update(clients)..where((c) => c.id.equals(clientId))).write(
      ClientsCompanion(soldeDette: Value(solde)),
    );
    return solde;
  }

  /// Recalcule tous les stocks et toutes les dettes en deux requêtes
  /// (après une synchronisation ou une restauration). Mêmes règles que
  /// [calculerStock] et [calculerSoldeDette].
  Future<void> recalculerTout() => transaction(() async {
    await customUpdate(
      'UPDATE produits SET quantite = ROUND(COALESCE(('
      'SELECT SUM(m.quantite) FROM mouvements_stock m '
      'WHERE m.produit_id = produits.id AND m.supprime_le IS NULL'
      '), 0), 3)',
      updates: {produits},
    );
    await customUpdate(
      'UPDATE clients SET solde_dette = COALESCE(('
      'SELECT SUM(v.reste_a_payer) FROM ventes v '
      'WHERE v.client_id = clients.id AND v.annulee = 0 '
      'AND v.supprime_le IS NULL'
      '), 0) - COALESCE(('
      'SELECT SUM(d.montant) FROM versements_dette d '
      'WHERE d.client_id = clients.id AND d.supprime_le IS NULL'
      '), 0)',
      updates: {clients},
    );
  });
}
