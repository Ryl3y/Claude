import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/domain/lieux.dart';

void main() {
  group('découpage embarqué', () {
    final d = Decoupage.depuisJson(File(Decoupage.fichier).readAsStringSync());

    test('10 régions, 58 départements, 360 arrondissements', () {
      expect(d.regions, hasLength(10));
      expect(d.departements, hasLength(58));
      expect(d.arrondissements, hasLength(360));
    });

    test('chaque niveau pointe vers un parent qui existe', () {
      for (final dep in d.departements) {
        expect(d.region(dep.region), isNotNull, reason: dep.nom);
      }
      for (final a in d.arrondissements) {
        expect(d.departement(a.departement), isNotNull, reason: a.nom);
        expect(a.code, matches(RegExp(r'^CM\d{9}$')));
      }
      expect(d.arrondissements.map((a) => a.code).toSet(), hasLength(360));
    });

    test('Ouest → Menoua → Dschang ; noms en français et en anglais', () {
      final ouest = d.regions.singleWhere((r) => r.nomFr == 'Ouest');
      expect(ouest.nom('en'), 'West');
      final menoua = d
          .departementsDe(ouest.code)
          .singleWhere((x) => x.nom == 'Menoua');
      expect(
        d.arrondissementsDe(menoua.code).map((a) => a.nom),
        containsAll(['Dschang', 'Santchou', 'Penka-Michel']),
      );
      expect(d.arrondissement('CM008005001')!.nom, 'Dschang');
      expect(d.departementsDe('CM008'), hasLength(8));
    });
  });

  group('noms de lieux', () {
    test('cleLieu : sans accents, majuscules ni ponctuation', () {
      expect(cleLieu('Haoussa'), cleLieu('  HAOUSSA '));
      expect(cleLieu('Foréké-Dschang'), 'foreke dschang');
      expect(cleLieu('Ndé'), 'nde');
      expect(cleLieu("Mbanga-Pongo (Bépanda)"), 'mbanga pongo bepanda');
      expect(cleLieu('  --  '), isEmpty);
    });

    test('nomLieu retire les espaces superflus', () {
      expect(nomLieu('  Foto   Marché '), 'Foto Marché');
    });

    test('filtrerLieux : début de mot d\'abord, puis le reste', () {
      const lieux = [
        Lieu('1', 'Bafoussam'),
        Lieu('2', 'Foréké-Dschang'),
        Lieu('3', 'Dschang'),
        Lieu('4', 'Fongo-Ndeng'),
      ];
      expect(filtrerLieux(lieux, 'dsch').map((l) => l.nom), [
        'Foréké-Dschang',
        'Dschang',
      ]);
      expect(filtrerLieux(lieux, 'FOREKE').single.nom, 'Foréké-Dschang');
      expect(filtrerLieux(lieux, 'ouss').single.nom, 'Bafoussam');
      expect(filtrerLieux(lieux, 'ndeng').single.nom, 'Fongo-Ndeng');
      expect(filtrerLieux(lieux, '', max: 2), hasLength(2));
      expect(filtrerLieux(lieux, 'zzz'), isEmpty);
    });

    test('lieu complet : arrondissement, village et quartier', () {
      expect(const LieuChoisi().complet, isFalse);
      expect(
        const LieuChoisi(
          arrondissement: 'CM008005001',
          localite: Lieu(null, 'Dschang'),
          quartier: Lieu(null, ' '),
        ).complet,
        isFalse,
      );
      expect(
        const LieuChoisi(
          arrondissement: 'CM008005001',
          localite: Lieu(null, 'Dschang'),
          quartier: Lieu(null, 'Haoussa'),
        ).complet,
        isTrue,
      );
    });
  });
}
