// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kassa';

  @override
  String get appTagline => 'Sales, stock and debts, even offline.';

  @override
  String get navHome => 'Home';

  @override
  String get navSell => 'Sell';

  @override
  String get navStock => 'Stock';

  @override
  String get navCustomers => 'Customers';

  @override
  String get newSale => 'New sale';

  @override
  String get collectPayment => 'Collect payment';

  @override
  String get add => 'Add';

  @override
  String get restock => 'Restock';

  @override
  String owes(String montant) {
    return 'Owes $montant';
  }

  @override
  String get paidUp => 'Paid up';

  @override
  String get remind => 'Remind';

  @override
  String get lowStock => 'Low stock';

  @override
  String get todaySales => 'Today\'s sales';

  @override
  String get moneyOwed => 'Money owed to you';

  @override
  String get saved => 'Saved';

  @override
  String get goPro => 'Go Pro';

  @override
  String get cancelSale => 'Cancel sale';

  @override
  String youSoldToday(String montant) {
    return 'You sold $montant today.';
  }

  @override
  String get todayProfit => 'Today\'s profit';

  @override
  String get language => 'Language';

  @override
  String get languagePhone => 'Phone language';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get previewStepNote =>
      'Component demo screen (step 3). The home screen will replace it.';

  @override
  String get owesLabel => 'Owes';

  @override
  String addToCart(String nom) {
    return 'Add $nom to cart';
  }

  @override
  String inCart(String quantite) {
    return '$quantite in cart';
  }

  @override
  String stockLeft(String quantite, String unite) {
    return '$quantite $unite';
  }

  @override
  String remindOnWhatsapp(String nom) {
    return 'Remind $nom on WhatsApp';
  }

  @override
  String reminderMessage(String nom, String montant, String boutique) {
    return 'Hello $nom, you still owe $montant at $boutique. Thank you.';
  }

  @override
  String get erase => 'Delete';

  @override
  String stockAlerts(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre products low on stock',
      one: '1 product low on stock',
    );
    return '$_temp0';
  }

  @override
  String salesCount(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre sales',
      one: '1 sale',
      zero: 'No sales',
    );
    return '$_temp0';
  }

  @override
  String customersCount(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre customers',
      one: '1 customer',
      zero: 'No customers',
    );
    return '$_temp0';
  }

  @override
  String lastPurchase(String date) {
    return 'Last purchase on $date';
  }

  @override
  String get later => 'Later';

  @override
  String get paid => 'Paid';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get demoTitle => 'Kassa components';

  @override
  String get demoButtons => 'Buttons';

  @override
  String get demoBadges => 'Labels';

  @override
  String get demoAmounts => 'Amounts';

  @override
  String get demoStats => 'Key figures';

  @override
  String get demoProducts => 'Products';

  @override
  String get demoProductsHint => 'Tap a card to add it to the cart.';

  @override
  String get demoCustomers => 'Customers';

  @override
  String get demoNumPad => 'Number pad';

  @override
  String demoReminderSent(String nom) {
    return 'Reminder ready for $nom.';
  }

  @override
  String get enterQuantity => 'Enter a quantity';

  @override
  String get proBadge => 'Pro';

  @override
  String get searchProducts => 'Search products';

  @override
  String get filterAll => 'All';

  @override
  String filterLowStock(int nombre) {
    return 'Low stock ($nombre)';
  }

  @override
  String get noCategory => 'No category';

  @override
  String get addProduct => 'Add product';

  @override
  String get stockEmptyTitle => 'No products yet';

  @override
  String get stockEmptyBody =>
      'Add your products to track your stock and start selling.';

  @override
  String stockNoResult(String recherche) {
    return 'No product matches “$recherche”. Check the spelling or add this product.';
  }

  @override
  String get stockNoLowStock =>
      'No products are low on stock. Everything is above its alert level.';

  @override
  String get stockNoInCategory => 'No products in this category.';

  @override
  String stockOf(String quantite) {
    return 'Stock: $quantite';
  }

  @override
  String restockProduct(String nom) {
    return 'Restock $nom';
  }

  @override
  String get productNewTitle => 'New product';

  @override
  String get productEditTitle => 'Edit product';

  @override
  String get fieldName => 'Product name';

  @override
  String get fieldNameHint => 'e.g. Rice 5 kg';

  @override
  String get fieldCategory => 'Category';

  @override
  String get newCategory => 'New category';

  @override
  String get fieldPurchasePrice => 'Purchase price';

  @override
  String get fieldPurchasePriceHelp => 'What you pay for one unit.';

  @override
  String get fieldSalePrice => 'Selling price';

  @override
  String get fieldSalePriceHelp => 'The price you charge for one unit.';

  @override
  String get fieldQuantity => 'Quantity in stock';

  @override
  String get fieldQuantityHelpNew =>
      'What you have today. Enter 0 if you have none.';

  @override
  String get fieldQuantityHelpEdit =>
      'Changing this number records a stock correction.';

  @override
  String get fieldUnit => 'Unit';

  @override
  String get fieldThreshold => 'Low-stock alert';

  @override
  String get fieldThresholdHelp =>
      'Kassa warns you when this many or fewer are left.';

  @override
  String get photoAdd => 'Add a photo';

  @override
  String get photoChange => 'Change photo';

  @override
  String get photoTake => 'Take a photo';

  @override
  String get photoGallery => 'Choose from gallery';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get photoError =>
      'The photo could not be added. Try again or choose another photo.';

  @override
  String get unitPiece => 'piece';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLitre => 'litre';

  @override
  String get unitCarton => 'carton';

  @override
  String get unitBag => 'bag';

  @override
  String get unitPack => 'pack';

  @override
  String get unitBottle => 'bottle';

  @override
  String get unitBox => 'box';

  @override
  String get errNameRequired => 'Enter the product name.';

  @override
  String get errPriceRequired => 'Enter a price in francs, with no decimals.';

  @override
  String get errQuantityInvalid => 'Enter a number, for example 12 or 1.5.';

  @override
  String get errUnitRequired => 'Choose or type a unit.';

  @override
  String warnSellingAtLoss(String montant) {
    return 'The selling price is lower than the purchase price: you lose $montant per unit.';
  }

  @override
  String get save => 'Save';

  @override
  String get productAdded => 'Product added.';

  @override
  String get productSaved => 'Changes saved.';

  @override
  String get deleteProduct => 'Delete product';

  @override
  String deleteProductTitle(String nom) {
    return 'Delete $nom?';
  }

  @override
  String get deleteProductBody =>
      'It will no longer be offered for sale. Past sales stay in your history.';

  @override
  String get deleteConfirm => 'Delete';

  @override
  String get keep => 'Keep';

  @override
  String productDeleted(String nom) {
    return '$nom was deleted.';
  }

  @override
  String get productNotFound =>
      'This product no longer exists. It may have been deleted.';

  @override
  String get saveError =>
      'Saving failed. Try again; your data is still on the phone.';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryCreate => 'Create';

  @override
  String get cancel => 'Cancel';

  @override
  String get errCategoryName => 'Enter a category name.';

  @override
  String get categoryQuickPick => 'Pick a suggestion or type a name.';

  @override
  String get catGrocery => 'Groceries';

  @override
  String get catDrinks => 'Drinks';

  @override
  String get catHygiene => 'Personal care';

  @override
  String get catHousehold => 'Household';

  @override
  String get catFresh => 'Fresh food';

  @override
  String get catOther => 'Other';

  @override
  String get restockChooseProduct => 'Choose the product you received.';

  @override
  String currentStock(String quantite) {
    return 'Current stock: $quantite';
  }

  @override
  String currentPurchasePrice(String montant) {
    return 'Current purchase price: $montant';
  }

  @override
  String get fieldReceivedQuantity => 'Quantity received';

  @override
  String get fieldNewPurchasePriceHelp =>
      'Change it if your supplier changed the price.';

  @override
  String newStockPreview(String quantite) {
    return 'New stock: $quantite';
  }

  @override
  String get addToStock => 'Add to stock';

  @override
  String get errReceivedQuantity =>
      'Enter the quantity received, greater than 0.';

  @override
  String stockUpdated(String quantite) {
    return 'Stock updated: $quantite.';
  }

  @override
  String get comingSoon => 'This screen is coming in a future version.';

  @override
  String get loadError =>
      'Your products could not be read. Close and reopen the app; your data stays on the phone.';
}
