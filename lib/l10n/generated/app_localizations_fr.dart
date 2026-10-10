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
}
