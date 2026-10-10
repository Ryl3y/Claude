import '../core/heure_douala.dart';

/// Jour, semaine (du lundi au dimanche) ou mois, à l'heure de Douala.
enum TypePeriode { jour, semaine, mois }

/// Une période de rapport : de [debut] (inclus) à [fin] (exclue), en UTC.
class Periode {
  const Periode._(this.type, this.debut, this.fin);

  /// La période de [type] qui contient [instant] (heure de Douala).
  factory Periode.contenant(TypePeriode type, DateTime instant) {
    if (type == TypePeriode.jour) {
      // Même définition du jour que l'historique et les numéros de vente.
      final debut = HeureDouala.debutDuJourUtc(instant);
      return Periode._(type, debut, debut.add(const Duration(days: 1)));
    }
    final d = HeureDouala.versDouala(instant);
    final (debut, fin) = switch (type) {
      TypePeriode.jour => throw StateError('traité plus haut'),
      TypePeriode.semaine => (
        DateTime.utc(d.year, d.month, d.day - (d.weekday - 1)),
        DateTime.utc(d.year, d.month, d.day - (d.weekday - 1) + 7),
      ),
      TypePeriode.mois => (
        DateTime.utc(d.year, d.month),
        DateTime.utc(d.year, d.month + 1),
      ),
    };
    // Minuit à Douala = 23 h UTC la veille.
    return Periode._(
      type,
      debut.subtract(HeureDouala.decalage),
      fin.subtract(HeureDouala.decalage),
    );
  }

  /// La période en cours.
  factory Periode.actuelle(TypePeriode type) =>
      Periode.contenant(type, HeureDouala.maintenantUtc());

  final TypePeriode type;
  final DateTime debut;
  final DateTime fin;

  Periode get precedente =>
      Periode.contenant(type, debut.subtract(const Duration(hours: 12)));

  Periode get suivante =>
      Periode.contenant(type, fin.add(const Duration(hours: 12)));

  bool contient(DateTime instant) =>
      !instant.isBefore(debut) && instant.isBefore(fin);

  /// Vrai si la période contient maintenant.
  bool get estEnCours => contient(HeureDouala.maintenantUtc());

  /// Vrai si la période est déjà finie ou en cours (pas dans le futur).
  bool get estCommencee => !HeureDouala.maintenantUtc().isBefore(debut);

  @override
  bool operator ==(Object other) =>
      other is Periode && other.type == type && other.debut == debut;

  @override
  int get hashCode => Object.hash(type, debut);

  @override
  String toString() => 'Periode($type, $debut → $fin)';
}
