// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = KassaDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Les données existantes passent intactes de la v1 à la v2.
  test('migration from v1 to v2 does not corrupt data', () async {
    // Une boutique d'avant le lieu guidé : tout est gardé, le lieu est vide.
    const instant = '2026-10-10T09:00:00.000Z';
    final oldBoutiquesData = <v1.BoutiquesData>[
      const v1.BoutiquesData(
        id: '00000000-0000-4000-8000-000000000001',
        majLe: instant,
        synchro: 1,
        appareilId: 'tel-a',
        nom: 'Chez Awa',
        telephone: '237690000000',
        ville: 'Douala',
        quartier: 'Akwa',
        typeCommerce: 'alimentation',
        seuilAlerteDefaut: 5,
        creeLe: instant,
      ),
    ];
    final expectedNewBoutiquesData = <v2.BoutiquesData>[
      const v2.BoutiquesData(
        id: '00000000-0000-4000-8000-000000000001',
        majLe: instant,
        synchro: 1,
        appareilId: 'tel-a',
        nom: 'Chez Awa',
        telephone: '237690000000',
        ville: 'Douala',
        quartier: 'Akwa',
        typeCommerce: 'alimentation',
        seuilAlerteDefaut: 5,
        creeLe: instant,
      ),
    ];

    final oldUtilisateursData = <v1.UtilisateursData>[];
    final expectedNewUtilisateursData = <v2.UtilisateursData>[];

    final oldCategoriesData = <v1.CategoriesData>[];
    final expectedNewCategoriesData = <v2.CategoriesData>[];

    final oldProduitsData = <v1.ProduitsData>[];
    final expectedNewProduitsData = <v2.ProduitsData>[];

    final oldClientsData = <v1.ClientsData>[];
    final expectedNewClientsData = <v2.ClientsData>[];

    final oldVentesData = <v1.VentesData>[];
    final expectedNewVentesData = <v2.VentesData>[];

    final oldLignesVenteData = <v1.LignesVenteData>[];
    final expectedNewLignesVenteData = <v2.LignesVenteData>[];

    final oldVersementsDetteData = <v1.VersementsDetteData>[];
    final expectedNewVersementsDetteData = <v2.VersementsDetteData>[];

    final oldMouvementsStockData = <v1.MouvementsStockData>[];
    final expectedNewMouvementsStockData = <v2.MouvementsStockData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: KassaDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.boutiques, oldBoutiquesData);
        batch.insertAll(oldDb.utilisateurs, oldUtilisateursData);
        batch.insertAll(oldDb.categories, oldCategoriesData);
        batch.insertAll(oldDb.produits, oldProduitsData);
        batch.insertAll(oldDb.clients, oldClientsData);
        batch.insertAll(oldDb.ventes, oldVentesData);
        batch.insertAll(oldDb.lignesVente, oldLignesVenteData);
        batch.insertAll(oldDb.versementsDette, oldVersementsDetteData);
        batch.insertAll(oldDb.mouvementsStock, oldMouvementsStockData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewBoutiquesData,
          await newDb.select(newDb.boutiques).get(),
        );
        expect(
          expectedNewUtilisateursData,
          await newDb.select(newDb.utilisateurs).get(),
        );
        expect(
          expectedNewCategoriesData,
          await newDb.select(newDb.categories).get(),
        );
        expect(
          expectedNewProduitsData,
          await newDb.select(newDb.produits).get(),
        );
        expect(expectedNewClientsData, await newDb.select(newDb.clients).get());
        expect(expectedNewVentesData, await newDb.select(newDb.ventes).get());
        expect(
          expectedNewLignesVenteData,
          await newDb.select(newDb.lignesVente).get(),
        );
        expect(
          expectedNewVersementsDetteData,
          await newDb.select(newDb.versementsDette).get(),
        );
        expect(
          expectedNewMouvementsStockData,
          await newDb.select(newDb.mouvementsStock).get(),
        );
      },
    );
  });
}
