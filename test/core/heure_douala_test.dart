import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kassa/core/heure_douala.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr');
    await initializeDateFormatting('en');
  });

  test('Douala = UTC+1', () {
    final utc = DateTime.utc(2026, 10, 10, 13, 30);
    final d = HeureDouala.versDouala(utc);
    expect(d.hour, 14);
    expect(d.minute, 30);
  });

  test('heure affichée : « 14 h 30 » / « 2:30 pm »', () {
    final utc = DateTime.utc(2026, 10, 10, 13, 30);
    expect(HeureDouala.heure(utc, 'fr'), '14 h 30');
    expect(HeureDouala.heure(utc, 'en'), '2:30 pm');
  });

  test('date courte : « 10 oct. » / « 10 Oct »', () {
    final utc = DateTime.utc(2026, 10, 10, 9);
    expect(HeureDouala.dateCourte(utc, 'fr'), '10 oct.');
    expect(HeureDouala.dateCourte(utc, 'en'), '10 Oct');
  });

  test('23 h 30 UTC est déjà le lendemain à Douala', () {
    final utc = DateTime.utc(2026, 10, 10, 23, 30);
    expect(HeureDouala.dateCourte(utc, 'fr'), '11 oct.');
  });

  test('début du jour à Douala, en UTC', () {
    final utc = DateTime.utc(2026, 10, 10, 23, 30); // 11 oct. 00 h 30 à Douala
    expect(HeureDouala.debutDuJourUtc(utc), DateTime.utc(2026, 10, 10, 23));
    final matin = DateTime.utc(2026, 10, 10, 8); // 9 h à Douala
    expect(HeureDouala.debutDuJourUtc(matin), DateTime.utc(2026, 10, 9, 23));
  });
}
