/// Règles de calcul de Kassa, sans Flutter ni base de données.
///
/// Montants en FCFA entiers. Les quantités peuvent être décimales (vrac :
/// 1,5 kg) : chaque ligne est arrondie au franc le plus proche.
library;

/// Une ligne de vente, telle qu'elle sert aux calculs.
class LigneCalcul {
  const LigneCalcul({
    required this.quantite,
    required this.prixUnitaire,
    required this.prixAchatUnitaire,
  });

  final double quantite;
  final int prixUnitaire;
  final int prixAchatUnitaire;

  /// Montant de la ligne : prix × quantité, arrondi au franc.
  int get montant => (prixUnitaire * quantite).round();

  /// Coût d'achat de la ligne, arrondi au franc.
  int get cout => (prixAchatUnitaire * quantite).round();
}

abstract final class Calculs {
  /// Précision des quantités en stock : 3 décimales (1,125 kg).
  static const _precisionStock = 1000;

  /// Total d'une vente : somme des montants des lignes.
  static int totalVente(Iterable<LigneCalcul> lignes) =>
      lignes.fold(0, (somme, l) => somme + l.montant);

  /// Bénéfice d'une vente : somme de (prix de vente − prix d'achat) × quantité.
  static int beneficeVente(Iterable<LigneCalcul> lignes) =>
      lignes.fold(0, (somme, l) => somme + l.montant - l.cout);

  /// Reste à payer : total − montant payé, jamais négatif
  /// (si le client donne plus, la différence est de la monnaie à rendre).
  static int resteAPayer({required int total, required int montantPaye}) {
    final reste = total - montantPaye;
    return reste > 0 ? reste : 0;
  }

  /// Monnaie à rendre : montant reçu − total, jamais négative.
  static int monnaieARendre({required int total, required int montantRecu}) {
    final monnaie = montantRecu - total;
    return monnaie > 0 ? monnaie : 0;
  }

  /// Stock : somme des quantités des mouvements (+ entrées, − sorties).
  /// Arrondi à 3 décimales pour effacer les erreurs d'arrondi des décimaux.
  static double stock(Iterable<double> quantitesMouvements) =>
      arrondirQuantite(quantitesMouvements.fold(0.0, (s, q) => s + q));

  static double arrondirQuantite(double q) =>
      (q * _precisionStock).round() / _precisionStock;

  /// Dette d'un client : reste à payer des ventes non annulées − versements.
  static int soldeDette({
    required Iterable<int> restesAPayer,
    required Iterable<int> versements,
  }) =>
      restesAPayer.fold(0, (s, r) => s + r) -
      versements.fold(0, (s, v) => s + v);

  /// Vrai si le stock est sous le seuil d'alerte (« Stock bas »).
  static bool stockBas({required double quantite, required double seuil}) =>
      quantite <= seuil;
}
