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

  @override
  String get history => 'History';

  @override
  String productsCount(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartEmptyHint =>
      'Tap a product to add it. Press and hold to choose the quantity.';

  @override
  String get sellNoProductsTitle => 'No products to sell';

  @override
  String get sellNoProductsBody =>
      'Add your products in the Stock tab to start selling.';

  @override
  String get clearCart => 'Clear cart';

  @override
  String get cartCleared => 'Cart cleared.';

  @override
  String get undo => 'Undo';

  @override
  String get removeFromCart => 'Remove';

  @override
  String increaseQuantity(String nom) {
    return 'Add 1 $nom';
  }

  @override
  String decreaseQuantity(String nom) {
    return 'Remove 1 $nom';
  }

  @override
  String quantityOf(String nom) {
    return 'Quantity of $nom';
  }

  @override
  String get putInCart => 'Put in cart';

  @override
  String stockInsufficient(String quantite) {
    return 'Not enough stock: $quantite left. You can still sell.';
  }

  @override
  String get decimalSeparator => 'Decimal point';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get saleTotal => 'Sale total';

  @override
  String get totalToPay => 'Total to pay';

  @override
  String get payCash => 'Cash';

  @override
  String get payMomo => 'MTN MoMo';

  @override
  String get payOrange => 'Orange Money';

  @override
  String get payCredit => 'Credit';

  @override
  String get amountReceived => 'Amount received';

  @override
  String get amountReceivedHint =>
      'Nothing to enter if the customer pays the exact amount.';

  @override
  String get changeToGive => 'Change to give';

  @override
  String missingAmount(String montant) {
    return '$montant is missing. Collect more, or choose Credit to record a debt.';
  }

  @override
  String mobileMoneyHint(String montant) {
    return 'Check that the $montant has arrived on your phone before collecting.';
  }

  @override
  String get advancePaid => 'Paid now';

  @override
  String get advancePaidHint => 'Leave 0 if the customer pays nothing today.';

  @override
  String get remainingDebt => 'Left to pay';

  @override
  String get customer => 'Customer';

  @override
  String get chooseCustomer => 'Choose customer';

  @override
  String get changeCustomer => 'Change';

  @override
  String get newCustomer => 'New customer';

  @override
  String get customerName => 'Customer name';

  @override
  String get customerPhone => 'Phone (optional)';

  @override
  String get customerPhoneHint => 'To send them a WhatsApp reminder.';

  @override
  String get errCustomerName => 'Enter the customer\'s name.';

  @override
  String get addCustomer => 'Add customer';

  @override
  String get searchCustomers => 'Search customers';

  @override
  String get noCustomers => 'No customers yet. Add one with “New customer”.';

  @override
  String get errChooseCustomer => 'Choose the customer buying on credit.';

  @override
  String collectAmount(String montant) {
    return 'Collect $montant';
  }

  @override
  String get sellOnCredit => 'Sell on credit';

  @override
  String saleRecorded(int numero, String montant) {
    return 'Sale #$numero saved: $montant.';
  }

  @override
  String saleRecordedChange(int numero, String monnaie) {
    return 'Sale #$numero saved. Give back $monnaie.';
  }

  @override
  String get historyTitle => 'Sales history';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get chooseDate => 'Pick a date';

  @override
  String get allDates => 'All dates';

  @override
  String saleNumber(int numero) {
    return 'Sale #$numero';
  }

  @override
  String saleNumberTime(int numero, String heure) {
    return '#$numero · $heure';
  }

  @override
  String get historyEmptyTitle => 'No sales yet';

  @override
  String get historyEmptyBody =>
      'Your sales will show here after the first one.';

  @override
  String get historyEmptyDay => 'No sales on that day. Pick another date.';

  @override
  String daySummary(int nombre, String montant) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre sales',
      one: '1 sale',
    );
    return '$_temp0 · $montant';
  }

  @override
  String saleDateTime(String date, String heure) {
    return 'On $date at $heure';
  }

  @override
  String get products => 'Products';

  @override
  String get profit => 'Profit';

  @override
  String get paymentMode => 'Payment';

  @override
  String lineDetail(String quantite, String prix) {
    return '$quantite × $prix';
  }

  @override
  String cancelSaleTitle(int numero) {
    return 'Cancel sale #$numero?';
  }

  @override
  String get cancelSaleBody =>
      'Stock will be put back and the customer\'s debt removed. The sale stays in the history, marked Cancelled.';

  @override
  String get keepSale => 'Keep sale';

  @override
  String get errCancelRepaid =>
      'The customer has already paid back part of this sale, so it can\'t be cancelled.';

  @override
  String saleCancelled(int numero) {
    return 'Sale #$numero cancelled. Stock was put back.';
  }

  @override
  String get saleNotFound => 'This sale no longer exists.';

  @override
  String debtorsCount(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre customers owe you money',
      one: '1 customer owes you money',
      zero: 'No one owes you money',
    );
    return '$_temp0';
  }

  @override
  String lastPurchaseOn(String date) {
    return 'Last purchase on $date';
  }

  @override
  String get lastPurchaseToday => 'Last purchase today';

  @override
  String get lastPurchaseYesterday => 'Last purchase yesterday';

  @override
  String get customersEmptyTitle => 'No customers yet';

  @override
  String get customersEmptyBody =>
      'Add your customers to keep track of what they owe you.';

  @override
  String noCustomerMatch(String texte) {
    return 'No customer matches \"$texte\".';
  }

  @override
  String reminderMessageNoShop(String nom, String montant) {
    return 'Hello $nom, you still owe $montant. Thank you.';
  }

  @override
  String get whatsappError =>
      'WhatsApp won\'t open. Check that it is installed on this phone.';

  @override
  String get addPhoneToRemind =>
      'Add their phone number to send a WhatsApp reminder.';

  @override
  String get edit => 'Edit';

  @override
  String get balance => 'Balance';

  @override
  String get customerHistoryEmpty => 'No purchases or payments yet.';

  @override
  String purchaseNumber(int numero) {
    return 'Purchase · #$numero';
  }

  @override
  String creditPurchaseNumber(int numero) {
    return 'Credit purchase · #$numero';
  }

  @override
  String debtPayment(String mode) {
    return 'Payment · $mode';
  }

  @override
  String get customerNotFound => 'This customer no longer exists.';

  @override
  String get collectDebtTitle => 'Collect a debt';

  @override
  String get amountPaidNow => 'Amount paid';

  @override
  String get amountPaidNowHint =>
      'Tap \"Whole debt\" if the customer pays everything.';

  @override
  String wholeDebt(String montant) {
    return 'Whole debt · $montant';
  }

  @override
  String get remainingAfterPayment => 'Still to pay after this';

  @override
  String get debtPaidOffLabel => 'Debt paid off';

  @override
  String errPaymentTooHigh(String nom, String montant) {
    return '$nom only owes $montant. Lower the amount.';
  }

  @override
  String get paymentRecordedTitle => 'Payment recorded';

  @override
  String paymentRecordedBody(String montant, String nom) {
    return '$montant received from $nom.';
  }

  @override
  String paymentRemaining(String montant) {
    return '$montant still to pay.';
  }

  @override
  String get paymentPaidOff => 'Their debt is paid off.';

  @override
  String get sendReceipt => 'Send receipt';

  @override
  String get done => 'Done';

  @override
  String receiptMessage(String nom, String montant, String date) {
    return 'Hello $nom, on $date we received $montant.';
  }

  @override
  String receiptRemaining(String montant) {
    return 'You still owe $montant. Thank you.';
  }

  @override
  String get receiptPaidOff => 'Your debt is fully paid. Thank you.';

  @override
  String get editCustomerTitle => 'Edit customer';

  @override
  String get customerNote => 'Note (optional)';

  @override
  String get customerNoteHint => 'For example: pays at the end of the month.';

  @override
  String get errCustomerPhone =>
      'Invalid number. Enter 9 digits, for example 6 77 12 34 56.';

  @override
  String get deleteCustomer => 'Delete customer';

  @override
  String deleteCustomerTitle(String nom) {
    return 'Delete $nom?';
  }

  @override
  String get deleteCustomerBody =>
      'They will no longer be in your list. Their purchases stay in the sales history.';

  @override
  String errDeleteIndebted(String nom, String montant) {
    return '$nom still owes $montant. Collect the debt before deleting them.';
  }

  @override
  String customerDeleted(String nom) {
    return '$nom was deleted.';
  }

  @override
  String dateAndTotal(String date, String total) {
    return '$date · Total $total';
  }
}
