import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/core/montant.dart';

void main() {
  const milliers = '\u00A0'; // séparateur de milliers en français (insécable)
  const insecable = '\u00A0';

  group('Montant.format', () {
    test('aucune espace milliers U+202F (absente de la police)', () {
      expect(Montant.format(1250000, 'fr').contains('\u202F'), isFalse);
    });

    test('français : « 12 500 FCFA »', () {
      expect(Montant.format(12500, 'fr'), '12${milliers}500${insecable}FCFA');
    });

    test('anglais : « 12,500 FCFA »', () {
      expect(Montant.format(12500, 'en'), '12,500${insecable}FCFA');
    });

    test('version courte : « 12 500 F »', () {
      expect(Montant.format(12500, 'fr', court: true), '12${milliers}500${insecable}F');
      expect(Montant.format(7500, 'en', court: true), '7,500${insecable}F');
    });

    test('petits montants et zéro', () {
      expect(Montant.format(0, 'fr'), '0${insecable}FCFA');
      expect(Montant.format(500, 'fr'), '500${insecable}FCFA');
    });

    test('millions', () {
      expect(Montant.nombre(1250000, 'fr'), '1${milliers}250${milliers}000');
      expect(Montant.nombre(1250000, 'en'), '1,250,000');
    });
  });
}
