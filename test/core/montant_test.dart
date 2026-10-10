import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/core/montant.dart';

void main() {
  const fine = ' '; // espace fine insécable (intl, français)
  const insecable = ' ';

  group('Montant.format', () {
    test('français : « 12 500 FCFA »', () {
      expect(Montant.format(12500, 'fr'), '12${fine}500${insecable}FCFA');
    });

    test('anglais : « 12,500 FCFA »', () {
      expect(Montant.format(12500, 'en'), '12,500${insecable}FCFA');
    });

    test('version courte : « 12 500 F »', () {
      expect(Montant.format(12500, 'fr', court: true), '12${fine}500${insecable}F');
      expect(Montant.format(7500, 'en', court: true), '7,500${insecable}F');
    });

    test('petits montants et zéro', () {
      expect(Montant.format(0, 'fr'), '0${insecable}FCFA');
      expect(Montant.format(500, 'fr'), '500${insecable}FCFA');
    });

    test('millions', () {
      expect(Montant.nombre(1250000, 'fr'), '1${fine}250${fine}000');
      expect(Montant.nombre(1250000, 'en'), '1,250,000');
    });
  });
}
