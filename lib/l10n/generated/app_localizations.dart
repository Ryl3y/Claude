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

  /// Message WhatsApp pré-rempli pour rappeler une dette.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {nom}, il reste {montant} à payer chez {boutique}. Merci.'**
  String reminderMessage(String nom, String montant, String boutique);

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
