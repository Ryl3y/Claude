import 'package:intl/intl.dart';

/// Format des montants en FCFA (entiers, pas de centimes).
///
/// - français : « 12 500 FCFA » (espace fine entre les milliers)
/// - anglais  : « 12,500 FCFA »
/// - version courte pour les listes serrées : « 12 500 F »
///
/// Le séparateur de milliers vient d'intl selon la langue, jamais fait à la main.
/// Une espace insécable sépare le nombre de la devise : elle ne passe
/// jamais seule à la ligne.
abstract final class Montant {
  static const deviseLongue = 'FCFA';
  static const deviseCourte = 'F';
  static const _insecable = ' ';

  /// Nombre seul, avec séparateur de milliers : « 12 500 » / « 12,500 ».
  static String nombre(int valeur, String locale) =>
      NumberFormat.decimalPattern(locale).format(valeur);

  /// Montant avec devise : « 12 500 FCFA » ou, si [court], « 12 500 F ».
  static String format(int valeur, String locale, {bool court = false}) {
    final devise = court ? deviseCourte : deviseLongue;
    return '${nombre(valeur, locale)}$_insecable$devise';
  }
}
