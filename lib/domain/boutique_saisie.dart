/// Ce qu'on saisit pour sa boutique : création (écran 3) et Réglages.
class BoutiqueSaisie {
  const BoutiqueSaisie({
    required this.nom,
    required this.typeCommerce,
    required this.ville,
    required this.quartier,
    this.arrondissement,
    this.localiteId,
    this.quartierId,
  });

  final String nom;
  final String typeCommerce;

  /// Nom de la ville ou du village.
  final String ville;
  final String quartier;

  /// Code officiel de l'arrondissement (« CM008005001 ») ; la région et le
  /// département s'en déduisent.
  final String? arrondissement;

  /// Ville ou village et quartier dans les listes partagées du serveur ;
  /// null si choisis hors ligne (le nom seul est gardé).
  final String? localiteId;
  final String? quartierId;
}

/// Alerte de stock bas proposée aux nouveaux produits : de 0 à ce maximum
/// (la colonne du serveur est un entier 32 bits).
const seuilAlerteDefautMax = 100000;
