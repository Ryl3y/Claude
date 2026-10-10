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
  String get previewTitle => 'Kassa style guide';

  @override
  String get previewLogo => 'Logo';

  @override
  String get previewColors => 'Colors';

  @override
  String get previewText => 'Text';

  @override
  String get previewAmounts => 'Amounts';

  @override
  String get previewWords => 'App words';

  @override
  String get previewStepNote =>
      'Temporary screen for step 1. The home screen will replace it.';
}
