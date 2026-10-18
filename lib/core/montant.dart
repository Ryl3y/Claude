import 'package:intl/intl.dart';

/// Format des montants en FCFA (entiers, pas de centimes).
///
/// - français : « 12 500 FCFA » (espace fine entre les milliers)
/// - anglais  : « 12,500 FCFA »
/// - version courte pour les listes serrées : « 12 500 F »
///
/// Le séparateur de milliers vient d'intl selon la langue, jamais fait à la main.
/// En français, intl donne une espace fine insécable (U+202F) que
/// Plus Jakarta Sans ne contient pas : on la remplace par une espace
/// insécable (U+00A0), présente dans la police. Le montant ne se coupe
/// jamais en fin de ligne.
abstract final class Montant {
  static const deviseLongue = 'FCFA';
  static const deviseCourte = 'F';
  static const _insecable = '\u00A0';

  /// Nombre seul, avec séparateur de milliers : « 12 500 » / « 12,500 ».
  static String nombre(int valeur, String locale) =>
      sansEspaceFine(NumberFormat.decimalPattern(locale).format(valeur));

  /// Remplace l'espace fine (U+202F, absente de la police) par une espace
  /// insécable. Sert aussi au format des quantités.
  static String sansEspaceFine(String texte) =>
      texte.replaceAll('\u202F', _insecable);

  /// Montant avec devise : « 12 500 FCFA » ou, si [court], « 12 500 F ».
  static String format(int valeur, String locale, {bool court = false}) {
    final devise = court ? deviseCourte : deviseLongue;
    return '${nombre(valeur, locale)}$_insecable$devise';
  }
}
