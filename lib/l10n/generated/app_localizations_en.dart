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
}
