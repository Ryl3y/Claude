import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/core/quantite.dart';
import 'package:kassa/core/whatsapp.dart';

void main() {
  group('Quantite.format', () {
    test('entier sans décimale', () {
      expect(Quantite.format(12, 'fr'), '12');
      expect(Quantite.format(12, 'en'), '12');
    });
    test('vrac : virgule en français, point en anglais', () {
      expect(Quantite.format(1.5, 'fr'), '1,5');
      expect(Quantite.format(1.5, 'en'), '1.5');
    });
    test('3 décimales au plus', () {
      expect(Quantite.format(1.12345, 'fr'), '1,123');
    });
    test('milliers avec espace insécable (pas d\'espace fine)', () {
      expect(Quantite.format(1500, 'fr'), '1 500');
      expect(Quantite.format(1500, 'en'), '1,500');
    });
  });

  group('WhatsApp', () {
    test('numéro local à 9 chiffres : indicatif 237 ajouté', () {
      expect(WhatsApp.numeroInternational('6 90 00 00 01'), '237690000001');
    });
    test('numéro déjà international', () {
      expect(WhatsApp.numeroInternational('+237 690 00 00 01'), '237690000001');
      expect(WhatsApp.numeroInternational('00237690000001'), '237690000001');
    });
    test('numéro inutilisable : pas de lien', () {
      expect(WhatsApp.numeroInternational(null), isNull);
      expect(WhatsApp.numeroInternational('123'), isNull);
      expect(WhatsApp.lien(telephone: '12', message: 'x'), isNull);
    });
    test('lien wa.me avec message encodé', () {
      final lien = WhatsApp.lien(
        telephone: '690000001',
        message: 'Bonjour Maman Brigitte, il reste 7 500 FCFA à payer.',
      )!;
      expect(lien.scheme, 'https');
      expect(lien.host, 'wa.me');
      expect(lien.path, '/237690000001');
      expect(
        lien.queryParameters['text'],
        'Bonjour Maman Brigitte, il reste 7 500 FCFA à payer.',
      );
    });
  });
}
