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

  /// No description provided for @previewLogo.
  ///
  /// In fr, this message translates to:
  /// **'Logo'**
  String get previewLogo;

  /// No description provided for @previewColors.
  ///
  /// In fr, this message translates to:
  /// **'Couleurs'**
  String get previewColors;

  /// No description provided for @previewText.
  ///
  /// In fr, this message translates to:
  /// **'Textes'**
  String get previewText;

  /// No description provided for @previewAmounts.
  ///
  /// In fr, this message translates to:
  /// **'Montants'**
  String get previewAmounts;

  /// No description provided for @previewWords.
  ///
  /// In fr, this message translates to:
  /// **'Mots de l\'app'**
  String get previewWords;

  /// No description provided for @previewStepNote.
  ///
  /// In fr, this message translates to:
  /// **'Écran provisoire de l\'étape 1. Il sera remplacé par l\'accueil.'**
  String get previewStepNote;
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
