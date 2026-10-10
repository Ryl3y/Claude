import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/domain/calculs.dart';

void main() {
  const riz = LigneCalcul(quantite: 2, prixUnitaire: 3500, prixAchatUnitaire: 3000);
  const savon = LigneCalcul(quantite: 3, prixUnitaire: 250, prixAchatUnitaire: 200);
  const sucreVrac = LigneCalcul(quantite: 1.5, prixUnitaire: 900, prixAchatUnitaire: 750);

  group('total', () {
    test('somme des lignes', () {
      expect(Calculs.totalVente([riz, savon]), 7750);
    });
    test('quantité décimale arrondie au franc', () {
      expect(Calculs.totalVente([sucreVrac]), 1350);
      const tiers = LigneCalcul(quantite: 0.333, prixUnitaire: 1000, prixAchatUnitaire: 0);
      expect(Calculs.totalVente([tiers]), 333);
    });
    test('vente vide = 0', () {
      expect(Calculs.totalVente(const []), 0);
    });
  });

  group('bénéfice', () {
    test('(prix de vente − prix d\'achat) × quantité', () {
      expect(Calculs.beneficeVente([riz, savon]), 1000 + 150);
    });
    test('vrac', () {
      expect(Calculs.beneficeVente([sucreVrac]), 225);
    });
    test('vente à perte : bénéfice négatif', () {
      const perte = LigneCalcul(quantite: 1, prixUnitaire: 800, prixAchatUnitaire: 1000);
      expect(Calculs.beneficeVente([perte]), -200);
    });
  });

  group('paiement', () {
    test('reste à payer', () {
      expect(Calculs.resteAPayer(total: 7750, montantPaye: 2000), 5750);
      expect(Calculs.resteAPayer(total: 7750, montantPaye: 10000), 0);
    });
    test('monnaie à rendre', () {
      expect(Calculs.monnaieARendre(total: 7750, montantRecu: 10000), 2250);
      expect(Calculs.monnaieARendre(total: 7750, montantRecu: 5000), 0);
    });
  });

  group('stock', () {
    test('entrées − sorties', () {
      expect(Calculs.stock([10, -2, -3, 5]), 10);
    });
    test('décimaux sans erreur d\'arrondi', () {
      expect(Calculs.stock([0.1, 0.2]), 0.3);
      expect(Calculs.stock([5, -1.5, -1.25]), 2.25);
    });
    test('stock bas', () {
      expect(Calculs.stockBas(quantite: 3, seuil: 5), isTrue);
      expect(Calculs.stockBas(quantite: 5, seuil: 5), isTrue);
      expect(Calculs.stockBas(quantite: 6, seuil: 5), isFalse);
    });
  });

  group('solde_dette', () {
    test('ventes à crédit − versements', () {
      expect(Calculs.soldeDette(restesAPayer: [5000, 2500], versements: [3000]), 4500);
    });
    test('à jour', () {
      expect(Calculs.soldeDette(restesAPayer: [5000], versements: [5000]), 0);
    });
  });
}
