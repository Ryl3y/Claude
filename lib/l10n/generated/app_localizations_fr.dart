// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Kassa';

  @override
  String get appTagline => 'Ventes, stock et dettes, même sans internet.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navSell => 'Vendre';

  @override
  String get navStock => 'Stock';

  @override
  String get navCustomers => 'Clients';

  @override
  String get newSale => 'Nouvelle vente';

  @override
  String get collectPayment => 'Encaisser';

  @override
  String get add => 'Ajouter';

  @override
  String get restock => 'Réappro';

  @override
  String owes(String montant) {
    return 'Doit $montant';
  }

  @override
  String get paidUp => 'À jour';

  @override
  String get remind => 'Rappeler';

  @override
  String get lowStock => 'Stock bas';

  @override
  String get todaySales => 'Ventes du jour';

  @override
  String get moneyOwed => 'Dettes à recevoir';

  @override
  String get saved => 'Sauvegardé';

  @override
  String get goPro => 'Passer à Pro';

  @override
  String get cancelSale => 'Annuler la vente';

  @override
  String youSoldToday(String montant) {
    return 'Vous avez vendu $montant aujourd\'hui.';
  }

  @override
  String get todayProfit => 'Bénéfice du jour';

  @override
  String get language => 'Langue';

  @override
  String get languagePhone => 'Langue du téléphone';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get previewStepNote =>
      'Écran de démonstration des composants (étape 3). Il sera remplacé par l\'accueil.';

  @override
  String get owesLabel => 'Doit';

  @override
  String addToCart(String nom) {
    return 'Ajouter $nom au panier';
  }

  @override
  String inCart(String quantite) {
    return '$quantite dans le panier';
  }

  @override
  String stockLeft(String quantite, String unite) {
    return '$quantite $unite';
  }

  @override
  String remindOnWhatsapp(String nom) {
    return 'Rappeler $nom sur WhatsApp';
  }

  @override
  String reminderMessage(String nom, String montant, String boutique) {
    return 'Bonjour $nom, il reste $montant à payer chez $boutique. Merci.';
  }

  @override
  String get erase => 'Effacer';

  @override
  String stockAlerts(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre produits en stock bas',
      one: '1 produit en stock bas',
    );
    return '$_temp0';
  }

  @override
  String salesCount(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre ventes',
      one: '1 vente',
      zero: 'Aucune vente',
    );
    return '$_temp0';
  }

  @override
  String customersCount(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre clients',
      one: '1 client',
      zero: 'Aucun client',
    );
    return '$_temp0';
  }

  @override
  String lastPurchase(String date) {
    return 'Dernier achat le $date';
  }

  @override
  String get later => 'Plus tard';

  @override
  String get paid => 'Payé';

  @override
  String get cancelled => 'Annulée';

  @override
  String get demoTitle => 'Composants Kassa';

  @override
  String get demoButtons => 'Boutons';

  @override
  String get demoBadges => 'Étiquettes';

  @override
  String get demoAmounts => 'Montants';

  @override
  String get demoStats => 'Chiffres clés';

  @override
  String get demoProducts => 'Produits';

  @override
  String get demoProductsHint => 'Touchez une carte pour l\'ajouter au panier.';

  @override
  String get demoCustomers => 'Clients';

  @override
  String get demoNumPad => 'Pavé numérique';

  @override
  String demoReminderSent(String nom) {
    return 'Rappel prêt pour $nom.';
  }

  @override
  String get enterQuantity => 'Saisir une quantité';

  @override
  String get proBadge => 'Pro';

  @override
  String get searchProducts => 'Rechercher un produit';

  @override
  String get filterAll => 'Tous';

  @override
  String filterLowStock(int nombre) {
    return 'Stock bas ($nombre)';
  }

  @override
  String get noCategory => 'Sans catégorie';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get stockEmptyTitle => 'Aucun produit pour l\'instant';

  @override
  String get stockEmptyBody =>
      'Ajoutez vos produits pour suivre le stock et commencer à vendre.';

  @override
  String stockNoResult(String recherche) {
    return 'Aucun produit ne correspond à « $recherche ». Vérifiez l\'orthographe ou ajoutez ce produit.';
  }

  @override
  String get stockNoLowStock =>
      'Aucun produit en stock bas. Tout est au-dessus du seuil d\'alerte.';

  @override
  String get stockNoInCategory => 'Aucun produit dans cette catégorie.';

  @override
  String stockOf(String quantite) {
    return 'Stock : $quantite';
  }

  @override
  String restockProduct(String nom) {
    return 'Réappro $nom';
  }

  @override
  String get productNewTitle => 'Nouveau produit';

  @override
  String get productEditTitle => 'Modifier le produit';

  @override
  String get fieldName => 'Nom du produit';

  @override
  String get fieldNameHint => 'Ex. Riz parfumé 5 kg';

  @override
  String get fieldCategory => 'Catégorie';

  @override
  String get newCategory => 'Nouvelle catégorie';

  @override
  String get fieldPurchasePrice => 'Prix d\'achat';

  @override
  String get fieldPurchasePriceHelp => 'Ce que vous payez pour une unité.';

  @override
  String get fieldSalePrice => 'Prix de vente';

  @override
  String get fieldSalePriceHelp => 'Le prix demandé au client pour une unité.';

  @override
  String get fieldQuantity => 'Quantité en stock';

  @override
  String get fieldQuantityHelpNew =>
      'Ce que vous avez aujourd\'hui. Mettez 0 si vous n\'en avez pas.';

  @override
  String get fieldQuantityHelpEdit =>
      'Changer ce nombre enregistre une correction du stock.';

  @override
  String get fieldUnit => 'Unité';

  @override
  String get fieldThreshold => 'Alerte de stock bas';

  @override
  String get fieldThresholdHelp =>
      'Kassa vous prévient quand il en reste ce nombre ou moins.';

  @override
  String get photoAdd => 'Ajouter une photo';

  @override
  String get photoChange => 'Changer la photo';

  @override
  String get photoTake => 'Prendre une photo';

  @override
  String get photoGallery => 'Choisir dans la galerie';

  @override
  String get photoRemove => 'Retirer la photo';

  @override
  String get photoError =>
      'La photo n\'a pas pu être ajoutée. Réessayez ou choisissez une autre photo.';

  @override
  String get unitPiece => 'pièce';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLitre => 'litre';

  @override
  String get unitCarton => 'carton';

  @override
  String get unitBag => 'sac';

  @override
  String get unitPack => 'paquet';

  @override
  String get unitBottle => 'bouteille';

  @override
  String get unitBox => 'boîte';

  @override
  String get errNameRequired => 'Saisissez le nom du produit.';

  @override
  String get errPriceRequired => 'Saisissez un prix en francs, sans virgule.';

  @override
  String get errQuantityInvalid =>
      'Saisissez un nombre, par exemple 12 ou 1,5.';

  @override
  String get errUnitRequired => 'Choisissez ou saisissez une unité.';

  @override
  String warnSellingAtLoss(String montant) {
    return 'Le prix de vente est plus bas que le prix d\'achat : vous perdez $montant par unité.';
  }

  @override
  String get save => 'Enregistrer';

  @override
  String get productAdded => 'Produit ajouté.';

  @override
  String get productSaved => 'Modifications enregistrées.';

  @override
  String get deleteProduct => 'Supprimer le produit';

  @override
  String deleteProductTitle(String nom) {
    return 'Supprimer $nom ?';
  }

  @override
  String get deleteProductBody =>
      'Il ne sera plus proposé à la vente. Les ventes passées restent dans l\'historique.';

  @override
  String get deleteConfirm => 'Supprimer';

  @override
  String get keep => 'Garder';

  @override
  String productDeleted(String nom) {
    return '$nom a été supprimé.';
  }

  @override
  String get productNotFound =>
      'Ce produit n\'existe plus. Il a peut-être été supprimé.';

  @override
  String get saveError =>
      'L\'enregistrement a échoué. Réessayez ; vos données sont toujours sur le téléphone.';

  @override
  String get categoryName => 'Nom de la catégorie';

  @override
  String get categoryCreate => 'Créer';

  @override
  String get cancel => 'Annuler';

  @override
  String get errCategoryName => 'Saisissez un nom de catégorie.';

  @override
  String get categoryQuickPick => 'Choisissez un modèle ou saisissez un nom.';

  @override
  String get catGrocery => 'Épicerie';

  @override
  String get catDrinks => 'Boissons';

  @override
  String get catHygiene => 'Hygiène';

  @override
  String get catHousehold => 'Ménage';

  @override
  String get catFresh => 'Frais';

  @override
  String get catOther => 'Autre';

  @override
  String get restockChooseProduct => 'Choisissez le produit reçu.';

  @override
  String currentStock(String quantite) {
    return 'Stock actuel : $quantite';
  }

  @override
  String currentPurchasePrice(String montant) {
    return 'Prix d\'achat actuel : $montant';
  }

  @override
  String get fieldReceivedQuantity => 'Quantité reçue';

  @override
  String get fieldNewPurchasePriceHelp =>
      'Changez-le si votre fournisseur a changé son prix.';

  @override
  String newStockPreview(String quantite) {
    return 'Nouveau stock : $quantite';
  }

  @override
  String get addToStock => 'Ajouter au stock';

  @override
  String get errReceivedQuantity =>
      'Saisissez la quantité reçue, plus grande que 0.';

  @override
  String stockUpdated(String quantite) {
    return 'Stock mis à jour : $quantite.';
  }

  @override
  String get comingSoon => 'Cet écran arrive dans une prochaine version.';
}
