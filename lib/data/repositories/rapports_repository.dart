import 'package:drift/drift.dart';

import '../../domain/calculs.dart';
import '../../domain/periode.dart';
import '../db/kassa_database.dart';
import '../db/tables.dart';

/// Un produit dans le classement « Meilleurs produits ».
class TopProduit {
  const TopProduit({
    required this.produitId,
    required this.nom,
    required this.unite,
    required this.quantite,
    required this.montant,
    required this.benefice,
  });

  final String produitId;
  final String nom;
  final String unite;
  final double quantite;
  final int montant;
  final int benefice;
}

/// Chiffres d'une période. Les ventes annulées ne comptent pas (sauf
/// [annulees], leur nombre).
class Rapport {
  const Rapport({
    required this.periode,
    required this.nombreVentes,
    required this.total,
    required this.benefice,
    required this.payeSurVentes,
    required this.venduACredit,
    required this.versements,
    required this.parMode,
    required this.top,
    required this.annulees,
  });

  final Periode periode;
  final int nombreVentes;

  /// Total des ventes (comptant et crédit).
  final int total;
  final int benefice;

  /// Argent reçu au moment des ventes (comptant + avances).
  final int payeSurVentes;

  /// Reste à payer des ventes à crédit de la période.
  final int venduACredit;

  /// Dettes encaissées pendant la période (versements).
  final int versements;

  /// Total des ventes par mode de paiement (codes de [ModePaiement]).
  final Map<String, int> parMode;

  /// Meilleurs produits, du plus gros montant vendu au plus petit.
  final List<TopProduit> top;
  final int annulees;

  /// Tout l'argent reçu : ventes + dettes encaissées.
  int get totalEncaisse => payeSurVentes + versements;

  /// Montant moyen d'une vente (0 sans vente).
  int get panierMoyen => nombreVentes == 0 ? 0 : (total / nombreVentes).round();
}

/// Chiffres de l'accueil et des rapports, calculés depuis la base locale.
class RapportsRepository {
  RapportsRepository(this._db);

  final KassaDatabase _db;

  /// Nombre de produits dans le classement.
  static const tailleTop = 5;

  /// Rapport de la période, recalculé dès qu'une vente, une ligne ou un
  /// versement change. Pas sur les produits : le stock est réécrit à chaque
  /// vente et réappro, sans changer les chiffres.
  Stream<Rapport> surveillerRapport(Periode periode) => _db
      .customSelect(
        'SELECT 1',
        readsFrom: {_db.ventes, _db.lignesVente, _db.versementsDette},
      )
      .watch()
      .asyncMap((_) => calculer(periode));

  Future<Rapport> calculer(Periode periode) async {
    final ventes =
        await (_db.select(_db.ventes)..where(
              (v) =>
                  v.supprimeLe.isNull() &
                  v.dateVente.isBiggerOrEqualValue(periode.debut) &
                  v.dateVente.isSmallerThanValue(periode.fin),
            ))
            .get();
    final valides = ventes.where((v) => !v.annulee).toList();

    final parMode = <String, int>{};
    for (final v in valides) {
      parMode[v.modePaiement] = (parMode[v.modePaiement] ?? 0) + v.total;
    }

    final versements = _db.versementsDette.montant.sum();
    final requeteVersements = _db.selectOnly(_db.versementsDette)
      ..addColumns([versements])
      ..where(
        _db.versementsDette.supprimeLe.isNull() &
            _db.versementsDette.dateVersement.isBiggerOrEqualValue(
              periode.debut,
            ) &
            _db.versementsDette.dateVersement.isSmallerThanValue(periode.fin),
      );
    final totalVersements =
        await requeteVersements.map((r) => r.read(versements)).getSingle() ?? 0;

    return Rapport(
      periode: periode,
      nombreVentes: valides.length,
      total: valides.fold(0, (s, v) => s + v.total),
      benefice: valides.fold(0, (s, v) => s + v.benefice),
      payeSurVentes: valides.fold(0, (s, v) => s + v.montantPaye),
      venduACredit: valides.fold(0, (s, v) => s + v.resteAPayer),
      versements: totalVersements,
      parMode: parMode,
      top: await _top(periode),
      annulees: ventes.length - valides.length,
    );
  }

  Future<List<TopProduit>> _top(Periode periode) async {
    // Une jointure plutôt qu'une liste d'identifiants : pas de limite de
    // variables SQLite, et les lignes viennent dans l'ordre des ventes.
    final requete =
        _db.select(_db.lignesVente).join([
            innerJoin(
              _db.ventes,
              _db.ventes.id.equalsExp(_db.lignesVente.venteId),
            ),
            leftOuterJoin(
              _db.produits,
              _db.produits.id.equalsExp(_db.lignesVente.produitId),
            ),
          ])
          ..where(
            _db.lignesVente.supprimeLe.isNull() &
                _db.ventes.supprimeLe.isNull() &
                _db.ventes.annulee.equals(false) &
                _db.ventes.dateVente.isBiggerOrEqualValue(periode.debut) &
                _db.ventes.dateVente.isSmallerThanValue(periode.fin),
          )
          ..orderBy([OrderingTerm.asc(_db.ventes.dateVente)]);
    final resultats = await requete.get();
    if (resultats.isEmpty) return const [];
    final lignes = [for (final r in resultats) r.readTable(_db.lignesVente)];
    final produits = <String, Produit>{};
    for (final r in resultats) {
      final p = r.readTableOrNull(_db.produits);
      if (p != null) produits[p.id] = p;
    }

    final groupes = <String, List<LigneVente>>{};
    for (final l in lignes) {
      groupes.putIfAbsent(l.produitId, () => []).add(l);
    }
    final top =
        [
          for (final MapEntry(key: id, value: ls) in groupes.entries)
            _topProduit(id, ls, produits[id]),
        ]..sort((a, b) {
          final parMontant = b.montant.compareTo(a.montant);
          return parMontant != 0 ? parMontant : a.nom.compareTo(b.nom);
        });
    return top.take(tailleTop).toList();
  }

  static TopProduit _topProduit(
    String id,
    List<LigneVente> lignes,
    Produit? produit,
  ) {
    final calculs = [
      for (final l in lignes)
        LigneCalcul(
          quantite: l.quantite,
          prixUnitaire: l.prixUnitaire,
          prixAchatUnitaire: l.prixAchatUnitaire,
        ),
    ];
    return TopProduit(
      produitId: id,
      // Le nom actuel du produit, ou celui copié dans sa vente la plus
      // récente s'il a été supprimé (lignes triées par date de vente).
      nom: produit != null && produit.supprimeLe == null
          ? produit.nom
          : lignes.last.nomProduit,
      unite: produit?.unite ?? '',
      quantite: Calculs.arrondirQuantite(
        lignes.fold(0.0, (s, l) => s + l.quantite),
      ),
      montant: Calculs.totalVente(calculs),
      benefice: Calculs.beneficeVente(calculs),
    );
  }

  /// Modes de paiement dans l'ordre d'affichage.
  static const ordreModes = [
    ModePaiement.especes,
    ModePaiement.momo,
    ModePaiement.orangeMoney,
    ModePaiement.credit,
  ];
}
