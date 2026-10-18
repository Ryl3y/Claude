import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/db/champs_synchro.dart';
import 'package:kassa/data/repositories/boutique_repository.dart';
import 'package:kassa/domain/boutique_saisie.dart';

import 'aide_base.dart';

void main() {
  final plusTard = maintenant.add(const Duration(hours: 1));

  test('modifier la boutique : textes nettoyés, à sauvegarder', () async {
    final db = baseEnMemoire();
    addTearDown(db.close);
    await Donnees.inserer(db);
    // Déjà sauvegardée en ligne : la modification devra repartir.
    await db
        .update(db.boutiques)
        .write(const BoutiquesCompanion(synchro: Value(true)));
    final depot = BoutiqueRepository(
      db,
      ChampsSynchro(appareilId: 'tel-2', horloge: () => plusTard),
    );

    await depot.modifierBoutique(
      Donnees.boutiqueId,
      saisie: const BoutiqueSaisie(
        nom: '  Chez Brigitte et fils ',
        typeCommerce: 'quincaillerie',
        ville: ' Yaoundé',
        quartier: 'Mokolo ',
      ),
      seuilAlerteDefaut: 8,
    );

    final b = await depot.surveillerBoutique(Donnees.boutiqueId).first;
    expect(b!.nom, 'Chez Brigitte et fils');
    expect(b.typeCommerce, 'quincaillerie');
    expect(b.ville, 'Yaoundé');
    expect(b.quartier, 'Mokolo');
    expect(b.seuilAlerteDefaut, 8);
    expect(b.majLe, plusTard);
    expect(b.appareilId, 'tel-2');
    expect(b.synchro, isFalse);
    expect(b.telephone, '237690000000'); // inchangé
  });

  test(
    'champs vides, seuil négatif ou trop grand refusés, rien ne change',
    () async {
      final db = baseEnMemoire();
      addTearDown(db.close);
      await Donnees.inserer(db);
      final depot = BoutiqueRepository(db, ChampsSynchro(appareilId: 'tel-2'));

      for (final (saisie, seuil) in [
        (
          const BoutiqueSaisie(
            nom: '  ',
            typeCommerce: 'autre',
            ville: 'Douala',
            quartier: 'Akwa',
          ),
          5,
        ),
        (
          const BoutiqueSaisie(
            nom: 'Chez Brigitte',
            typeCommerce: 'autre',
            ville: 'Douala',
            quartier: 'Akwa',
          ),
          -1,
        ),
        (
          const BoutiqueSaisie(
            nom: 'Chez Brigitte',
            typeCommerce: 'autre',
            ville: 'Douala',
            quartier: 'Akwa',
          ),
          seuilAlerteDefautMax + 1, // hors de l'entier du serveur
        ),
      ]) {
        await expectLater(
          depot.modifierBoutique(
            Donnees.boutiqueId,
            saisie: saisie,
            seuilAlerteDefaut: seuil,
          ),
          throwsArgumentError,
        );
      }
      final b = await depot.surveillerBoutique(Donnees.boutiqueId).first;
      expect(b!.nom, 'Chez Maman Brigitte');
    },
  );
}
