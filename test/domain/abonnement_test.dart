import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/domain/abonnement.dart';

void main() {
  final aujourdhui = DateTime.utc(2026, 10, 10);

  group('EtatAbonnement.calculer', () {
    test('essai : jours restants jusqu\'à la date de fin incluse', () {
      expect(
        EtatAbonnement.calculer(
          formule: 'gratuit',
          fin: DateTime.utc(2026, 11, 9),
          aujourdhui: aujourdhui,
        ),
        AbonnementEssai(DateTime.utc(2026, 11, 9), joursRestants: 30),
      );
    });

    test('dernier jour : 0 jour restant, on peut encore écrire', () {
      final e = EtatAbonnement.calculer(
        formule: 'gratuit',
        fin: aujourdhui,
        aujourdhui: aujourdhui,
      );
      expect(e, AbonnementEssai(aujourdhui, joursRestants: 0));
      expect(e.peutEcrire, isTrue);
    });

    test('le lendemain : terminé, lecture seule', () {
      final e = EtatAbonnement.calculer(
        formule: 'gratuit',
        fin: DateTime.utc(2026, 10, 9),
        aujourdhui: aujourdhui,
      );
      expect(e, AbonnementTermine(DateTime.utc(2026, 10, 9), etaitPro: false));
      expect(e.peutEcrire, isFalse);
    });

    test('Pro en cours puis Pro terminé', () {
      expect(
        EtatAbonnement.calculer(
          formule: 'pro',
          fin: DateTime.utc(2026, 11, 10),
          aujourdhui: aujourdhui,
        ),
        AbonnementPro(DateTime.utc(2026, 11, 10)),
      );
      expect(
        EtatAbonnement.calculer(
          formule: 'pro',
          fin: DateTime.utc(2026, 10, 1),
          aujourdhui: aujourdhui,
        ),
        AbonnementTermine(DateTime.utc(2026, 10, 1), etaitPro: true),
      );
    });
  });

  test('jour de Douala : 23 h 30 UTC est déjà le lendemain', () {
    expect(
      EtatAbonnement.jourDouala(DateTime.utc(2026, 10, 9, 23, 30)),
      DateTime.utc(2026, 10, 10),
    );
  });

  test('fin d\'essai sans serveur : 30 jours après la création (Douala)', () {
    expect(
      EtatAbonnement.finEssaiDepuis(DateTime.utc(2026, 10, 9, 23, 30)),
      DateTime.utc(2026, 11, 9),
    );
  });

  test('dates du serveur', () {
    expect(EtatAbonnement.lireDate('2026-11-09'), DateTime.utc(2026, 11, 9));
    expect(EtatAbonnement.lireDate('n/a'), isNull);
    expect(EtatAbonnement.lireDate(null), isNull);
    expect(EtatAbonnement.ecrireDate(DateTime.utc(2026, 1, 5)), '2026-01-05');
  });
}
