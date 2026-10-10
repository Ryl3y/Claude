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
        AbonnementEssai(DateTime.utc(2026, 11, 9), joursRestants: 31),
      );
    });

    test(
      'dernier jour : 1 jour restant (aujourd\'hui), on peut encore écrire',
      () {
        final e = EtatAbonnement.calculer(
          formule: 'gratuit',
          fin: aujourdhui,
          aujourdhui: aujourdhui,
        );
        expect(e, AbonnementEssai(aujourdhui, joursRestants: 1));
        expect(e.peutEcrire, isTrue);
      },
    );

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

  test('fin d\'essai sans serveur : 7 jours après la création (Douala)', () {
    expect(
      EtatAbonnement.finEssaiDepuis(DateTime.utc(2026, 10, 9, 23, 30)),
      DateTime.utc(2026, 10, 16),
    );
  });

  test('essai de 7 jours : du 1er au 7e jour, puis terminé', () {
    final creation = DateTime.utc(2026, 10, 10, 9);
    final fin = EtatAbonnement.finEssaiDepuis(creation);
    int? reste(int jour) => switch (EtatAbonnement.calculer(
      formule: 'gratuit',
      fin: fin,
      aujourdhui: DateTime.utc(2026, 10, 10 + jour - 1),
    )) {
      AbonnementEssai(:final joursRestants) => joursRestants,
      _ => null,
    };
    expect(
      [for (var j = 1; j <= 8; j++) reste(j)],
      [7, 6, 5, 4, 3, 2, 1, null],
    );
  });

  test('dates du serveur', () {
    expect(EtatAbonnement.lireDate('2026-11-09'), DateTime.utc(2026, 11, 9));
    expect(EtatAbonnement.lireDate('n/a'), isNull);
    expect(EtatAbonnement.lireDate(null), isNull);
    expect(EtatAbonnement.ecrireDate(DateTime.utc(2026, 1, 5)), '2026-01-05');
  });
}
