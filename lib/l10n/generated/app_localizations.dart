import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
  ];

  /// Nom de l'application (ne se traduit pas).
  ///
  /// In fr, this message translates to:
  /// **'Kassa'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Ventes, stock et dettes, même sans internet.'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navSell.
  ///
  /// In fr, this message translates to:
  /// **'Vendre'**
  String get navSell;

  /// No description provided for @navStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get navStock;

  /// No description provided for @navCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get navCustomers;

  /// No description provided for @newSale.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle vente'**
  String get newSale;

  /// No description provided for @collectPayment.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser'**
  String get collectPayment;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @restock.
  ///
  /// In fr, this message translates to:
  /// **'Réappro'**
  String get restock;

  /// Montant dû par un client. Toujours devant un montant de dette.
  ///
  /// In fr, this message translates to:
  /// **'Doit {montant}'**
  String owes(String montant);

  /// No description provided for @paidUp.
  ///
  /// In fr, this message translates to:
  /// **'À jour'**
  String get paidUp;

  /// No description provided for @remind.
  ///
  /// In fr, this message translates to:
  /// **'Rappeler'**
  String get remind;

  /// No description provided for @lowStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock bas'**
  String get lowStock;

  /// No description provided for @todaySales.
  ///
  /// In fr, this message translates to:
  /// **'Ventes du jour'**
  String get todaySales;

  /// No description provided for @moneyOwed.
  ///
  /// In fr, this message translates to:
  /// **'Dettes à recevoir'**
  String get moneyOwed;

  /// État de la sauvegarde en ligne. Ne jamais dire « synchronisation ».
  ///
  /// In fr, this message translates to:
  /// **'Sauvegardé'**
  String get saved;

  /// No description provided for @goPro.
  ///
  /// In fr, this message translates to:
  /// **'Passer à Pro'**
  String get goPro;

  /// No description provided for @cancelSale.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la vente'**
  String get cancelSale;

  /// No description provided for @youSoldToday.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez vendu {montant} aujourd\'hui.'**
  String youSoldToday(String montant);

  /// No description provided for @todayProfit.
  ///
  /// In fr, this message translates to:
  /// **'Bénéfice du jour'**
  String get todayProfit;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languagePhone.
  ///
  /// In fr, this message translates to:
  /// **'Langue du téléphone'**
  String get languagePhone;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @previewStepNote.
  ///
  /// In fr, this message translates to:
  /// **'Écran de démonstration des composants (étape 3). Il sera remplacé par l\'accueil.'**
  String get previewStepNote;

  /// Mot placé devant un montant dû (le montant suit, plus grand).
  ///
  /// In fr, this message translates to:
  /// **'Doit'**
  String get owesLabel;

  /// Libellé pour lecteur d'écran d'une carte produit.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter {nom} au panier'**
  String addToCart(String nom);

  /// No description provided for @inCart.
  ///
  /// In fr, this message translates to:
  /// **'{quantite} dans le panier'**
  String inCart(String quantite);

  /// Stock restant sous un produit.
  ///
  /// In fr, this message translates to:
  /// **'{quantite} {unite}'**
  String stockLeft(String quantite, String unite);

  /// No description provided for @remindOnWhatsapp.
  ///
  /// In fr, this message translates to:
  /// **'Rappeler {nom} sur WhatsApp'**
  String remindOnWhatsapp(String nom);

  /// Touche du pavé numérique qui efface le dernier chiffre.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get erase;

  /// No description provided for @stockAlerts.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =1{1 produit en stock bas} other{{nombre} produits en stock bas}}'**
  String stockAlerts(int nombre);

  /// No description provided for @salesCount.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =0{Aucune vente} =1{1 vente} other{{nombre} ventes}}'**
  String salesCount(int nombre);

  /// No description provided for @customersCount.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =0{Aucun client} =1{1 client} other{{nombre} clients}}'**
  String customersCount(int nombre);

  /// No description provided for @lastPurchase.
  ///
  /// In fr, this message translates to:
  /// **'Dernier achat le {date}'**
  String lastPurchase(String date);

  /// No description provided for @later.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get later;

  /// No description provided for @paid.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get paid;

  /// No description provided for @cancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get cancelled;

  /// No description provided for @demoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Composants Kassa'**
  String get demoTitle;

  /// No description provided for @demoButtons.
  ///
  /// In fr, this message translates to:
  /// **'Boutons'**
  String get demoButtons;

  /// No description provided for @demoBadges.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get demoBadges;

  /// No description provided for @demoAmounts.
  ///
  /// In fr, this message translates to:
  /// **'Montants'**
  String get demoAmounts;

  /// No description provided for @demoStats.
  ///
  /// In fr, this message translates to:
  /// **'Chiffres clés'**
  String get demoStats;

  /// No description provided for @demoProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get demoProducts;

  /// No description provided for @demoProductsHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez une carte pour l\'ajouter au panier.'**
  String get demoProductsHint;

  /// No description provided for @demoCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get demoCustomers;

  /// No description provided for @demoNumPad.
  ///
  /// In fr, this message translates to:
  /// **'Pavé numérique'**
  String get demoNumPad;

  /// No description provided for @demoReminderSent.
  ///
  /// In fr, this message translates to:
  /// **'Rappel prêt pour {nom}.'**
  String demoReminderSent(String nom);

  /// Action de l'appui long sur une carte produit (lecteur d'écran).
  ///
  /// In fr, this message translates to:
  /// **'Saisir une quantité'**
  String get enterQuantity;

  /// Étiquette de la formule payante (nom de la formule, identique en anglais).
  ///
  /// In fr, this message translates to:
  /// **'Pro'**
  String get proBadge;

  /// No description provided for @searchProducts.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit'**
  String get searchProducts;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAll;

  /// No description provided for @filterLowStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock bas ({nombre})'**
  String filterLowStock(int nombre);

  /// No description provided for @noCategory.
  ///
  /// In fr, this message translates to:
  /// **'Sans catégorie'**
  String get noCategory;

  /// No description provided for @addProduct.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un produit'**
  String get addProduct;

  /// No description provided for @stockEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit pour l\'instant'**
  String get stockEmptyTitle;

  /// No description provided for @stockEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos produits pour suivre le stock et commencer à vendre.'**
  String get stockEmptyBody;

  /// No description provided for @stockNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit ne correspond à « {recherche} ». Vérifiez l\'orthographe ou ajoutez ce produit.'**
  String stockNoResult(String recherche);

  /// No description provided for @stockNoLowStock.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit en stock bas. Tout est au-dessus du seuil d\'alerte.'**
  String get stockNoLowStock;

  /// No description provided for @stockNoInCategory.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit dans cette catégorie.'**
  String get stockNoInCategory;

  /// No description provided for @stockOf.
  ///
  /// In fr, this message translates to:
  /// **'Stock : {quantite}'**
  String stockOf(String quantite);

  /// No description provided for @restockProduct.
  ///
  /// In fr, this message translates to:
  /// **'Réappro {nom}'**
  String restockProduct(String nom);

  /// No description provided for @productNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau produit'**
  String get productNewTitle;

  /// No description provided for @productEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le produit'**
  String get productEditTitle;

  /// No description provided for @fieldName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du produit'**
  String get fieldName;

  /// No description provided for @fieldNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Riz parfumé 5 kg'**
  String get fieldNameHint;

  /// No description provided for @fieldCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get fieldCategory;

  /// No description provided for @newCategory.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie'**
  String get newCategory;

  /// No description provided for @fieldPurchasePrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get fieldPurchasePrice;

  /// No description provided for @fieldPurchasePriceHelp.
  ///
  /// In fr, this message translates to:
  /// **'Ce que vous payez pour une unité.'**
  String get fieldPurchasePriceHelp;

  /// No description provided for @fieldSalePrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente'**
  String get fieldSalePrice;

  /// No description provided for @fieldSalePriceHelp.
  ///
  /// In fr, this message translates to:
  /// **'Le prix demandé au client pour une unité.'**
  String get fieldSalePriceHelp;

  /// No description provided for @fieldQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité en stock'**
  String get fieldQuantity;

  /// No description provided for @fieldQuantityHelpNew.
  ///
  /// In fr, this message translates to:
  /// **'Ce que vous avez aujourd\'hui. Mettez 0 si vous n\'en avez pas.'**
  String get fieldQuantityHelpNew;

  /// No description provided for @fieldQuantityHelpEdit.
  ///
  /// In fr, this message translates to:
  /// **'Changer ce nombre enregistre une correction du stock.'**
  String get fieldQuantityHelpEdit;

  /// No description provided for @fieldUnit.
  ///
  /// In fr, this message translates to:
  /// **'Unité'**
  String get fieldUnit;

  /// No description provided for @fieldThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Alerte de stock bas'**
  String get fieldThreshold;

  /// No description provided for @fieldThresholdHelp.
  ///
  /// In fr, this message translates to:
  /// **'Kassa vous prévient quand il en reste ce nombre ou moins.'**
  String get fieldThresholdHelp;

  /// No description provided for @photoAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get photoAdd;

  /// No description provided for @photoChange.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get photoChange;

  /// No description provided for @photoTake.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get photoTake;

  /// No description provided for @photoGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get photoGallery;

  /// No description provided for @photoRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la photo'**
  String get photoRemove;

  /// No description provided for @photoError.
  ///
  /// In fr, this message translates to:
  /// **'La photo n\'a pas pu être ajoutée. Réessayez ou choisissez une autre photo.'**
  String get photoError;

  /// No description provided for @unitPiece.
  ///
  /// In fr, this message translates to:
  /// **'pièce'**
  String get unitPiece;

  /// No description provided for @unitKg.
  ///
  /// In fr, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitLitre.
  ///
  /// In fr, this message translates to:
  /// **'litre'**
  String get unitLitre;

  /// No description provided for @unitCarton.
  ///
  /// In fr, this message translates to:
  /// **'carton'**
  String get unitCarton;

  /// No description provided for @unitBag.
  ///
  /// In fr, this message translates to:
  /// **'sac'**
  String get unitBag;

  /// No description provided for @unitPack.
  ///
  /// In fr, this message translates to:
  /// **'paquet'**
  String get unitPack;

  /// No description provided for @unitBottle.
  ///
  /// In fr, this message translates to:
  /// **'bouteille'**
  String get unitBottle;

  /// No description provided for @unitBox.
  ///
  /// In fr, this message translates to:
  /// **'boîte'**
  String get unitBox;

  /// No description provided for @errNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le nom du produit.'**
  String get errNameRequired;

  /// No description provided for @errPriceRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un prix en francs, sans virgule.'**
  String get errPriceRequired;

  /// No description provided for @errQuantityInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un nombre, par exemple 12 ou 1,5.'**
  String get errQuantityInvalid;

  /// No description provided for @errUnitRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez ou saisissez une unité.'**
  String get errUnitRequired;

  /// No description provided for @warnSellingAtLoss.
  ///
  /// In fr, this message translates to:
  /// **'Le prix de vente est plus bas que le prix d\'achat : vous perdez {montant} par unité.'**
  String warnSellingAtLoss(String montant);

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @productAdded.
  ///
  /// In fr, this message translates to:
  /// **'Produit ajouté.'**
  String get productAdded;

  /// No description provided for @productSaved.
  ///
  /// In fr, this message translates to:
  /// **'Modifications enregistrées.'**
  String get productSaved;

  /// No description provided for @deleteProduct.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le produit'**
  String get deleteProduct;

  /// No description provided for @deleteProductTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer {nom} ?'**
  String deleteProductTitle(String nom);

  /// No description provided for @deleteProductBody.
  ///
  /// In fr, this message translates to:
  /// **'Il ne sera plus proposé à la vente. Les ventes passées restent dans l\'historique.'**
  String get deleteProductBody;

  /// No description provided for @deleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteConfirm;

  /// No description provided for @keep.
  ///
  /// In fr, this message translates to:
  /// **'Garder'**
  String get keep;

  /// No description provided for @productDeleted.
  ///
  /// In fr, this message translates to:
  /// **'{nom} a été supprimé.'**
  String productDeleted(String nom);

  /// No description provided for @productNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ce produit n\'existe plus. Il a peut-être été supprimé.'**
  String get productNotFound;

  /// No description provided for @saveError.
  ///
  /// In fr, this message translates to:
  /// **'L\'enregistrement a échoué. Réessayez ; vos données sont toujours sur le téléphone.'**
  String get saveError;

  /// No description provided for @categoryName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la catégorie'**
  String get categoryName;

  /// No description provided for @categoryCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get categoryCreate;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @errCategoryName.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un nom de catégorie.'**
  String get errCategoryName;

  /// No description provided for @categoryQuickPick.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un modèle ou saisissez un nom.'**
  String get categoryQuickPick;

  /// No description provided for @catGrocery.
  ///
  /// In fr, this message translates to:
  /// **'Épicerie'**
  String get catGrocery;

  /// No description provided for @catDrinks.
  ///
  /// In fr, this message translates to:
  /// **'Boissons'**
  String get catDrinks;

  /// No description provided for @catHygiene.
  ///
  /// In fr, this message translates to:
  /// **'Hygiène'**
  String get catHygiene;

  /// No description provided for @catHousehold.
  ///
  /// In fr, this message translates to:
  /// **'Ménage'**
  String get catHousehold;

  /// No description provided for @catFresh.
  ///
  /// In fr, this message translates to:
  /// **'Frais'**
  String get catFresh;

  /// No description provided for @catOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get catOther;

  /// No description provided for @restockChooseProduct.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le produit reçu.'**
  String get restockChooseProduct;

  /// No description provided for @currentStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock actuel : {quantite}'**
  String currentStock(String quantite);

  /// No description provided for @currentPurchasePrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat actuel : {montant}'**
  String currentPurchasePrice(String montant);

  /// No description provided for @fieldReceivedQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité reçue'**
  String get fieldReceivedQuantity;

  /// No description provided for @fieldNewPurchasePriceHelp.
  ///
  /// In fr, this message translates to:
  /// **'Changez-le si votre fournisseur a changé son prix.'**
  String get fieldNewPurchasePriceHelp;

  /// No description provided for @newStockPreview.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau stock : {quantite}'**
  String newStockPreview(String quantite);

  /// No description provided for @addToStock.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au stock'**
  String get addToStock;

  /// No description provided for @errReceivedQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez la quantité reçue, plus grande que 0.'**
  String get errReceivedQuantity;

  /// No description provided for @stockUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Stock mis à jour : {quantite}.'**
  String stockUpdated(String quantite);

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Cet écran arrive dans une prochaine version.'**
  String get comingSoon;

  /// No description provided for @loadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire vos produits. Fermez puis rouvrez l\'app ; vos données restent sur le téléphone.'**
  String get loadError;

  /// No description provided for @history.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get history;

  /// No description provided for @productsCount.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =1{1 produit} other{{nombre} produits}}'**
  String productsCount(int nombre);

  /// No description provided for @cartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Panier'**
  String get cartTitle;

  /// No description provided for @cartEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez un produit pour l\'ajouter. Appui long pour choisir la quantité.'**
  String get cartEmptyHint;

  /// No description provided for @sellNoProductsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit à vendre'**
  String get sellNoProductsTitle;

  /// No description provided for @sellNoProductsBody.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos produits dans l\'onglet Stock pour commencer à vendre.'**
  String get sellNoProductsBody;

  /// No description provided for @clearCart.
  ///
  /// In fr, this message translates to:
  /// **'Vider le panier'**
  String get clearCart;

  /// No description provided for @cartCleared.
  ///
  /// In fr, this message translates to:
  /// **'Panier vidé.'**
  String get cartCleared;

  /// No description provided for @undo.
  ///
  /// In fr, this message translates to:
  /// **'Rétablir'**
  String get undo;

  /// No description provided for @removeFromCart.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get removeFromCart;

  /// No description provided for @increaseQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter 1 {nom}'**
  String increaseQuantity(String nom);

  /// No description provided for @decreaseQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Enlever 1 {nom}'**
  String decreaseQuantity(String nom);

  /// No description provided for @quantityOf.
  ///
  /// In fr, this message translates to:
  /// **'Quantité de {nom}'**
  String quantityOf(String nom);

  /// No description provided for @putInCart.
  ///
  /// In fr, this message translates to:
  /// **'Mettre au panier'**
  String get putInCart;

  /// No description provided for @stockInsufficient.
  ///
  /// In fr, this message translates to:
  /// **'Stock insuffisant : il reste {quantite}. La vente reste possible.'**
  String stockInsufficient(String quantite);

  /// No description provided for @decimalSeparator.
  ///
  /// In fr, this message translates to:
  /// **'Virgule'**
  String get decimalSeparator;

  /// No description provided for @paymentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get paymentTitle;

  /// No description provided for @saleTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total de la vente'**
  String get saleTotal;

  /// No description provided for @totalToPay.
  ///
  /// In fr, this message translates to:
  /// **'Total à payer'**
  String get totalToPay;

  /// No description provided for @payCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get payCash;

  /// No description provided for @payMomo.
  ///
  /// In fr, this message translates to:
  /// **'MTN MoMo'**
  String get payMomo;

  /// No description provided for @payOrange.
  ///
  /// In fr, this message translates to:
  /// **'Orange Money'**
  String get payOrange;

  /// No description provided for @payCredit.
  ///
  /// In fr, this message translates to:
  /// **'Crédit'**
  String get payCredit;

  /// No description provided for @amountReceived.
  ///
  /// In fr, this message translates to:
  /// **'Montant reçu'**
  String get amountReceived;

  /// No description provided for @amountReceivedHint.
  ///
  /// In fr, this message translates to:
  /// **'Rien à saisir si le client donne le montant exact.'**
  String get amountReceivedHint;

  /// No description provided for @changeToGive.
  ///
  /// In fr, this message translates to:
  /// **'Monnaie à rendre'**
  String get changeToGive;

  /// No description provided for @missingAmount.
  ///
  /// In fr, this message translates to:
  /// **'Il manque {montant}. Encaissez plus, ou choisissez Crédit pour noter une dette.'**
  String missingAmount(String montant);

  /// No description provided for @mobileMoneyHint.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez que les {montant} sont bien arrivés sur votre téléphone avant d\'encaisser.'**
  String mobileMoneyHint(String montant);

  /// No description provided for @advancePaid.
  ///
  /// In fr, this message translates to:
  /// **'Avance payée maintenant'**
  String get advancePaid;

  /// No description provided for @advancePaidHint.
  ///
  /// In fr, this message translates to:
  /// **'Laissez 0 si le client ne paie rien aujourd\'hui.'**
  String get advancePaidHint;

  /// No description provided for @remainingDebt.
  ///
  /// In fr, this message translates to:
  /// **'Reste à payer'**
  String get remainingDebt;

  /// No description provided for @customer.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get customer;

  /// No description provided for @chooseCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le client'**
  String get chooseCustomer;

  /// No description provided for @changeCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Changer'**
  String get changeCustomer;

  /// No description provided for @newCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau client'**
  String get newCustomer;

  /// No description provided for @customerName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du client'**
  String get customerName;

  /// No description provided for @customerPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone (facultatif)'**
  String get customerPhone;

  /// No description provided for @customerPhoneHint.
  ///
  /// In fr, this message translates to:
  /// **'Pour lui envoyer un rappel WhatsApp.'**
  String get customerPhoneHint;

  /// No description provided for @errCustomerName.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le nom du client.'**
  String get errCustomerName;

  /// No description provided for @addCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter le client'**
  String get addCustomer;

  /// No description provided for @searchCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un client'**
  String get searchCustomers;

  /// No description provided for @noCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client pour l\'instant. Ajoutez-le avec « Nouveau client ».'**
  String get noCustomers;

  /// No description provided for @errChooseCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le client qui prend à crédit.'**
  String get errChooseCustomer;

  /// No description provided for @collectAmount.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser {montant}'**
  String collectAmount(String montant);

  /// No description provided for @sellOnCredit.
  ///
  /// In fr, this message translates to:
  /// **'Vendre à crédit'**
  String get sellOnCredit;

  /// No description provided for @saleRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Vente n°{numero} enregistrée : {montant}.'**
  String saleRecorded(int numero, String montant);

  /// No description provided for @saleRecordedChange.
  ///
  /// In fr, this message translates to:
  /// **'Vente n°{numero} enregistrée. Rendez {monnaie}.'**
  String saleRecordedChange(int numero, String monnaie);

  /// No description provided for @historyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des ventes'**
  String get historyTitle;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get yesterday;

  /// No description provided for @chooseDate.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une date'**
  String get chooseDate;

  /// No description provided for @allDates.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les dates'**
  String get allDates;

  /// No description provided for @saleNumber.
  ///
  /// In fr, this message translates to:
  /// **'Vente n°{numero}'**
  String saleNumber(int numero);

  /// No description provided for @saleNumberTime.
  ///
  /// In fr, this message translates to:
  /// **'N°{numero} · {heure}'**
  String saleNumberTime(int numero, String heure);

  /// No description provided for @historyEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vente pour l\'instant'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos ventes apparaîtront ici dès la première.'**
  String get historyEmptyBody;

  /// No description provided for @historyEmptyDay.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vente ce jour-là. Choisissez une autre date.'**
  String get historyEmptyDay;

  /// No description provided for @daySummary.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =1{1 vente} other{{nombre} ventes}} · {montant}'**
  String daySummary(int nombre, String montant);

  /// No description provided for @saleDateTime.
  ///
  /// In fr, this message translates to:
  /// **'Le {date} à {heure}'**
  String saleDateTime(String date, String heure);

  /// No description provided for @products.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get products;

  /// No description provided for @profit.
  ///
  /// In fr, this message translates to:
  /// **'Bénéfice'**
  String get profit;

  /// No description provided for @paymentMode.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get paymentMode;

  /// No description provided for @lineDetail.
  ///
  /// In fr, this message translates to:
  /// **'{quantite} × {prix}'**
  String lineDetail(String quantite, String prix);

  /// No description provided for @cancelSaleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la vente n°{numero} ?'**
  String cancelSaleTitle(int numero);

  /// No description provided for @cancelSaleBody.
  ///
  /// In fr, this message translates to:
  /// **'Le stock sera remis et la dette du client retirée. La vente reste dans l\'historique, marquée Annulée.'**
  String get cancelSaleBody;

  /// No description provided for @keepSale.
  ///
  /// In fr, this message translates to:
  /// **'Garder la vente'**
  String get keepSale;

  /// No description provided for @errCancelRepaid.
  ///
  /// In fr, this message translates to:
  /// **'Le client a déjà remboursé une partie de cette vente : impossible de l\'annuler.'**
  String get errCancelRepaid;

  /// No description provided for @saleCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Vente n°{numero} annulée. Le stock a été remis.'**
  String saleCancelled(int numero);

  /// No description provided for @saleNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette vente n\'existe plus.'**
  String get saleNotFound;

  /// No description provided for @debtorsCount.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =0{Personne ne vous doit d\'argent} =1{1 client vous doit de l\'argent} other{{nombre} clients vous doivent de l\'argent}}'**
  String debtorsCount(int nombre);

  /// No description provided for @lastPurchaseOn.
  ///
  /// In fr, this message translates to:
  /// **'Dernier achat le {date}'**
  String lastPurchaseOn(String date);

  /// No description provided for @lastPurchaseToday.
  ///
  /// In fr, this message translates to:
  /// **'Dernier achat aujourd\'hui'**
  String get lastPurchaseToday;

  /// No description provided for @lastPurchaseYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Dernier achat hier'**
  String get lastPurchaseYesterday;

  /// No description provided for @customersEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client pour l\'instant'**
  String get customersEmptyTitle;

  /// No description provided for @customersEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos clients pour suivre ce qu\'ils vous doivent.'**
  String get customersEmptyBody;

  /// No description provided for @noCustomerMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client ne correspond à « {texte} ».'**
  String noCustomerMatch(String texte);

  /// No description provided for @reminderMessageNoShop.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {nom}, il vous reste {montant} à payer. Merci.'**
  String reminderMessageNoShop(String nom, String montant);

  /// No description provided for @whatsappError.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp ne s\'ouvre pas. Vérifiez qu\'il est installé sur ce téléphone.'**
  String get whatsappError;

  /// No description provided for @addPhoneToRemind.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez son numéro pour lui envoyer un rappel WhatsApp.'**
  String get addPhoneToRemind;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @balance.
  ///
  /// In fr, this message translates to:
  /// **'Solde'**
  String get balance;

  /// No description provided for @customerHistoryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun achat ni versement pour l\'instant.'**
  String get customerHistoryEmpty;

  /// No description provided for @purchaseNumber.
  ///
  /// In fr, this message translates to:
  /// **'Achat · N°{numero}'**
  String purchaseNumber(int numero);

  /// No description provided for @creditPurchaseNumber.
  ///
  /// In fr, this message translates to:
  /// **'Achat à crédit · N°{numero}'**
  String creditPurchaseNumber(int numero);

  /// No description provided for @debtPayment.
  ///
  /// In fr, this message translates to:
  /// **'Versement · {mode}'**
  String debtPayment(String mode);

  /// No description provided for @customerNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ce client n\'existe plus.'**
  String get customerNotFound;

  /// No description provided for @collectDebtTitle.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser une dette'**
  String get collectDebtTitle;

  /// No description provided for @amountPaidNow.
  ///
  /// In fr, this message translates to:
  /// **'Montant versé'**
  String get amountPaidNow;

  /// No description provided for @amountPaidNowHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez « Toute la dette » si le client paie tout.'**
  String get amountPaidNowHint;

  /// No description provided for @wholeDebt.
  ///
  /// In fr, this message translates to:
  /// **'Toute la dette · {montant}'**
  String wholeDebt(String montant);

  /// No description provided for @remainingAfterPayment.
  ///
  /// In fr, this message translates to:
  /// **'Il restera à payer'**
  String get remainingAfterPayment;

  /// No description provided for @debtPaidOffLabel.
  ///
  /// In fr, this message translates to:
  /// **'Dette soldée'**
  String get debtPaidOffLabel;

  /// No description provided for @errPaymentTooHigh.
  ///
  /// In fr, this message translates to:
  /// **'{nom} ne doit que {montant}. Baissez le montant.'**
  String errPaymentTooHigh(String nom, String montant);

  /// No description provided for @paymentRecordedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Versement enregistré'**
  String get paymentRecordedTitle;

  /// No description provided for @paymentRecordedBody.
  ///
  /// In fr, this message translates to:
  /// **'{montant} reçus de {nom}.'**
  String paymentRecordedBody(String montant, String nom);

  /// No description provided for @paymentRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Il reste {montant} à payer.'**
  String paymentRemaining(String montant);

  /// No description provided for @paymentPaidOff.
  ///
  /// In fr, this message translates to:
  /// **'Sa dette est soldée.'**
  String get paymentPaidOff;

  /// No description provided for @sendReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le reçu'**
  String get sendReceipt;

  /// No description provided for @done.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get done;

  /// No description provided for @receiptMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {nom}, le {date}, nous avons bien reçu {montant}.'**
  String receiptMessage(String nom, String montant, String date);

  /// No description provided for @receiptRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Il vous reste {montant} à payer. Merci.'**
  String receiptRemaining(String montant);

  /// No description provided for @receiptPaidOff.
  ///
  /// In fr, this message translates to:
  /// **'Votre dette est soldée. Merci.'**
  String get receiptPaidOff;

  /// No description provided for @editCustomerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le client'**
  String get editCustomerTitle;

  /// No description provided for @customerNote.
  ///
  /// In fr, this message translates to:
  /// **'Note (facultatif)'**
  String get customerNote;

  /// No description provided for @customerNoteHint.
  ///
  /// In fr, this message translates to:
  /// **'Par exemple : paie en fin de mois.'**
  String get customerNoteHint;

  /// No description provided for @errCustomerPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide. Saisissez 9 chiffres, par exemple 6 77 12 34 56.'**
  String get errCustomerPhone;

  /// No description provided for @deleteCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le client'**
  String get deleteCustomer;

  /// No description provided for @deleteCustomerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer {nom} ?'**
  String deleteCustomerTitle(String nom);

  /// No description provided for @deleteCustomerBody.
  ///
  /// In fr, this message translates to:
  /// **'Il ne sera plus dans votre liste. Ses achats restent dans l\'historique des ventes.'**
  String get deleteCustomerBody;

  /// No description provided for @errDeleteIndebted.
  ///
  /// In fr, this message translates to:
  /// **'{nom} doit encore {montant}. Encaissez sa dette avant de le supprimer.'**
  String errDeleteIndebted(String nom, String montant);

  /// No description provided for @customerDeleted.
  ///
  /// In fr, this message translates to:
  /// **'{nom} a été supprimé.'**
  String customerDeleted(String nom);

  /// No description provided for @dateAndTotal.
  ///
  /// In fr, this message translates to:
  /// **'{date} · Total {total}'**
  String dateAndTotal(String date, String total);

  /// No description provided for @salesAndProfit.
  ///
  /// In fr, this message translates to:
  /// **'{ventes} · bénéfice {montant}'**
  String salesAndProfit(String ventes, String montant);

  /// No description provided for @saveStatePending.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde en attente'**
  String get saveStatePending;

  /// No description provided for @saveStateLocal.
  ///
  /// In fr, this message translates to:
  /// **'Sur ce téléphone'**
  String get saveStateLocal;

  /// No description provided for @saveStateSavedHelp.
  ///
  /// In fr, this message translates to:
  /// **'Tout est sauvegardé en ligne.'**
  String get saveStateSavedHelp;

  /// No description provided for @saveStatePendingHelp.
  ///
  /// In fr, this message translates to:
  /// **'Des changements attendent internet pour être sauvegardés.'**
  String get saveStatePendingHelp;

  /// No description provided for @saveStateLocalHelp.
  ///
  /// In fr, this message translates to:
  /// **'Vos données sont enregistrées sur ce téléphone. La sauvegarde en ligne commencera quand vous créerez votre compte.'**
  String get saveStateLocalHelp;

  /// No description provided for @seeStock.
  ///
  /// In fr, this message translates to:
  /// **'Voir le stock'**
  String get seeStock;

  /// No description provided for @reportsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get reportsTitle;

  /// No description provided for @reportsHint.
  ///
  /// In fr, this message translates to:
  /// **'Jour, semaine, mois et meilleurs produits'**
  String get reportsHint;

  /// No description provided for @homeNoProductsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos produits pour commencer'**
  String get homeNoProductsTitle;

  /// No description provided for @homeNoProductsBody.
  ///
  /// In fr, this message translates to:
  /// **'Avec vos produits et leurs prix, une vente se fait en quelques touchers.'**
  String get homeNoProductsBody;

  /// No description provided for @periodDay.
  ///
  /// In fr, this message translates to:
  /// **'Jour'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In fr, this message translates to:
  /// **'Semaine'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get periodMonth;

  /// No description provided for @periodEarlier.
  ///
  /// In fr, this message translates to:
  /// **'Avant'**
  String get periodEarlier;

  /// No description provided for @periodLater.
  ///
  /// In fr, this message translates to:
  /// **'Après'**
  String get periodLater;

  /// No description provided for @periodEarlierHint.
  ///
  /// In fr, this message translates to:
  /// **'Période précédente'**
  String get periodEarlierHint;

  /// No description provided for @periodLaterHint.
  ///
  /// In fr, this message translates to:
  /// **'Période suivante'**
  String get periodLaterHint;

  /// No description provided for @thisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In fr, this message translates to:
  /// **'La semaine dernière'**
  String get lastWeek;

  /// No description provided for @weekRange.
  ///
  /// In fr, this message translates to:
  /// **'Du {debut} au {fin}'**
  String weekRange(String debut, String fin);

  /// No description provided for @thisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois-ci'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In fr, this message translates to:
  /// **'Le mois dernier'**
  String get lastMonth;

  /// No description provided for @salesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get salesLabel;

  /// No description provided for @averageSale.
  ///
  /// In fr, this message translates to:
  /// **'Vente moyenne : {montant}'**
  String averageSale(String montant);

  /// No description provided for @moneyReceivedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Argent reçu'**
  String get moneyReceivedTitle;

  /// No description provided for @paidAtSale.
  ///
  /// In fr, this message translates to:
  /// **'Payé à la vente'**
  String get paidAtSale;

  /// No description provided for @soldOnCredit.
  ///
  /// In fr, this message translates to:
  /// **'Vendu à crédit'**
  String get soldOnCredit;

  /// No description provided for @debtsCollected.
  ///
  /// In fr, this message translates to:
  /// **'Dettes encaissées'**
  String get debtsCollected;

  /// No description provided for @totalReceived.
  ///
  /// In fr, this message translates to:
  /// **'Total reçu'**
  String get totalReceived;

  /// No description provided for @salesByMode.
  ///
  /// In fr, this message translates to:
  /// **'Ventes par mode de paiement'**
  String get salesByMode;

  /// No description provided for @bestSellers.
  ///
  /// In fr, this message translates to:
  /// **'Meilleurs produits'**
  String get bestSellers;

  /// No description provided for @bestSellerDetail.
  ///
  /// In fr, this message translates to:
  /// **'{quantite} vendus · bénéfice {benefice}'**
  String bestSellerDetail(String quantite, String benefice);

  /// No description provided for @bestSellerRank.
  ///
  /// In fr, this message translates to:
  /// **'N°{rang}'**
  String bestSellerRank(int rang);

  /// No description provided for @reportEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vente sur cette période.'**
  String get reportEmpty;

  /// No description provided for @cancelledNotCounted.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =1{1 vente annulée n\'est pas comptée.} other{{nombre} ventes annulées ne sont pas comptées.}}'**
  String cancelledNotCounted(int nombre);

  /// No description provided for @welcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre caisse, même sans internet'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In fr, this message translates to:
  /// **'Ventes, stock et dettes de vos clients au même endroit. Il faut internet une seule fois, pour créer votre compte.'**
  String get welcomeBody;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get start;

  /// No description provided for @serverMissing.
  ///
  /// In fr, this message translates to:
  /// **'Cette version de l\'app n\'est pas reliée au serveur Kassa.'**
  String get serverMissing;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre numéro'**
  String get loginTitle;

  /// No description provided for @loginBody.
  ///
  /// In fr, this message translates to:
  /// **'Nous vous envoyons un code par SMS pour vérifier que ce numéro est à vous.'**
  String get loginBody;

  /// No description provided for @phoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get phoneLabel;

  /// No description provided for @errPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide. Saisissez les 9 chiffres, par exemple 6 77 12 34 56.'**
  String get errPhone;

  /// No description provided for @sendCode.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir le code'**
  String get sendCode;

  /// No description provided for @codeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Code reçu par SMS'**
  String get codeTitle;

  /// No description provided for @codeBody.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code à 6 chiffres envoyé au {numero}.'**
  String codeBody(String numero);

  /// No description provided for @codeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code à 6 chiffres'**
  String get codeLabel;

  /// No description provided for @verifyCode.
  ///
  /// In fr, this message translates to:
  /// **'Valider le code'**
  String get verifyCode;

  /// No description provided for @resendIn.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code dans {secondes} s'**
  String resendIn(int secondes);

  /// No description provided for @resendCode.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get resendCode;

  /// No description provided for @changeNumber.
  ///
  /// In fr, this message translates to:
  /// **'Changer de numéro'**
  String get changeNumber;

  /// No description provided for @codeSent.
  ///
  /// In fr, this message translates to:
  /// **'Code envoyé au {numero}.'**
  String codeSent(String numero);

  /// No description provided for @errCodeRefused.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect ou trop ancien. Vérifiez le SMS ou demandez un nouveau code.'**
  String get errCodeRefused;

  /// No description provided for @errTooManyRequests.
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes. Attendez une minute avant de réessayer.'**
  String get errTooManyRequests;

  /// No description provided for @errSmsFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le SMS n\'a pas pu partir. Vérifiez le numéro.'**
  String get errSmsFailed;

  /// No description provided for @errNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet. Vérifiez vos données mobiles, puis réessayez.'**
  String get errNetwork;

  /// No description provided for @errOther.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite. Réessayez dans un instant.'**
  String get errOther;

  /// No description provided for @errOtherAccount.
  ///
  /// In fr, this message translates to:
  /// **'Ce téléphone est déjà relié au compte d\'un autre numéro. Connectez-vous avec ce numéro-là.'**
  String get errOtherAccount;

  /// No description provided for @restoring.
  ///
  /// In fr, this message translates to:
  /// **'Récupération de vos données…'**
  String get restoring;

  /// No description provided for @shopTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre boutique'**
  String get shopTitle;

  /// No description provided for @shopBody.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations restent modifiables plus tard dans Réglages.'**
  String get shopBody;

  /// No description provided for @shopName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la boutique'**
  String get shopName;

  /// No description provided for @shopNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Par exemple : Chez Maman Brigitte'**
  String get shopNameHint;

  /// No description provided for @errShopName.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le nom de la boutique.'**
  String get errShopName;

  /// No description provided for @shopType.
  ///
  /// In fr, this message translates to:
  /// **'Type de commerce'**
  String get shopType;

  /// No description provided for @typeFood.
  ///
  /// In fr, this message translates to:
  /// **'Alimentation, épicerie'**
  String get typeFood;

  /// No description provided for @typeNeighborhood.
  ///
  /// In fr, this message translates to:
  /// **'Boutique de quartier'**
  String get typeNeighborhood;

  /// No description provided for @typeHardware.
  ///
  /// In fr, this message translates to:
  /// **'Quincaillerie'**
  String get typeHardware;

  /// No description provided for @typeBeauty.
  ///
  /// In fr, this message translates to:
  /// **'Cosmétiques'**
  String get typeBeauty;

  /// No description provided for @typeClothes.
  ///
  /// In fr, this message translates to:
  /// **'Vêtements, chaussures'**
  String get typeClothes;

  /// No description provided for @typePhones.
  ///
  /// In fr, this message translates to:
  /// **'Téléphones, accessoires'**
  String get typePhones;

  /// No description provided for @typeOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get typeOther;

  /// No description provided for @city.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get city;

  /// No description provided for @cityHint.
  ///
  /// In fr, this message translates to:
  /// **'Par exemple : Douala'**
  String get cityHint;

  /// No description provided for @errCity.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez la ville.'**
  String get errCity;

  /// No description provided for @district.
  ///
  /// In fr, this message translates to:
  /// **'Quartier'**
  String get district;

  /// No description provided for @districtHint.
  ///
  /// In fr, this message translates to:
  /// **'Par exemple : Akwa'**
  String get districtHint;

  /// No description provided for @errDistrict.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le quartier.'**
  String get errDistrict;

  /// No description provided for @pinChoose.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN à 4 chiffres'**
  String get pinChoose;

  /// No description provided for @pinChooseHint.
  ///
  /// In fr, this message translates to:
  /// **'Il protège l\'app si quelqu\'un d\'autre prend votre téléphone.'**
  String get pinChooseHint;

  /// No description provided for @pinConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez le code PIN'**
  String get pinConfirm;

  /// No description provided for @errPinFormat.
  ///
  /// In fr, this message translates to:
  /// **'Le code PIN doit avoir 4 chiffres.'**
  String get errPinFormat;

  /// No description provided for @errPinMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les deux codes ne sont pas pareils. Saisissez-les à nouveau.'**
  String get errPinMismatch;

  /// No description provided for @createShop.
  ///
  /// In fr, this message translates to:
  /// **'Créer ma boutique'**
  String get createShop;

  /// No description provided for @pinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre code PIN'**
  String get pinTitle;

  /// No description provided for @pinProgress.
  ///
  /// In fr, this message translates to:
  /// **'{n} chiffres sur 4 saisis'**
  String pinProgress(int n);

  /// No description provided for @pinWrong.
  ///
  /// In fr, this message translates to:
  /// **'{restants, plural, =1{Code incorrect. Il reste 1 essai.} other{Code incorrect. Il reste {restants} essais.}}'**
  String pinWrong(int restants);

  /// No description provided for @pinLocked.
  ///
  /// In fr, this message translates to:
  /// **'Trop d\'essais. Réessayez dans {secondes} s.'**
  String pinLocked(int secondes);

  /// No description provided for @pinForgot.
  ///
  /// In fr, this message translates to:
  /// **'Code oublié'**
  String get pinForgot;

  /// No description provided for @pinForgotBody.
  ///
  /// In fr, this message translates to:
  /// **'Nous vous envoyons un code par SMS, puis vous choisissez un nouveau code PIN.'**
  String get pinForgotBody;

  /// No description provided for @newPinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un nouveau code PIN'**
  String get newPinTitle;

  /// No description provided for @newPinConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez-le encore une fois'**
  String get newPinConfirmTitle;

  /// No description provided for @pinChanged.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN changé.'**
  String get pinChanged;

  /// No description provided for @errPinOtherNumber.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro n\'est pas celui du compte de ce téléphone.'**
  String get errPinOtherNumber;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get loading;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsHint.
  ///
  /// In fr, this message translates to:
  /// **'Langue, abonnement, compte'**
  String get settingsHint;

  /// No description provided for @settingsSubscription.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement'**
  String get settingsSubscription;

  /// No description provided for @settingsBackup.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get settingsBackup;

  /// No description provided for @settingsAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get settingsAccount;

  /// No description provided for @backupNow.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder maintenant'**
  String get backupNow;

  /// No description provided for @backupDone.
  ///
  /// In fr, this message translates to:
  /// **'Tout est sauvegardé en ligne.'**
  String get backupDone;

  /// No description provided for @backupFailed.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde impossible pour l\'instant. Vos données restent sur ce téléphone ; Kassa réessaiera quand internet reviendra.'**
  String get backupFailed;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @logoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter de ce téléphone ?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In fr, this message translates to:
  /// **'Les données de la boutique seront effacées de ce téléphone. Elles restent sauvegardées en ligne et reviendront quand vous vous reconnecterez avec votre numéro.'**
  String get logoutBody;

  /// No description provided for @logoutPending.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =1{1 changement n\'est pas encore sauvegardé en ligne : il sera perdu.} other{{n} changements ne sont pas encore sauvegardés en ligne : ils seront perdus.}}'**
  String logoutPending(int n);

  /// No description provided for @logoutLocalOnly.
  ///
  /// In fr, this message translates to:
  /// **'Cette boutique n\'est pas sauvegardée en ligne : toutes ses données seront perdues.'**
  String get logoutLocalOnly;

  /// No description provided for @logoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Effacer et se déconnecter'**
  String get logoutConfirm;

  /// No description provided for @proTitle.
  ///
  /// In fr, this message translates to:
  /// **'Kassa Pro'**
  String get proTitle;

  /// No description provided for @trialDaysLeft.
  ///
  /// In fr, this message translates to:
  /// **'{jours, plural, =1{Dernier jour d\'essai gratuit} other{Essai gratuit : {jours} jours restants}}'**
  String trialDaysLeft(int jours);

  /// No description provided for @trialUntil.
  ///
  /// In fr, this message translates to:
  /// **'Essai gratuit jusqu\'au {date}'**
  String trialUntil(String date);

  /// No description provided for @proUntil.
  ///
  /// In fr, this message translates to:
  /// **'Kassa Pro jusqu\'au {date}'**
  String proUntil(String date);

  /// No description provided for @trialEnded.
  ///
  /// In fr, this message translates to:
  /// **'Votre essai gratuit est terminé'**
  String get trialEnded;

  /// No description provided for @proEnded.
  ///
  /// In fr, this message translates to:
  /// **'Votre abonnement Pro est terminé'**
  String get proEnded;

  /// No description provided for @readOnlyBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos ventes, votre stock et vos dettes restent visibles. Pour enregistrer à nouveau, passez à Kassa Pro : {prix} par mois.'**
  String readOnlyBody(String prix);

  /// No description provided for @trialEndingBody.
  ///
  /// In fr, this message translates to:
  /// **'Après l\'essai, Kassa Pro coûte {prix} par mois pour continuer à enregistrer.'**
  String trialEndingBody(String prix);

  /// No description provided for @proPrice.
  ///
  /// In fr, this message translates to:
  /// **'{prix} / mois'**
  String proPrice(String prix);

  /// No description provided for @proBenefitRecord.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez ventes, stock et dettes sans limite.'**
  String get proBenefitRecord;

  /// No description provided for @proBenefitBackup.
  ///
  /// In fr, this message translates to:
  /// **'Vos données restent sauvegardées en ligne.'**
  String get proBenefitBackup;

  /// No description provided for @proBenefitDays.
  ///
  /// In fr, this message translates to:
  /// **'Les jours qui restent ne sont pas perdus : le mois payé s\'ajoute à la fin.'**
  String get proBenefitDays;

  /// No description provided for @payWith.
  ///
  /// In fr, this message translates to:
  /// **'Payer avec'**
  String get payWith;

  /// No description provided for @payPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro Mobile Money'**
  String get payPhoneLabel;

  /// No description provided for @payButton.
  ///
  /// In fr, this message translates to:
  /// **'Payer {prix}'**
  String payButton(String prix);

  /// No description provided for @payWaitingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Validez le paiement sur votre téléphone'**
  String get payWaitingTitle;

  /// No description provided for @payWaitingBody.
  ///
  /// In fr, this message translates to:
  /// **'Un message {operateur} va s\'afficher sur le {numero}. Entrez votre code secret Mobile Money pour payer {prix}.'**
  String payWaitingBody(String operateur, String numero, String prix);

  /// No description provided for @payWaitingLater.
  ///
  /// In fr, this message translates to:
  /// **'Revenir plus tard'**
  String get payWaitingLater;

  /// No description provided for @paySuccess.
  ///
  /// In fr, this message translates to:
  /// **'Merci. Kassa Pro est activé jusqu\'au {date}.'**
  String paySuccess(String date);

  /// No description provided for @payFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le paiement n\'a pas abouti. Vérifiez votre solde Mobile Money, puis réessayez.'**
  String get payFailed;

  /// No description provided for @payTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de réponse. Si vous avez payé, Kassa Pro s\'activera tout seul dans quelques minutes.'**
  String get payTimeout;

  /// No description provided for @payPending.
  ///
  /// In fr, this message translates to:
  /// **'Un paiement attend déjà votre validation. Regardez votre téléphone, ou réessayez dans 5 minutes.'**
  String get payPending;

  /// No description provided for @payRefused.
  ///
  /// In fr, this message translates to:
  /// **'La demande de paiement a été refusée. Vérifiez le numéro et l\'opérateur, puis réessayez.'**
  String get payRefused;

  /// No description provided for @payUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Le paiement en ligne n\'est pas disponible sur cette version de Kassa.'**
  String get payUnavailable;

  /// No description provided for @payExtend.
  ///
  /// In fr, this message translates to:
  /// **'Payer un mois de plus'**
  String get payExtend;

  /// No description provided for @settingsShop.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get settingsShop;

  /// No description provided for @shopEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la boutique'**
  String get shopEditTitle;

  /// No description provided for @shopThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Alerte de stock bas par défaut'**
  String get shopThreshold;

  /// No description provided for @shopThresholdHelp.
  ///
  /// In fr, this message translates to:
  /// **'Proposée pour chaque nouveau produit. Les produits déjà créés gardent la leur.'**
  String get shopThresholdHelp;

  /// No description provided for @errThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un nombre entier de 0 à 100 000, par exemple 5.'**
  String get errThreshold;

  /// No description provided for @shopSaved.
  ///
  /// In fr, this message translates to:
  /// **'Boutique enregistrée.'**
  String get shopSaved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
