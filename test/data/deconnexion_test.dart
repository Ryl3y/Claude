import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/deconnexion.dart';
import 'package:kassa/data/preferences/preferences_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aide_base.dart';
import 'faux_auth.dart';

Future<int> _lignes(KassaDatabase db) async {
  var n = 0;
  for (final t in db.allTables) {
    n += await db
        .customSelect('SELECT COUNT(*) AS n FROM ${t.actualTableName}')
        .map((r) => r.read<int>('n'))
        .getSingle();
  }
  return n;
}

void main() {
  test(
    'vide la base, oublie le compte, garde la langue et le téléphone',
    () async {
      SharedPreferences.setMockInitialValues({'langue': 'en'});
      final prefs = await PreferencesLocales.ouvrir();
      final appareilId = await prefs.appareilId();
      await prefs.ecrire('ventes', 'curseur');
      await prefs.marquerRestauration(enCours: true);
      await prefs.noterEchecPin(maintenant);
      await prefs.enregistrerAbonnement(
        Donnees.boutiqueId,
        formule: 'pro',
        dateFin: '2026-11-10',
      );

      final db = baseEnMemoire();
      addTearDown(db.close);
      await Donnees.inserer(db);
      await (db.update(
        db.produits,
      )..where((p) => p.id.equals(Donnees.produitId))).write(
        const ProduitsCompanion(photoLocale: Value('/photos/riz.jpg')),
      );
      expect(await _lignes(db), greaterThan(0));

      final auth = FauxAuth();
      await auth.verifierCode('237677123456', auth.codeAttendu);
      final effacees = <String?>[];

      await Deconnexion(
        db: db,
        prefs: prefs,
        auth: auth,
        effacerPhoto: (p) async => effacees.add(p),
      ).deconnecter();

      expect(await _lignes(db), 0);
      expect(auth.utilisateurId, isNull);
      expect(effacees, ['/photos/riz.jpg']);
      expect(prefs.lire('ventes'), isNull);
      expect(prefs.restaurationEnCours, isFalse);
      expect(prefs.echecsPin, 0);
      expect(prefs.abonnement(Donnees.boutiqueId), isNull);
      expect(prefs.langue, 'en');
      expect(await prefs.appareilId(), appareilId);
    },
  );

  test(
    'sans réseau, photo verrouillée : le téléphone est vidé quand même',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesLocales.ouvrir();
      final db = baseEnMemoire();
      addTearDown(db.close);
      await Donnees.inserer(db);
      await (db.update(
        db.produits,
      )..where((p) => p.id.equals(Donnees.produitId))).write(
        const ProduitsCompanion(photoLocale: Value('/photos/riz.jpg')),
      );
      final auth = FauxAuth()..prochaineErreurDeconnexion = true;

      await Deconnexion(
        db: db,
        prefs: prefs,
        auth: auth,
        effacerPhoto: (_) async => throw const FileSystemException('verrou'),
      ).deconnecter();
      expect(await _lignes(db), 0);
    },
  );

  test('abonnement gardé seulement pour sa boutique', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesLocales.ouvrir();
    await prefs.enregistrerAbonnement(
      'b1',
      formule: 'pro',
      dateFin: '2026-11-10',
    );
    expect(prefs.abonnement('b1'), ('pro', '2026-11-10'));
    expect(prefs.abonnement('b2'), isNull);
  });
}
