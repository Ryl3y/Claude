/// Données d'exemple de la page de démonstration (pas des textes d'interface :
/// ce sont des produits et des clients comme un commerçant les saisirait).
library;

class ProduitDemo {
  const ProduitDemo(
    this.id,
    this.nom,
    this.prix,
    this.stock,
    this.unite,
    this.seuil,
  );

  final String id;
  final String nom;
  final int prix;
  final double stock;
  final String unite;
  final double seuil;
}

class ClientDemo {
  const ClientDemo(this.nom, this.telephone, this.dette, this.dernierAchat);

  final String nom;
  final String telephone;
  final int dette;
  final DateTime dernierAchat;
}

const nomBoutiqueDemo = 'Chez Rich';

const produitsDemo = [
  ProduitDemo('riz', 'Riz parfumé 5 kg', 3500, 12, 'sacs', 3),
  ProduitDemo('huile', 'Huile Mayor 1 L', 1500, 2, 'bouteilles', 4),
  ProduitDemo('savon', 'Savon Azur', 250, 40, 'pièces', 10),
  ProduitDemo('sucre', 'Sucre en vrac', 900, 1.5, 'kg', 2),
  ProduitDemo('lait', 'Lait concentré', 650, 24, 'boîtes', 6),
  ProduitDemo('spaghetti', 'Spaghetti Panzani 500 g', 400, 0, 'paquets', 5),
];

final clientsDemo = [
  ClientDemo('Awa Moussa', '690000003', 25000, DateTime.utc(2026, 10, 9, 15)),
  ClientDemo(
    'Maman Brigitte',
    '690000001',
    7500,
    DateTime.utc(2026, 10, 10, 8),
  ),
  ClientDemo('Paul Ndongo', '690000002', 0, DateTime.utc(2026, 10, 7, 11)),
];
