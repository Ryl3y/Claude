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

  @override
  String get loadError =>
      'Impossible de lire vos produits. Fermez puis rouvrez l\'app ; vos données restent sur le téléphone.';

  @override
  String get history => 'Historique';

  @override
  String productsCount(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre produits',
      one: '1 produit',
    );
    return '$_temp0';
  }

  @override
  String get cartTitle => 'Panier';

  @override
  String get cartEmptyHint =>
      'Touchez un produit pour l\'ajouter. Appui long pour choisir la quantité.';

  @override
  String get sellNoProductsTitle => 'Aucun produit à vendre';

  @override
  String get sellNoProductsBody =>
      'Ajoutez vos produits dans l\'onglet Stock pour commencer à vendre.';

  @override
  String get clearCart => 'Vider le panier';

  @override
  String get cartCleared => 'Panier vidé.';

  @override
  String get undo => 'Rétablir';

  @override
  String get removeFromCart => 'Retirer';

  @override
  String increaseQuantity(String nom) {
    return 'Ajouter 1 $nom';
  }

  @override
  String decreaseQuantity(String nom) {
    return 'Enlever 1 $nom';
  }

  @override
  String quantityOf(String nom) {
    return 'Quantité de $nom';
  }

  @override
  String get putInCart => 'Mettre au panier';

  @override
  String stockInsufficient(String quantite) {
    return 'Stock insuffisant : il reste $quantite. La vente reste possible.';
  }

  @override
  String get decimalSeparator => 'Virgule';

  @override
  String get paymentTitle => 'Paiement';

  @override
  String get saleTotal => 'Total de la vente';

  @override
  String get totalToPay => 'Total à payer';

  @override
  String get payCash => 'Espèces';

  @override
  String get payMomo => 'MTN MoMo';

  @override
  String get payOrange => 'Orange Money';

  @override
  String get payCredit => 'Crédit';

  @override
  String get amountReceived => 'Montant reçu';

  @override
  String get amountReceivedHint =>
      'Rien à saisir si le client donne le montant exact.';

  @override
  String get changeToGive => 'Monnaie à rendre';

  @override
  String missingAmount(String montant) {
    return 'Il manque $montant. Encaissez plus, ou choisissez Crédit pour noter une dette.';
  }

  @override
  String mobileMoneyHint(String montant) {
    return 'Vérifiez que les $montant sont bien arrivés sur votre téléphone avant d\'encaisser.';
  }

  @override
  String get advancePaid => 'Avance payée maintenant';

  @override
  String get advancePaidHint =>
      'Laissez 0 si le client ne paie rien aujourd\'hui.';

  @override
  String get remainingDebt => 'Reste à payer';

  @override
  String get customer => 'Client';

  @override
  String get chooseCustomer => 'Choisir le client';

  @override
  String get changeCustomer => 'Changer';

  @override
  String get newCustomer => 'Nouveau client';

  @override
  String get customerName => 'Nom du client';

  @override
  String get customerPhone => 'Téléphone (facultatif)';

  @override
  String get customerPhoneHint => 'Pour lui envoyer un rappel WhatsApp.';

  @override
  String get errCustomerName => 'Saisissez le nom du client.';

  @override
  String get addCustomer => 'Ajouter le client';

  @override
  String get searchCustomers => 'Rechercher un client';

  @override
  String get noCustomers =>
      'Aucun client pour l\'instant. Ajoutez-le avec « Nouveau client ».';

  @override
  String get errChooseCustomer => 'Choisissez le client qui prend à crédit.';

  @override
  String collectAmount(String montant) {
    return 'Encaisser $montant';
  }

  @override
  String get sellOnCredit => 'Vendre à crédit';

  @override
  String saleRecorded(int numero, String montant) {
    return 'Vente n°$numero enregistrée : $montant.';
  }

  @override
  String saleRecordedChange(int numero, String monnaie) {
    return 'Vente n°$numero enregistrée. Rendez $monnaie.';
  }

  @override
  String get historyTitle => 'Historique des ventes';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get chooseDate => 'Choisir une date';

  @override
  String get allDates => 'Toutes les dates';

  @override
  String saleNumber(int numero) {
    return 'Vente n°$numero';
  }

  @override
  String saleNumberTime(int numero, String heure) {
    return 'N°$numero · $heure';
  }

  @override
  String get historyEmptyTitle => 'Aucune vente pour l\'instant';

  @override
  String get historyEmptyBody => 'Vos ventes apparaîtront ici dès la première.';

  @override
  String get historyEmptyDay =>
      'Aucune vente ce jour-là. Choisissez une autre date.';

  @override
  String daySummary(int nombre, String montant) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre ventes',
      one: '1 vente',
    );
    return '$_temp0 · $montant';
  }

  @override
  String saleDateTime(String date, String heure) {
    return 'Le $date à $heure';
  }

  @override
  String get products => 'Produits';

  @override
  String get profit => 'Bénéfice';

  @override
  String get paymentMode => 'Paiement';

  @override
  String lineDetail(String quantite, String prix) {
    return '$quantite × $prix';
  }

  @override
  String cancelSaleTitle(int numero) {
    return 'Annuler la vente n°$numero ?';
  }

  @override
  String get cancelSaleBody =>
      'Le stock sera remis et la dette du client retirée. La vente reste dans l\'historique, marquée Annulée.';

  @override
  String get keepSale => 'Garder la vente';

  @override
  String get errCancelRepaid =>
      'Le client a déjà remboursé une partie de cette vente : impossible de l\'annuler.';

  @override
  String saleCancelled(int numero) {
    return 'Vente n°$numero annulée. Le stock a été remis.';
  }

  @override
  String get saleNotFound => 'Cette vente n\'existe plus.';

  @override
  String debtorsCount(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre clients vous doivent de l\'argent',
      one: '1 client vous doit de l\'argent',
      zero: 'Personne ne vous doit d\'argent',
    );
    return '$_temp0';
  }

  @override
  String lastPurchaseOn(String date) {
    return 'Dernier achat le $date';
  }

  @override
  String get lastPurchaseToday => 'Dernier achat aujourd\'hui';

  @override
  String get lastPurchaseYesterday => 'Dernier achat hier';

  @override
  String get customersEmptyTitle => 'Aucun client pour l\'instant';

  @override
  String get customersEmptyBody =>
      'Ajoutez vos clients pour suivre ce qu\'ils vous doivent.';

  @override
  String noCustomerMatch(String texte) {
    return 'Aucun client ne correspond à « $texte ».';
  }

  @override
  String reminderMessageNoShop(String nom, String montant) {
    return 'Bonjour $nom, il vous reste $montant à payer. Merci.';
  }

  @override
  String get whatsappError =>
      'WhatsApp ne s\'ouvre pas. Vérifiez qu\'il est installé sur ce téléphone.';

  @override
  String get addPhoneToRemind =>
      'Ajoutez son numéro pour lui envoyer un rappel WhatsApp.';

  @override
  String get edit => 'Modifier';

  @override
  String get balance => 'Solde';

  @override
  String get customerHistoryEmpty =>
      'Aucun achat ni versement pour l\'instant.';

  @override
  String purchaseNumber(int numero) {
    return 'Achat · N°$numero';
  }

  @override
  String creditPurchaseNumber(int numero) {
    return 'Achat à crédit · N°$numero';
  }

  @override
  String debtPayment(String mode) {
    return 'Versement · $mode';
  }

  @override
  String get customerNotFound => 'Ce client n\'existe plus.';

  @override
  String get collectDebtTitle => 'Encaisser une dette';

  @override
  String get amountPaidNow => 'Montant versé';

  @override
  String get amountPaidNowHint =>
      'Touchez « Toute la dette » si le client paie tout.';

  @override
  String wholeDebt(String montant) {
    return 'Toute la dette · $montant';
  }

  @override
  String get remainingAfterPayment => 'Il restera à payer';

  @override
  String get debtPaidOffLabel => 'Dette soldée';

  @override
  String errPaymentTooHigh(String nom, String montant) {
    return '$nom ne doit que $montant. Baissez le montant.';
  }

  @override
  String get paymentRecordedTitle => 'Versement enregistré';

  @override
  String paymentRecordedBody(String montant, String nom) {
    return '$montant reçus de $nom.';
  }

  @override
  String paymentRemaining(String montant) {
    return 'Il reste $montant à payer.';
  }

  @override
  String get paymentPaidOff => 'Sa dette est soldée.';

  @override
  String get sendReceipt => 'Envoyer le reçu';

  @override
  String get done => 'Terminer';

  @override
  String receiptMessage(String nom, String montant, String date) {
    return 'Bonjour $nom, le $date, nous avons bien reçu $montant.';
  }

  @override
  String receiptRemaining(String montant) {
    return 'Il vous reste $montant à payer. Merci.';
  }

  @override
  String get receiptPaidOff => 'Votre dette est soldée. Merci.';

  @override
  String get editCustomerTitle => 'Modifier le client';

  @override
  String get customerNote => 'Note (facultatif)';

  @override
  String get customerNoteHint => 'Par exemple : paie en fin de mois.';

  @override
  String get errCustomerPhone =>
      'Numéro invalide. Saisissez 9 chiffres, par exemple 6 77 12 34 56.';

  @override
  String get deleteCustomer => 'Supprimer le client';

  @override
  String deleteCustomerTitle(String nom) {
    return 'Supprimer $nom ?';
  }

  @override
  String get deleteCustomerBody =>
      'Il ne sera plus dans votre liste. Ses achats restent dans l\'historique des ventes.';

  @override
  String errDeleteIndebted(String nom, String montant) {
    return '$nom doit encore $montant. Encaissez sa dette avant de le supprimer.';
  }

  @override
  String customerDeleted(String nom) {
    return '$nom a été supprimé.';
  }

  @override
  String dateAndTotal(String date, String total) {
    return '$date · Total $total';
  }

  @override
  String salesAndProfit(String ventes, String montant) {
    return '$ventes · bénéfice $montant';
  }

  @override
  String get saveStatePending => 'Sauvegarde en attente';

  @override
  String get saveStateLocal => 'Sur ce téléphone';

  @override
  String get saveStateSavedHelp => 'Tout est sauvegardé en ligne.';

  @override
  String get saveStatePendingHelp =>
      'Des changements attendent internet pour être sauvegardés.';

  @override
  String get saveStateLocalHelp =>
      'Vos données sont enregistrées sur ce téléphone. La sauvegarde en ligne commencera quand vous créerez votre compte.';

  @override
  String get seeStock => 'Voir le stock';

  @override
  String get reportsTitle => 'Rapports';

  @override
  String get reportsHint => 'Jour, semaine, mois et meilleurs produits';

  @override
  String get homeNoProductsTitle => 'Ajoutez vos produits pour commencer';

  @override
  String get homeNoProductsBody =>
      'Avec vos produits et leurs prix, une vente se fait en quelques touchers.';

  @override
  String get periodDay => 'Jour';

  @override
  String get periodWeek => 'Semaine';

  @override
  String get periodMonth => 'Mois';

  @override
  String get periodEarlier => 'Avant';

  @override
  String get periodLater => 'Après';

  @override
  String get periodEarlierHint => 'Période précédente';

  @override
  String get periodLaterHint => 'Période suivante';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get lastWeek => 'La semaine dernière';

  @override
  String weekRange(String debut, String fin) {
    return 'Du $debut au $fin';
  }

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get lastMonth => 'Le mois dernier';

  @override
  String get salesLabel => 'Ventes';

  @override
  String averageSale(String montant) {
    return 'Vente moyenne : $montant';
  }

  @override
  String get moneyReceivedTitle => 'Argent reçu';

  @override
  String get paidAtSale => 'Payé à la vente';

  @override
  String get soldOnCredit => 'Vendu à crédit';

  @override
  String get debtsCollected => 'Dettes encaissées';

  @override
  String get totalReceived => 'Total reçu';

  @override
  String get salesByMode => 'Ventes par mode de paiement';

  @override
  String get bestSellers => 'Meilleurs produits';

  @override
  String bestSellerDetail(String quantite, String benefice) {
    return '$quantite vendus · bénéfice $benefice';
  }

  @override
  String bestSellerRank(int rang) {
    return 'N°$rang';
  }

  @override
  String get reportEmpty => 'Aucune vente sur cette période.';

  @override
  String cancelledNotCounted(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre ventes annulées ne sont pas comptées.',
      one: '1 vente annulée n\'est pas comptée.',
    );
    return '$_temp0';
  }

  @override
  String get welcomeTitle => 'Votre caisse, même sans internet';

  @override
  String get welcomeBody =>
      'Ventes, stock et dettes de vos clients au même endroit. Il faut internet une seule fois, pour créer votre compte.';

  @override
  String get start => 'Commencer';

  @override
  String get serverMissing =>
      'Cette version de l\'app n\'est pas reliée au serveur Kassa.';

  @override
  String get loginTitle => 'Votre numéro';

  @override
  String get loginBody =>
      'Nous vous envoyons un code par SMS pour vérifier que ce numéro est à vous.';

  @override
  String get phoneLabel => 'Numéro de téléphone';

  @override
  String get errPhone =>
      'Numéro invalide. Saisissez les 9 chiffres, par exemple 6 77 12 34 56.';

  @override
  String get sendCode => 'Recevoir le code';

  @override
  String get codeTitle => 'Code reçu par SMS';

  @override
  String codeBody(String numero) {
    return 'Saisissez le code à 6 chiffres envoyé au $numero.';
  }

  @override
  String get codeLabel => 'Code à 6 chiffres';

  @override
  String get verifyCode => 'Valider le code';

  @override
  String resendIn(int secondes) {
    return 'Renvoyer le code dans $secondes s';
  }

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get changeNumber => 'Changer de numéro';

  @override
  String codeSent(String numero) {
    return 'Code envoyé au $numero.';
  }

  @override
  String get errCodeRefused =>
      'Code incorrect ou trop ancien. Vérifiez le SMS ou demandez un nouveau code.';

  @override
  String get errTooManyRequests =>
      'Trop de demandes. Attendez une minute avant de réessayer.';

  @override
  String get errSmsFailed => 'Le SMS n\'a pas pu partir. Vérifiez le numéro.';

  @override
  String get errNetwork =>
      'Pas de connexion internet. Vérifiez vos données mobiles, puis réessayez.';

  @override
  String get errOther =>
      'Une erreur s\'est produite. Réessayez dans un instant.';

  @override
  String get errOtherAccount =>
      'Ce téléphone est déjà relié au compte d\'un autre numéro. Connectez-vous avec ce numéro-là.';

  @override
  String get restoring => 'Récupération de vos données…';

  @override
  String get shopTitle => 'Votre boutique';

  @override
  String get shopBody =>
      'Ces informations restent modifiables plus tard dans Réglages.';

  @override
  String get shopName => 'Nom de la boutique';

  @override
  String get shopNameHint => 'Par exemple : Chez Maman Brigitte';

  @override
  String get errShopName => 'Saisissez le nom de la boutique.';

  @override
  String get shopType => 'Type de commerce';

  @override
  String get typeFood => 'Alimentation, épicerie';

  @override
  String get typeNeighborhood => 'Boutique de quartier';

  @override
  String get typeHardware => 'Quincaillerie';

  @override
  String get typeBeauty => 'Cosmétiques';

  @override
  String get typeClothes => 'Vêtements, chaussures';

  @override
  String get typePhones => 'Téléphones, accessoires';

  @override
  String get typeOther => 'Autre';

  @override
  String get city => 'Ville';

  @override
  String get cityHint => 'Par exemple : Douala';

  @override
  String get errCity => 'Saisissez la ville.';

  @override
  String get district => 'Quartier';

  @override
  String get districtHint => 'Par exemple : Akwa';

  @override
  String get errDistrict => 'Saisissez le quartier.';

  @override
  String get pinChoose => 'Code PIN à 4 chiffres';

  @override
  String get pinChooseHint =>
      'Il protège l\'app si quelqu\'un d\'autre prend votre téléphone.';

  @override
  String get pinConfirm => 'Confirmez le code PIN';

  @override
  String get errPinFormat => 'Le code PIN doit avoir 4 chiffres.';

  @override
  String get errPinMismatch =>
      'Les deux codes ne sont pas pareils. Saisissez-les à nouveau.';

  @override
  String get createShop => 'Créer ma boutique';

  @override
  String get pinTitle => 'Entrez votre code PIN';

  @override
  String pinProgress(int n) {
    return '$n chiffres sur 4 saisis';
  }

  @override
  String pinWrong(int restants) {
    String _temp0 = intl.Intl.pluralLogic(
      restants,
      locale: localeName,
      other: 'Code incorrect. Il reste $restants essais.',
      one: 'Code incorrect. Il reste 1 essai.',
    );
    return '$_temp0';
  }

  @override
  String pinLocked(int secondes) {
    return 'Trop d\'essais. Réessayez dans $secondes s.';
  }

  @override
  String get pinForgot => 'Code oublié';

  @override
  String get pinForgotBody =>
      'Nous vous envoyons un code par SMS, puis vous choisissez un nouveau code PIN.';

  @override
  String get newPinTitle => 'Choisissez un nouveau code PIN';

  @override
  String get newPinConfirmTitle => 'Saisissez-le encore une fois';

  @override
  String get pinChanged => 'Code PIN changé.';

  @override
  String get errPinOtherNumber =>
      'Ce numéro n\'est pas celui du compte de ce téléphone.';

  @override
  String get loading => 'Chargement…';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsHint => 'Langue, abonnement, compte';

  @override
  String get settingsSubscription => 'Abonnement';

  @override
  String get settingsBackup => 'Sauvegarde';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get backupNow => 'Sauvegarder maintenant';

  @override
  String get backupDone => 'Tout est sauvegardé en ligne.';

  @override
  String get backupFailed =>
      'Sauvegarde impossible pour l\'instant. Vos données restent sur ce téléphone ; Kassa réessaiera quand internet reviendra.';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logoutTitle => 'Se déconnecter de ce téléphone ?';

  @override
  String get logoutBody =>
      'Les données de la boutique seront effacées de ce téléphone. Elles restent sauvegardées en ligne et reviendront quand vous vous reconnecterez avec votre numéro.';

  @override
  String logoutPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other:
          '$n changements ne sont pas encore sauvegardés en ligne : ils seront perdus.',
      one:
          '1 changement n\'est pas encore sauvegardé en ligne : il sera perdu.',
    );
    return '$_temp0';
  }

  @override
  String get logoutLocalOnly =>
      'Cette boutique n\'est pas sauvegardée en ligne : toutes ses données seront perdues.';

  @override
  String get logoutConfirm => 'Effacer et se déconnecter';

  @override
  String get proTitle => 'Kassa Pro';

  @override
  String trialDaysLeft(int jours) {
    String _temp0 = intl.Intl.pluralLogic(
      jours,
      locale: localeName,
      other: 'Essai gratuit : $jours jours restants',
      one: 'Essai gratuit : 1 jour restant',
      zero: 'Dernier jour d\'essai gratuit',
    );
    return '$_temp0';
  }

  @override
  String trialUntil(String date) {
    return 'Essai gratuit jusqu\'au $date';
  }

  @override
  String proUntil(String date) {
    return 'Kassa Pro jusqu\'au $date';
  }

  @override
  String get trialEnded => 'Votre essai gratuit est terminé';

  @override
  String get proEnded => 'Votre abonnement Pro est terminé';

  @override
  String readOnlyBody(String prix) {
    return 'Vos ventes, votre stock et vos dettes restent visibles. Pour enregistrer à nouveau, passez à Kassa Pro : $prix par mois.';
  }

  @override
  String trialEndingBody(String prix) {
    return 'Après l\'essai, Kassa Pro coûte $prix par mois pour continuer à enregistrer.';
  }

  @override
  String proPrice(String prix) {
    return '$prix / mois';
  }

  @override
  String get proBenefitRecord =>
      'Enregistrez ventes, stock et dettes sans limite.';

  @override
  String get proBenefitBackup => 'Vos données restent sauvegardées en ligne.';

  @override
  String get proBenefitDays =>
      'Les jours qui restent ne sont pas perdus : le mois payé s\'ajoute à la fin.';

  @override
  String get payWith => 'Payer avec';

  @override
  String get payPhoneLabel => 'Numéro Mobile Money';

  @override
  String payButton(String prix) {
    return 'Payer $prix';
  }

  @override
  String get payWaitingTitle => 'Validez le paiement sur votre téléphone';

  @override
  String payWaitingBody(String operateur, String numero, String prix) {
    return 'Un message $operateur va s\'afficher sur le $numero. Entrez votre code secret Mobile Money pour payer $prix.';
  }

  @override
  String get payWaitingLater => 'Revenir plus tard';

  @override
  String paySuccess(String date) {
    return 'Merci. Kassa Pro est activé jusqu\'au $date.';
  }

  @override
  String get payFailed =>
      'Le paiement n\'a pas abouti. Vérifiez votre solde Mobile Money, puis réessayez.';

  @override
  String get payTimeout =>
      'Pas encore de réponse. Si vous avez payé, Kassa Pro s\'activera tout seul dans quelques minutes.';

  @override
  String get payPending =>
      'Un paiement attend déjà votre validation. Regardez votre téléphone, ou réessayez dans 5 minutes.';

  @override
  String get payRefused =>
      'La demande de paiement a été refusée. Vérifiez le numéro et l\'opérateur, puis réessayez.';

  @override
  String get payUnavailable =>
      'Le paiement en ligne n\'est pas disponible sur cette version de Kassa.';

  @override
  String get payExtend => 'Payer un mois de plus';
}
