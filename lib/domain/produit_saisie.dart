/// Données d'un produit saisies dans le formulaire (écran 10).
class ProduitSaisie {
  const ProduitSaisie({
    required this.nom,
    required this.prixAchat,
    required this.prixVente,
    required this.quantite,
    required this.unite,
    required this.seuilAlerte,
    this.categorieId,
    this.photoLocale,
    this.codeBarre,
  });

  final String nom;
  final String? categorieId;
  final int prixAchat;
  final int prixVente;
  final double quantite;
  final String unite;
  final double seuilAlerte;
  final String? photoLocale;
  final String? codeBarre;
}

/// Erreurs possibles dans le formulaire produit.
enum ErreurProduit {
  nomVide,
  prixInvalide,
  quantiteInvalide,
  uniteVide,
  seuilInvalide,
}

abstract final class ReglesProduit {
  /// Seuil d'alerte proposé quand la boutique n'en a pas encore.
  static const seuilAlerteParDefaut = 5;

  /// Vérifie une saisie ; ensemble vide = valide. À la création, la quantité
  /// de départ ne peut pas être négative ; en modification, elle peut l'être
  /// (le stock réel peut passer sous zéro après des ventes).
  static Set<ErreurProduit> verifier(ProduitSaisie s, {bool creation = true}) =>
      {
        if (s.nom.trim().isEmpty) ErreurProduit.nomVide,
        if (s.prixAchat < 0 || s.prixVente < 0) ErreurProduit.prixInvalide,
        if (creation && s.quantite < 0) ErreurProduit.quantiteInvalide,
        if (s.unite.trim().isEmpty) ErreurProduit.uniteVide,
        if (s.seuilAlerte < 0) ErreurProduit.seuilInvalide,
      };

  /// Perte par unité si le prix de vente est sous le prix d'achat (sinon 0).
  static int perteParUnite({required int prixAchat, required int prixVente}) =>
      prixVente < prixAchat ? prixAchat - prixVente : 0;
}
