import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/core/telephone.dart';

void main() {
  test('numéros camerounais acceptés sous toutes les formes', () {
    for (final saisie in [
      '677123456',
      '6 77 12 34 56',
      '+237 677 12 34 56',
      '237677123456',
      '00237677123456',
      '677-12-34-56',
    ]) {
      expect(
        Telephone.versInternational(saisie),
        '237677123456',
        reason: saisie,
      );
    }
    expect(Telephone.versInternational('222123456'), '237222123456');
  });

  test('numéros refusés', () {
    for (final saisie in [
      '',
      '67712345',
      '6771234567',
      '777123456',
      '+33612345678',
    ]) {
      expect(Telephone.versInternational(saisie), isNull, reason: saisie);
    }
  });

  test('affichage lisible', () {
    expect(Telephone.afficher('237677123456'), '+237 6 77 12 34 56');
  });
}
