import 'calculs.dart';

/// Une ligne du panier : copie du produit au moment où on l'ajoute.
class LignePanier {
  const LignePanier({
    required this.produitId,
    required this.nom,
    required this.unite,
    required this.prixUnitaire,
    required this.prixAchatUnitaire,
    required this.quantite,
    required this.stockDisponible,
  });

  final String produitId;
  final String nom;
  final String unite;
  final int prixUnitaire;
  final int prixAchatUnitaire;
  final double quantite;

  /// Stock au moment de l'ajout, pour prévenir si on vend plus qu'on n'a.
  final double stockDisponible;

  int get montant => LigneCalcul(
    quantite: quantite,
    prixUnitaire: prixUnitaire,
    prixAchatUnitaire: prixAchatUnitaire,
  ).montant;

  bool get depasseLeStock => quantite > stockDisponible;

  LignePanier avecQuantite(double q) => LignePanier(
    produitId: produitId,
    nom: nom,
    unite: unite,
    prixUnitaire: prixUnitaire,
    prixAchatUnitaire: prixAchatUnitaire,
    quantite: Calculs.arrondirQuantite(q),
    stockDisponible: stockDisponible,
  );
}

/// Le panier de la vente en cours (immuable).
class Panier {
  const Panier([this.lignes = const []]);

  final List<LignePanier> lignes;

  bool get estVide => lignes.isEmpty;

  /// Nombre d'articles (somme des quantités ; 1,5 kg compte pour 1,5).
  double get nombreArticles =>
      Calculs.arrondirQuantite(lignes.fold(0.0, (s, l) => s + l.quantite));

  List<LigneCalcul> get _calculs => [
    for (final l in lignes)
      LigneCalcul(
        quantite: l.quantite,
        prixUnitaire: l.prixUnitaire,
        prixAchatUnitaire: l.prixAchatUnitaire,
      ),
  ];

  int get total => Calculs.totalVente(_calculs);
  int get benefice => Calculs.beneficeVente(_calculs);

  double quantiteDe(String produitId) =>
      lignes.where((l) => l.produitId == produitId).firstOrNull?.quantite ?? 0;

  /// Ajoute [quantite] (1 par défaut) ; crée la ligne si besoin.
  Panier ajouter(LignePanier nouvelle) {
    final i = lignes.indexWhere((l) => l.produitId == nouvelle.produitId);
    if (i < 0) return Panier([...lignes, nouvelle]);
    final copie = [...lignes];
    copie[i] = copie[i].avecQuantite(copie[i].quantite + nouvelle.quantite);
    return Panier(copie);
  }

  /// Fixe la quantité d'un produit ; 0 ou moins retire la ligne.
  Panier fixerQuantite(String produitId, double quantite) {
    if (quantite <= 0) return retirer(produitId);
    return Panier([
      for (final l in lignes)
        l.produitId == produitId ? l.avecQuantite(quantite) : l,
    ]);
  }

  Panier retirer(String produitId) => Panier([
    for (final l in lignes)
      if (l.produitId != produitId) l,
  ]);
}

/// Mode de paiement choisi à l'écran Paiement.
enum ModeChoisi { especes, momo, orangeMoney, credit }

/// Montants proposés en un toucher à l'écran Paiement (espèces) : le
/// montant exact, puis les arrondis au billet supérieur (4 au plus).
List<int> montantsProposes(int total) {
  const billets = [500, 1000, 2000, 5000, 10000];
  final montants = <int>{total};
  for (final b in billets) {
    final arrondi = ((total + b - 1) ~/ b) * b;
    if (arrondi > total) montants.add(arrondi);
    if (montants.length >= 4) break;
  }
  return montants.toList()..sort();
}

/// Résultat du calcul de paiement.
class CalculPaiement {
  const CalculPaiement({
    required this.montantPaye,
    required this.resteAPayer,
    required this.monnaie,
    required this.manque,
  });

  /// Ce qui est enregistré comme payé (jamais plus que le total).
  final int montantPaye;
  final int resteAPayer;

  /// Monnaie à rendre (espèces).
  final int monnaie;

  /// Ce qui manque quand le client donne moins que le total (espèces).
  final int manque;

  /// Calcule le paiement. [saisi] : montant reçu (espèces) ou avance
  /// (crédit) ; null = rien de saisi → le montant exact pour les espèces,
  /// 0 d'avance pour le crédit. Mobile money : toujours le total.
  static CalculPaiement pour({
    required ModeChoisi mode,
    required int total,
    int? saisi,
  }) {
    switch (mode) {
      case ModeChoisi.momo || ModeChoisi.orangeMoney:
        return CalculPaiement(
          montantPaye: total,
          resteAPayer: 0,
          monnaie: 0,
          manque: 0,
        );
      case ModeChoisi.especes:
        final recu = saisi ?? total;
        return CalculPaiement(
          montantPaye: recu < total ? recu : total,
          resteAPayer: 0,
          monnaie: Calculs.monnaieARendre(total: total, montantRecu: recu),
          manque: Calculs.resteAPayer(total: total, montantPaye: recu),
        );
      case ModeChoisi.credit:
        final avance = saisi ?? 0;
        final paye = avance < total ? avance : total;
        return CalculPaiement(
          montantPaye: paye,
          resteAPayer: Calculs.resteAPayer(total: total, montantPaye: paye),
          monnaie: Calculs.monnaieARendre(total: total, montantRecu: avance),
          manque: 0,
        );
    }
  }
}
