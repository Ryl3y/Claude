import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/domain/periode.dart';

void main() {
  // Samedi 10 octobre 2026, 0 h 30 à Douala = vendredi 9, 23 h 30 UTC.
  final juste = DateTime.utc(2026, 10, 9, 23, 30);

  test('jour : de minuit à minuit, heure de Douala', () {
    final p = Periode.contenant(TypePeriode.jour, juste);
    expect(p.debut, DateTime.utc(2026, 10, 9, 23));
    expect(p.fin, DateTime.utc(2026, 10, 10, 23));
    expect(p.contient(juste), isTrue);
    expect(p.contient(DateTime.utc(2026, 10, 9, 22, 59)), isFalse);
  });

  test('semaine : du lundi au dimanche', () {
    final p = Periode.contenant(TypePeriode.semaine, juste);
    // Lundi 5 octobre, minuit à Douala.
    expect(p.debut, DateTime.utc(2026, 10, 4, 23));
    expect(p.fin, DateTime.utc(2026, 10, 11, 23));
  });

  test('mois : du 1er au 1er du mois suivant', () {
    final p = Periode.contenant(TypePeriode.mois, juste);
    expect(p.debut, DateTime.utc(2026, 9, 30, 23));
    expect(p.fin, DateTime.utc(2026, 10, 31, 23));
    final dec = Periode.contenant(TypePeriode.mois, DateTime.utc(2026, 12, 15));
    expect(dec.suivante.debut, DateTime.utc(2026, 12, 31, 23));
  });

  test('précédente et suivante s\'enchaînent sans trou', () {
    for (final type in TypePeriode.values) {
      final p = Periode.contenant(type, juste);
      expect(p.precedente.fin, p.debut);
      expect(p.suivante.debut, p.fin);
      expect(p.precedente.suivante, p);
    }
  });

  test('égalité par type et début (clé de cache)', () {
    expect(
      Periode.contenant(TypePeriode.jour, juste),
      Periode.contenant(TypePeriode.jour, DateTime.utc(2026, 10, 10, 12)),
    );
    expect(
      Periode.contenant(TypePeriode.jour, juste),
      isNot(Periode.contenant(TypePeriode.semaine, juste)),
    );
  });
}
