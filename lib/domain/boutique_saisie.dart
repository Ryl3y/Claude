/// Ce qu'on saisit pour sa boutique : création (écran 3) et Réglages.
class BoutiqueSaisie {
  const BoutiqueSaisie({
    required this.nom,
    required this.typeCommerce,
    required this.ville,
    required this.quartier,
  });

  final String nom;
  final String typeCommerce;
  final String ville;
  final String quartier;
}

/// Alerte de stock bas proposée aux nouveaux produits : de 0 à ce maximum
/// (la colonne du serveur est un entier 32 bits).
const seuilAlerteDefautMax = 100000;
