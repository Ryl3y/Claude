import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Dates : enregistrées en UTC, affichées à l'heure de Douala.
///
/// Le Cameroun est à UTC+1 toute l'année (pas d'heure d'été) :
/// un décalage fixe suffit, sans base de fuseaux horaires.
abstract final class HeureDouala {
  static const decalage = Duration(hours: 1);

  /// Maintenant, en UTC : c'est ce qu'on enregistre en base.
  static DateTime maintenantUtc() => horloge().toUtc();

  /// Source de l'heure ; les tests la figent pour des captures stables.
  @visibleForTesting
  static DateTime Function() horloge = DateTime.now;

  /// Convertit une date (UTC ou locale) en heure murale de Douala.
  /// Le résultat est marqué UTC pour qu'aucun fuseau du téléphone ne s'y ajoute.
  static DateTime versDouala(DateTime date) => date.toUtc().add(decalage);

  /// Début du jour à Douala, renvoyé en UTC (utile pour « ventes du jour »).
  static DateTime debutDuJourUtc(DateTime date) {
    final d = versDouala(date);
    return DateTime.utc(d.year, d.month, d.day).subtract(decalage);
  }

  /// Date courte : « 10 oct. » (fr) / « 10 Oct » (en).
  static String dateCourte(DateTime date, String locale) {
    final d = versDouala(date);
    return DateFormat('d MMM', locale).format(d);
  }

  /// Heure : « 14 h 30 » (fr) / « 2:30 pm » (en).
  static String heure(DateTime date, String locale) {
    final d = versDouala(date);
    if (locale.startsWith('fr')) {
      return DateFormat("H 'h' mm", locale).format(d);
    }
    return DateFormat('h:mm a', locale).format(d).toLowerCase();
  }
}
