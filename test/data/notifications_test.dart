import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/firebase/notifications.dart';

class _FauxJetons implements JetonsNotification {
  final envoyes = <String>[];
  var echouer = false;

  @override
  Future<void> enregistrer({
    required String utilisateurId,
    required String appareilId,
    required String boutiqueId,
    required String jeton,
    required String langue,
  }) async {
    if (echouer) throw StateError('pas de réseau');
    envoyes.add('$utilisateurId/$appareilId/$boutiqueId/$jeton/$langue');
  }
}

void main() {
  test('permission, jeton envoyé, puis chaque renouvellement', () async {
    final jetons = _FauxJetons();
    final renouvellements = StreamController<String>();
    var permission = false;
    final n = Notifications(
      jetons,
      lireJeton: () async => 'j1',
      renouvellements: renouvellements.stream,
      demanderPermission: () async => permission = true,
    );
    await n.demarrer(
      utilisateurId: 'u',
      appareilId: 'a',
      boutiqueId: 'b',
      langue: 'fr',
    );
    expect(permission, isTrue);
    expect(jetons.envoyes, ['u/a/b/j1/fr']);
    renouvellements.add('j2');
    await Future<void>.delayed(Duration.zero);
    expect(jetons.envoyes.last, 'u/a/b/j2/fr');
    await n.arreter();
    await renouvellements.close();
  });

  test('pas de réseau ou pas de services Google : rien ne casse', () async {
    final jetons = _FauxJetons()..echouer = true;
    final n = Notifications(
      jetons,
      lireJeton: () async => throw StateError('pas de services Google'),
      renouvellements: const Stream.empty(),
      demanderPermission: () async {},
    );
    await n.demarrer(
      utilisateurId: 'u',
      appareilId: 'a',
      boutiqueId: 'b',
      langue: 'en',
    );
    expect(jetons.envoyes, isEmpty);
    await n.arreter();
  });
}
