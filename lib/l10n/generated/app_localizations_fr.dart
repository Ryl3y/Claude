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
  String get previewLogo => 'Logo';

  @override
  String get previewColors => 'Couleurs';

  @override
  String get previewText => 'Textes';

  @override
  String get previewAmounts => 'Montants';

  @override
  String get previewWords => 'Mots de l\'app';

  @override
  String get previewStepNote =>
      'Écran provisoire de l\'étape 1. Il sera remplacé par l\'accueil.';
}
