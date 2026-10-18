import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/lieux/service_lieux.dart';
import 'package:kassa/domain/lieux.dart';

import '../faux_lieux.dart';

void main() {
  const dschang = 'CM008005001';
  const koutaba = 'CM008008005';

  LieuChoisi lieu(String arr, Lieu localite, Lieu quartier) => LieuChoisi(
    region: 'CM008',
    departement: arr.substring(0, 8),
    arrondissement: arr,
    localite: localite,
    quartier: quartier,
  );

  test('noms déjà dans la liste : rien n\'est ajouté', () async {
    final s = FauxLieux();
    final ville = s.lieuNomme('Dschang')!;
    final quartier = s.lieuNomme('Haoussa')!;
    final r = await enregistrerLieu(s, lieu(dschang, ville, quartier));
    expect(r.localite, ville);
    expect(r.quartier, quartier);
    expect(s.ajouts, isEmpty);
  });

  test('village et quartier nouveaux : ajoutés, puis proposés aux '
      'suivants', () async {
    final s = FauxLieux();
    final r = await enregistrerLieu(
      s,
      lieu(dschang, const Lieu(null, ' Baleveng '), const Lieu(null, 'Centre')),
    );
    expect(r.localite!.id, isNotNull);
    expect(r.localite!.nom, 'Baleveng');
    expect(r.quartier!.id, isNotNull);
    expect(
      (await s.localites(dschang)).map((l) => l.nom),
      contains('Baleveng'),
    );
    expect((await s.quartiers(r.localite!.id!)).single.nom, 'Centre');

    // Même nom tapé autrement : on retrouve le même village.
    final r2 = await enregistrerLieu(
      s,
      lieu(dschang, const Lieu(null, 'BALÉVENG'), const Lieu(null, 'centre')),
    );
    expect(r2.localite!.id, r.localite!.id);
    expect(r2.quartier!.id, r.quartier!.id);
    expect(s.ajouts, hasLength(2));
  });

  test('un même nom de quartier dans plusieurs arrondissements', () async {
    final s = FauxLieux();
    final aDschang = await enregistrerLieu(
      s,
      lieu(dschang, s.lieuNomme('Dschang')!, const Lieu(null, 'Haoussa')),
    );
    final aKoutaba = await enregistrerLieu(
      s,
      lieu(koutaba, s.lieuNomme('Koutaba')!, const Lieu(null, 'Haoussa')),
    );
    expect(aDschang.quartier!.id, isNot(aKoutaba.quartier!.id));
    expect(aKoutaba.quartier!.nom, 'Haoussa');
    // À Dschang, Haoussa existait déjà ; à Koutaba, il vient d'être ajouté.
    expect(s.ajouts.map((a) => a.$2), ['Haoussa']);
  });

  test('sans réseau : les noms sont gardés sans identifiant', () async {
    final s = FauxLieux()..horsLigne = true;
    final r = await enregistrerLieu(
      s,
      lieu(dschang, const Lieu(null, 'Baleveng'), const Lieu(null, 'Centre')),
    );
    expect(r.localite, const Lieu(null, 'Baleveng'));
    expect(r.quartier, const Lieu(null, 'Centre'));
  });

  test('sans serveur : le lieu est rendu tel quel', () async {
    const l = LieuChoisi(
      arrondissement: dschang,
      localite: Lieu(null, 'Baleveng'),
      quartier: Lieu(null, 'Centre'),
    );
    expect(await enregistrerLieu(null, l), same(l));
  });

  test('trop d\'ajouts ou nom refusé : l\'erreur remonte', () async {
    final s = FauxLieux()..prochainRefus = RefusLieu.tropDAjouts;
    await expectLater(
      enregistrerLieu(
        s,
        lieu(dschang, const Lieu(null, 'Baleveng'), const Lieu(null, 'X')),
      ),
      throwsA(
        isA<LieuRefuse>().having(
          (e) => e.raison,
          'raison',
          RefusLieu.tropDAjouts,
        ),
      ),
    );
    s.prochainRefus = RefusLieu.nomInvalide;
    await expectLater(
      enregistrerLieu(
        s,
        lieu(dschang, s.lieuNomme('Dschang')!, const Lieu(null, '123')),
      ),
      throwsA(isA<LieuRefuse>()),
    );
  });

  test('le refus dit quel champ corriger : village ou quartier', () async {
    final s = FauxLieux()..prochainRefus = RefusLieu.nomInvalide;
    await expectLater(
      enregistrerLieu(
        s,
        lieu(dschang, s.lieuNomme('Dschang')!, const Lieu(null, '--')),
      ),
      throwsA(isA<LieuRefuse>().having((e) => e.surQuartier, 'quartier', true)),
    );
    s.prochainRefus = RefusLieu.tropDAjouts;
    await expectLater(
      enregistrerLieu(
        s,
        lieu(dschang, const Lieu(null, 'Baleveng'), const Lieu(null, 'Centre')),
      ),
      throwsA(
        isA<LieuRefuse>().having((e) => e.surQuartier, 'quartier', false),
      ),
    );
  });
}
