import 'package:drift/drift.dart';

import '../../core/heure_douala.dart';
import '../../core/identifiant.dart';
import '../../domain/panier.dart';
import '../db/champs_synchro.dart';
import '../db/kassa_database.dart';
import '../db/tables.dart';

/// Une vente avec ses lignes et son client (historique, détail).
class VenteDetaillee {
  const VenteDetaillee({
    required this.vente,
    required this.lignes,
    this.client,
  });

  final Vente vente;
  final List<LigneVente> lignes;
  final Client? client;
}

/// Ventes, lignes, mouvements « vente » et « annulation » (écrans 6, 7, 8).
class VentesRepository {
  VentesRepository(this._db, this._champs);

  final KassaDatabase _db;
  final ChampsSynchro _champs;

  static String codeMode(ModeChoisi mode) => switch (mode) {
    ModeChoisi.especes => ModePaiement.especes,
    ModeChoisi.momo => ModePaiement.momo,
    ModeChoisi.orangeMoney => ModePaiement.orangeMoney,
    ModeChoisi.credit => ModePaiement.credit,
  };

  /// Enregistre une vente : vente + lignes (nom et prix copiés) + mouvements
  /// « vente » + stock recalculé ; à crédit, la dette du client est
  /// recalculée. Tout ou rien (une seule transaction). Renvoie la vente.
  Future<Vente> enregistrerVente({
    required Panier panier,
    required ModeChoisi mode,
    required CalculPaiement paiement,
    required String utilisateurId,
    String? clientId,
  }) {
    if (panier.estVide) throw ArgumentError('Panier vide');
    if (mode == ModeChoisi.credit && clientId == null) {
      throw ArgumentError('Une vente à crédit demande un client');
    }
    if (mode == ModeChoisi.especes && paiement.manque > 0) {
      throw ArgumentError('Montant reçu insuffisant');
    }
    return _db.transaction(() async {
      final instant = _champs.maintenant();
      final venteId = Identifiant.nouveau();
      await _db
          .into(_db.ventes)
          .insert(
            VentesCompanion.insert(
              id: venteId,
              numero: await _numeroDuJour(instant),
              clientId: Value(clientId),
              utilisateurId: utilisateurId,
              total: panier.total,
              montantPaye: paiement.montantPaye,
              resteAPayer: paiement.resteAPayer,
              modePaiement: codeMode(mode),
              benefice: panier.benefice,
              dateVente: instant,
              majLe: instant,
              appareilId: _champs.appareilId,
            ),
          );
      for (final l in panier.lignes) {
        await _db
            .into(_db.lignesVente)
            .insert(
              LignesVenteCompanion.insert(
                id: Identifiant.nouveau(),
                venteId: venteId,
                produitId: l.produitId,
                nomProduit: l.nom,
                quantite: l.quantite,
                prixUnitaire: l.prixUnitaire,
                prixAchatUnitaire: l.prixAchatUnitaire,
                majLe: instant,
                appareilId: _champs.appareilId,
              ),
            );
        await _mouvement(
          produitId: l.produitId,
          type: TypeMouvement.vente,
          quantite: -l.quantite,
          venteId: venteId,
          instant: instant,
        );
        await _db.recalculerStock(l.produitId);
      }
      if (clientId != null) await _db.recalculerSoldeDette(clientId);
      return (_db.select(
        _db.ventes,
      )..where((v) => v.id.equals(venteId))).getSingle();
    });
  }

  /// Annule une vente : le stock est remis (mouvements « annulation ») et la
  /// dette du client recalculée. Une vente déjà annulée est refusée.
  Future<void> annulerVente(String venteId) => _db.transaction(() async {
    final vente =
        await (_db.select(_db.ventes)
              ..where((v) => v.id.equals(venteId) & v.supprimeLe.isNull()))
            .getSingleOrNull();
    if (vente == null) throw StateError('Vente introuvable : $venteId');
    if (vente.annulee) throw StateError('Vente déjà annulée : $venteId');
    final instant = _champs.maintenant();
    await (_db.update(_db.ventes)..where((v) => v.id.equals(venteId))).write(
      VentesCompanion(
        annulee: const Value(true),
        majLe: Value(instant),
        synchro: const Value(false),
        appareilId: Value(_champs.appareilId),
      ),
    );
    final lignes = await (_db.select(
      _db.lignesVente,
    )..where((l) => l.venteId.equals(venteId) & l.supprimeLe.isNull())).get();
    for (final l in lignes) {
      await _mouvement(
        produitId: l.produitId,
        type: TypeMouvement.annulation,
        quantite: l.quantite,
        venteId: venteId,
        instant: instant,
      );
      await _db.recalculerStock(l.produitId);
    }
    if (vente.clientId != null) {
      await _db.recalculerSoldeDette(vente.clientId!);
    }
  });

  /// Ventes entre deux instants UTC (non supprimées), les plus récentes d'abord.
  Stream<List<Vente>> surveillerVentes({DateTime? depuis, DateTime? jusqua}) {
    final requete = _db.select(_db.ventes)
      ..where((v) {
        Expression<bool> e = v.supprimeLe.isNull();
        if (depuis != null) e = e & v.dateVente.isBiggerOrEqualValue(depuis);
        if (jusqua != null) e = e & v.dateVente.isSmallerThanValue(jusqua);
        return e;
      })
      ..orderBy([(v) => OrderingTerm.desc(v.dateVente)]);
    return requete.watch();
  }

  /// Une vente avec ses lignes et son client.
  Stream<VenteDetaillee?> surveillerVente(String id) {
    final vente = (_db.select(
      _db.ventes,
    )..where((v) => v.id.equals(id))).watchSingleOrNull();
    return vente.asyncMap((v) async {
      if (v == null) return null;
      final lignes = await (_db.select(
        _db.lignesVente,
      )..where((l) => l.venteId.equals(id) & l.supprimeLe.isNull())).get();
      final client = v.clientId == null
          ? null
          : await (_db.select(
              _db.clients,
            )..where((c) => c.id.equals(v.clientId!))).getSingleOrNull();
      return VenteDetaillee(vente: v, lignes: lignes, client: client);
    });
  }

  /// Numéro lisible : rang de la vente dans la journée (heure de Douala),
  /// annulées comprises, pour que les numéros ne changent jamais.
  Future<int> _numeroDuJour(DateTime instant) async {
    final debut = HeureDouala.debutDuJourUtc(instant);
    final fin = debut.add(const Duration(days: 1));
    final nombre = _db.ventes.id.count();
    final requete = _db.selectOnly(_db.ventes)
      ..addColumns([nombre])
      ..where(
        _db.ventes.dateVente.isBiggerOrEqualValue(debut) &
            _db.ventes.dateVente.isSmallerThanValue(fin),
      );
    return (await requete.map((r) => r.read(nombre)).getSingle() ?? 0) + 1;
  }

  Future<void> _mouvement({
    required String produitId,
    required String type,
    required double quantite,
    required String venteId,
    required DateTime instant,
  }) => _db
      .into(_db.mouvementsStock)
      .insert(
        MouvementsStockCompanion.insert(
          id: Identifiant.nouveau(),
          produitId: produitId,
          type: type,
          quantite: quantite,
          referenceId: Value(venteId),
          dateMouvement: instant,
          majLe: instant,
          appareilId: _champs.appareilId,
        ),
      );
}
