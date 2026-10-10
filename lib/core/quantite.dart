import 'package:intl/intl.dart';

import 'montant.dart';

/// Format des quantités (stock, vrac) selon la langue :
/// « 1,5 » (fr), « 1.5 » (en) ; 3 décimales au plus, aucune si entier.
abstract final class Quantite {
  static String format(double valeur, String locale) =>
      Montant.sansEspaceFine(NumberFormat('#,##0.###', locale).format(valeur));
}
