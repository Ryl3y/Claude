import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/domain/client_saisie.dart';

void main() {
  test('nom obligatoire', () {
    expect(ReglesClient.verifier(const ClientSaisie(nom: '  ')), {
      ErreurClient.nomVide,
    });
  });

  test('téléphone facultatif, mais valide s\'il est rempli', () {
    expect(ReglesClient.verifier(const ClientSaisie(nom: 'Awa')), isEmpty);
    expect(
      ReglesClient.verifier(
        const ClientSaisie(nom: 'Awa', telephone: '6 77 12 34 56'),
      ),
      isEmpty,
    );
    expect(
      ReglesClient.verifier(
        const ClientSaisie(nom: 'Awa', telephone: '+237 677 12 34 56'),
      ),
      isEmpty,
    );
    expect(
      ReglesClient.verifier(
        const ClientSaisie(nom: 'Awa', telephone: '7712345'),
      ),
      {ErreurClient.telephoneInvalide},
    );
  });

  test('valeurs nettoyées : espaces retirés, vide = null', () {
    const s = ClientSaisie(
      nom: ' Awa ',
      telephone: '  ',
      note: ' fin du mois ',
    );
    expect(s.nomPropre, 'Awa');
    expect(s.telephonePropre, isNull);
    expect(s.notePropre, 'fin du mois');
  });
}
