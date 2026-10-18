import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/domain/panier.dart';

LignePanier l(
  String id, {
  double q = 1,
  int prix = 1000,
  int achat = 800,
  double stock = 10,
}) => LignePanier(
  produitId: id,
  nom: id,
  unite: 'pièce',
  prixUnitaire: prix,
  prixAchatUnitaire: achat,
  quantite: q,
  stockDisponible: stock,
);

void main() {
  group('Panier', () {
    test('toucher deux fois = quantité 2, même ligne', () {
      final p = const Panier().ajouter(l('a')).ajouter(l('a'));
      expect(p.lignes, hasLength(1));
      expect(p.quantiteDe('a'), 2);
      expect(p.total, 2000);
      expect(p.benefice, 400);
    });
    test('quantité fixée, vrac décimal, retrait à 0', () {
      var p = const Panier().ajouter(l('sucre', prix: 900, achat: 750));
      p = p.fixerQuantite('sucre', 1.5);
      expect(p.total, 1350);
      expect(p.nombreArticles, 1.5);
      p = p.fixerQuantite('sucre', 0);
      expect(p.estVide, isTrue);
    });
    test('dépassement du stock signalé', () {
      final p = const Panier().ajouter(l('a', q: 11));
      expect(p.lignes.single.depasseLeStock, isTrue);
    });
  });

  group('CalculPaiement', () {
    test('espèces : rien saisi = montant exact', () {
      final c = CalculPaiement.pour(mode: ModeChoisi.especes, total: 7750);
      expect(c.montantPaye, 7750);
      expect(c.monnaie, 0);
      expect(c.manque, 0);
    });
    test('espèces : monnaie à rendre', () {
      final c = CalculPaiement.pour(
        mode: ModeChoisi.especes,
        total: 7750,
        saisi: 10000,
      );
      expect(c.montantPaye, 7750);
      expect(c.monnaie, 2250);
    });
    test('espèces : il manque', () {
      final c = CalculPaiement.pour(
        mode: ModeChoisi.especes,
        total: 7750,
        saisi: 5000,
      );
      expect(c.manque, 2750);
    });
    test('mobile money : toujours le total', () {
      for (final m in [ModeChoisi.momo, ModeChoisi.orangeMoney]) {
        final c = CalculPaiement.pour(mode: m, total: 5000, saisi: 1);
        expect(c.montantPaye, 5000);
        expect(c.resteAPayer, 0);
      }
    });
    test('crédit : avance et reste', () {
      final c = CalculPaiement.pour(
        mode: ModeChoisi.credit,
        total: 7000,
        saisi: 2000,
      );
      expect(c.montantPaye, 2000);
      expect(c.resteAPayer, 5000);
      expect(
        CalculPaiement.pour(mode: ModeChoisi.credit, total: 7000).resteAPayer,
        7000,
      );
    });
    test('crédit : avance plus grande que le total = payé, monnaie rendue', () {
      final c = CalculPaiement.pour(
        mode: ModeChoisi.credit,
        total: 7000,
        saisi: 8000,
      );
      expect(c.montantPaye, 7000);
      expect(c.resteAPayer, 0);
      expect(c.monnaie, 1000);
    });
  });

  test('montants proposés : exact puis billets', () {
    expect(montantsProposes(7750), [7750, 8000, 10000]);
    expect(montantsProposes(3500), [3500, 4000, 5000, 10000]);
    expect(montantsProposes(10000), [10000]);
  });

  test('ré-ajout : le stock le plus récent remplace l\'ancien', () {
    const l = LignePanier(
      produitId: 'p',
      nom: 'Riz',
      unite: 'sac',
      prixUnitaire: 100,
      prixAchatUnitaire: 80,
      quantite: 1,
      stockDisponible: 2,
    );
    final panier = const Panier()
        .ajouter(l)
        .ajouter(l)
        .ajouter(
          const LignePanier(
            produitId: 'p',
            nom: 'Riz',
            unite: 'sac',
            prixUnitaire: 100,
            prixAchatUnitaire: 80,
            quantite: 1,
            stockDisponible: 50,
          ),
        );
    expect(panier.lignes.single.quantite, 3);
    expect(panier.lignes.single.depasseLeStock, isFalse);
  });
}
