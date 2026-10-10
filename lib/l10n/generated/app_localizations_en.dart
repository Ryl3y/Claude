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

  @override
  String salesAndProfit(String ventes, String montant) {
    return '$ventes · profit $montant';
  }

  @override
  String get saveStatePending => 'Waiting to save';

  @override
  String get saveStateLocal => 'On this phone';

  @override
  String get saveStateSavedHelp => 'Everything is backed up online.';

  @override
  String get saveStatePendingHelp =>
      'Some changes are waiting for internet to be saved.';

  @override
  String get saveStateLocalHelp =>
      'Your data is stored on this phone. Online backup will start when you create your account.';

  @override
  String get seeStock => 'See stock';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsHint => 'Day, week, month and best sellers';

  @override
  String get homeNoProductsTitle => 'Add your products to get started';

  @override
  String get homeNoProductsBody =>
      'Once your products and prices are in, a sale takes just a few taps.';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodEarlier => 'Earlier';

  @override
  String get periodLater => 'Later';

  @override
  String get periodEarlierHint => 'Previous period';

  @override
  String get periodLaterHint => 'Next period';

  @override
  String get thisWeek => 'This week';

  @override
  String get lastWeek => 'Last week';

  @override
  String weekRange(String debut, String fin) {
    return '$debut to $fin';
  }

  @override
  String get thisMonth => 'This month';

  @override
  String get lastMonth => 'Last month';

  @override
  String get salesLabel => 'Sales';

  @override
  String averageSale(String montant) {
    return 'Average sale: $montant';
  }

  @override
  String get moneyReceivedTitle => 'Money received';

  @override
  String get paidAtSale => 'Paid at sale';

  @override
  String get soldOnCredit => 'Sold on credit';

  @override
  String get debtsCollected => 'Debts collected';

  @override
  String get totalReceived => 'Total received';

  @override
  String get salesByMode => 'Sales by payment method';

  @override
  String get bestSellers => 'Best sellers';

  @override
  String bestSellerDetail(String quantite, String benefice) {
    return '$quantite sold · profit $benefice';
  }

  @override
  String bestSellerRank(int rang) {
    return '#$rang';
  }

  @override
  String get reportEmpty => 'No sales in this period.';

  @override
  String cancelledNotCounted(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre cancelled sales are not counted.',
      one: '1 cancelled sale is not counted.',
    );
    return '$_temp0';
  }

  @override
  String get welcomeTitle => 'Your till, even without internet';

  @override
  String get welcomeBody =>
      'Sales, stock and customer debts in one place. You only need internet once, to create your account.';

  @override
  String get start => 'Get started';

  @override
  String get serverMissing =>
      'This version of the app is not connected to the Kassa server.';

  @override
  String get loginTitle => 'Your phone number';

  @override
  String get loginBody =>
      'We will text you a code to check that this number is yours.';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get errPhone =>
      'Invalid number. Enter the 9 digits, for example 6 77 12 34 56.';

  @override
  String get sendCode => 'Get the code';

  @override
  String get codeTitle => 'Code from the text message';

  @override
  String codeBody(String numero) {
    return 'Enter the 6-digit code sent to $numero.';
  }

  @override
  String get codeLabel => '6-digit code';

  @override
  String get verifyCode => 'Confirm code';

  @override
  String resendIn(int secondes) {
    return 'Resend code in $secondes s';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get changeNumber => 'Change number';

  @override
  String codeSent(String numero) {
    return 'Code sent to $numero.';
  }

  @override
  String get errCodeRefused =>
      'Wrong or expired code. Check the text message or ask for a new code.';

  @override
  String get errTooManyRequests =>
      'Too many requests. Wait a minute before trying again.';

  @override
  String get errSmsFailed =>
      'The text message could not be sent. Check the number.';

  @override
  String get errNetwork =>
      'No internet connection. Check your mobile data, then try again.';

  @override
  String get errOther => 'Something went wrong. Try again in a moment.';

  @override
  String get errOtherAccount =>
      'This phone is already linked to another number\'s account. Sign in with that number.';

  @override
  String get restoring => 'Getting your data back…';

  @override
  String get shopTitle => 'Your shop';

  @override
  String get shopBody => 'You can change this later in Settings.';

  @override
  String get shopName => 'Shop name';

  @override
  String get shopNameHint => 'For example: Mama Brigitte\'s';

  @override
  String get errShopName => 'Enter the shop name.';

  @override
  String get shopType => 'Type of business';

  @override
  String get typeFood => 'Food, grocery';

  @override
  String get typeNeighborhood => 'Corner shop';

  @override
  String get typeHardware => 'Hardware';

  @override
  String get typeBeauty => 'Beauty products';

  @override
  String get typeClothes => 'Clothes, shoes';

  @override
  String get typePhones => 'Phones, accessories';

  @override
  String get typeOther => 'Other';

  @override
  String get city => 'City';

  @override
  String get cityHint => 'For example: Douala';

  @override
  String get errCity => 'Enter the city.';

  @override
  String get district => 'Neighbourhood';

  @override
  String get districtHint => 'For example: Akwa';

  @override
  String get errDistrict => 'Enter the neighbourhood.';

  @override
  String get pinChoose => '4-digit PIN';

  @override
  String get pinChooseHint =>
      'It protects the app if someone else picks up your phone.';

  @override
  String get pinConfirm => 'Confirm the PIN';

  @override
  String get errPinFormat => 'The PIN must have 4 digits.';

  @override
  String get errPinMismatch => 'The two PINs are different. Enter them again.';

  @override
  String get createShop => 'Create my shop';

  @override
  String get pinTitle => 'Enter your PIN';

  @override
  String pinProgress(int n) {
    return '$n of 4 digits entered';
  }

  @override
  String pinWrong(int restants) {
    String _temp0 = intl.Intl.pluralLogic(
      restants,
      locale: localeName,
      other: 'Wrong PIN. $restants tries left.',
      one: 'Wrong PIN. 1 try left.',
    );
    return '$_temp0';
  }

  @override
  String pinLocked(int secondes) {
    return 'Too many tries. Try again in $secondes s.';
  }

  @override
  String get pinForgot => 'Forgot PIN';

  @override
  String get pinForgotBody =>
      'We will text you a code, then you choose a new PIN.';

  @override
  String get newPinTitle => 'Choose a new PIN';

  @override
  String get newPinConfirmTitle => 'Enter it once more';

  @override
  String get pinChanged => 'PIN changed.';

  @override
  String get errPinOtherNumber =>
      'This number is not the one of this phone\'s account.';

  @override
  String get loading => 'Loading…';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHint => 'Language, subscription, account';

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsAccount => 'Account';

  @override
  String get backupNow => 'Back up now';

  @override
  String get backupDone => 'Everything is backed up online.';

  @override
  String get backupFailed =>
      'Backup isn\'t possible right now. Your data stays on this phone; Kassa will try again when the internet is back.';

  @override
  String get logout => 'Log out';

  @override
  String get logoutTitle => 'Log out of this phone?';

  @override
  String get logoutBody =>
      'Your shop\'s data will be erased from this phone. It stays backed up online and comes back when you log in again with your number.';

  @override
  String logoutPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n changes aren\'t backed up online yet: they will be lost.',
      one: '1 change isn\'t backed up online yet: it will be lost.',
    );
    return '$_temp0';
  }

  @override
  String get logoutLocalOnly =>
      'This shop isn\'t backed up online: all its data will be lost.';

  @override
  String get logoutConfirm => 'Erase and log out';

  @override
  String get proTitle => 'Kassa Pro';

  @override
  String trialDaysLeft(int jours) {
    String _temp0 = intl.Intl.pluralLogic(
      jours,
      locale: localeName,
      other: 'Free trial: $jours days left',
      one: 'Last day of your free trial',
    );
    return '$_temp0';
  }

  @override
  String trialUntil(String date) {
    return 'Free trial until $date';
  }

  @override
  String proUntil(String date) {
    return 'Kassa Pro until $date';
  }

  @override
  String get trialEnded => 'Your free trial has ended';

  @override
  String get proEnded => 'Your Pro subscription has ended';

  @override
  String readOnlyBody(String prix) {
    return 'Your sales, stock and debts stay visible. To record again, go Pro: $prix a month.';
  }

  @override
  String trialEndingBody(String prix) {
    return 'After the trial, Kassa Pro costs $prix a month to keep recording.';
  }

  @override
  String proPrice(String prix) {
    return '$prix / month';
  }

  @override
  String get proBenefitRecord =>
      'Record sales, stock and debts without limits.';

  @override
  String get proBenefitBackup => 'Your data stays backed up online.';

  @override
  String get proBenefitDays =>
      'Days left aren\'t lost: the paid month is added at the end.';

  @override
  String get payWith => 'Pay with';

  @override
  String get payPhoneLabel => 'Mobile Money number';

  @override
  String payButton(String prix) {
    return 'Pay $prix';
  }

  @override
  String get payWaitingTitle => 'Approve the payment on your phone';

  @override
  String payWaitingBody(String operateur, String numero, String prix) {
    return 'A $operateur message will appear on $numero. Enter your Mobile Money PIN to pay $prix.';
  }

  @override
  String get payWaitingLater => 'Come back later';

  @override
  String paySuccess(String date) {
    return 'Thank you. Kassa Pro is active until $date.';
  }

  @override
  String get payFailed =>
      'The payment didn\'t go through. Check your Mobile Money balance, then try again.';

  @override
  String get payTimeout =>
      'No answer yet. If you paid, Kassa Pro will turn on by itself in a few minutes.';

  @override
  String get payPending =>
      'A payment is already waiting for your approval. Check your phone, or try again in 5 minutes.';

  @override
  String get payRefused =>
      'The payment request was refused. Check the number and the operator, then try again.';

  @override
  String get payUnavailable =>
      'Online payment isn\'t available in this version of Kassa.';

  @override
  String get payExtend => 'Pay for another month';
}
