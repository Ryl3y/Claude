import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/core/saisie.dart';
import 'package:kassa/data/db/champs_synchro.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/db/tables.dart';
import 'package:kassa/data/repositories/produits_repository.dart';
import 'package:kassa/domain/produit_saisie.dart';

import 'aide_base.dart';

ProduitSaisie riz({
  double quantite = 10,
  int prixAchat = 3000,
  String nom = 'Riz 5 kg',
}) => ProduitSaisie(
  nom: nom,
  prixAchat: prixAchat,
  prixVente: 3500,
  quantite: quantite,
  unite: 'sac',
  seuilAlerte: 3,
);

void main() {
  late KassaDatabase db;
  late ProduitsRepository repo;
  var heure = DateTime.utc(2026, 10, 10, 9);

  setUp(() {
    db = baseEnMemoire();
    heure = DateTime.utc(2026, 10, 10, 9);
    repo = ProduitsRepository(
      db,
      ChampsSynchro(appareilId: 'tel-1', horloge: () => heure),
    );
  });
  tearDown(() => db.close());

  Future<List<MouvementStock>> mouvements() =>
      db.select(db.mouvementsStock).get();

  group('création', () {
    test('produit + mouvement entree pour la quantité de départ', () async {
      final id = await repo.creerProduit(riz());
      final p = await (db.select(
        db.produits,
      )..where((x) => x.id.equals(id))).getSingle();
      expect(p.quantite, 10);
      expect(p.synchro, isFalse);
      expect(p.appareilId, 'tel-1');
      expect(p.majLe, heure);
      final m = await mouvements();
      expect(m.single.type, TypeMouvement.entree);
      expect(m.single.quantite, 10);
      expect(m.single.prixAchatUnitaire, 3000);
    });

    test('quantité 0 : aucun mouvement', () async {
      await repo.creerProduit(riz(quantite: 0));
      expect(await mouvements(), isEmpty);
    });

    test('nom vide refusé', () {
      expect(() => repo.creerProduit(riz(nom: '  ')), throwsArgumentError);
    });

    test('catégorie créée puis liée', () async {
      final cat = await repo.creerCategorie(
        nom: ' Épicerie ',
        icone: 'grocery',
      );
      final id = await repo.creerProduit(
        ProduitSaisie(
          nom: 'Huile',
          categorieId: cat,
          prixAchat: 1200,
          prixVente: 1500,
          quantite: 0,
          unite: 'bouteille',
          seuilAlerte: 4,
        ),
      );
      final p = await (db.select(
        db.produits,
      )..where((x) => x.id.equals(id))).getSingle();
      expect(p.categorieId, cat);
      final c = await db.select(db.categories).getSingle();
      expect(c.nom, 'Épicerie');
    });
  });

  group('modification', () {
    test('quantité changée : mouvement correction de l\'écart', () async {
      final id = await repo.creerProduit(riz());
      heure = heure.add(const Duration(minutes: 5));
      await repo.modifierProduit(id, riz(quantite: 7.5));
      final m = await mouvements();
      expect(m.map((x) => x.type), [
        TypeMouvement.entree,
        TypeMouvement.correction,
      ]);
      expect(m.last.quantite, -2.5);
      final p = await (db.select(
        db.produits,
      )..where((x) => x.id.equals(id))).getSingle();
      expect(p.quantite, 7.5);
      expect(p.majLe, heure);
    });

    test('quantité inchangée : aucun mouvement de plus', () async {
      final id = await repo.creerProduit(riz());
      await repo.modifierProduit(id, riz(prixAchat: 3100));
      expect(await mouvements(), hasLength(1));
    });

    test('produit supprimé : modification refusée', () async {
      final id = await repo.creerProduit(riz());
      await repo.supprimerProduit(id);
      expect(() => repo.modifierProduit(id, riz()), throwsStateError);
    });
  });

  group('réappro', () {
    test(
      'entrée au nouveau prix, prix d\'achat du produit mis à jour',
      () async {
        final id = await repo.creerProduit(riz());
        final stock = await repo.reapprovisionner(
          produitId: id,
          quantite: 12,
          nouveauPrixAchat: 3200,
        );
        expect(stock, 22);
        final p = await (db.select(
          db.produits,
        )..where((x) => x.id.equals(id))).getSingle();
        expect(p.prixAchat, 3200);
        expect(p.quantite, 22);
        final m = await mouvements();
        expect(m.last.type, TypeMouvement.entree);
        expect(m.last.prixAchatUnitaire, 3200);
      },
    );

    test('sans nouveau prix : prix actuel copié dans le mouvement', () async {
      final id = await repo.creerProduit(riz());
      await repo.reapprovisionner(produitId: id, quantite: 1.5);
      final m = await mouvements();
      expect(m.last.prixAchatUnitaire, 3000);
      expect(m.last.quantite, 1.5);
    });

    test('quantité 0 refusée', () async {
      final id = await repo.creerProduit(riz());
      expect(
        () => repo.reapprovisionner(produitId: id, quantite: 0),
        throwsArgumentError,
      );
    });

    test('l\'alerte disparaît quand le seuil est dépassé', () async {
      final id = await repo.creerProduit(riz(quantite: 2));
      var p = await (db.select(
        db.produits,
      )..where((x) => x.id.equals(id))).getSingle();
      expect(p.quantite <= p.seuilAlerte, isTrue);
      await repo.reapprovisionner(produitId: id, quantite: 5);
      p = await (db.select(
        db.produits,
      )..where((x) => x.id.equals(id))).getSingle();
      expect(p.quantite <= p.seuilAlerte, isFalse);
    });
  });

  group('lecture', () {
    test('liste triée, sans les produits supprimés', () async {
      await repo.creerProduit(riz(nom: 'savon'));
      final b = await repo.creerProduit(riz(nom: 'Bière'));
      await repo.creerProduit(riz(nom: 'Arachide'));
      await repo.supprimerProduit(b);
      final liste = await repo.surveillerProduits().first;
      expect(liste.map((p) => p.nom), ['Arachide', 'savon']);
    });

    test('suppression logique : la ligne reste, en attente d\'envoi', () async {
      final id = await repo.creerProduit(riz());
      await (db.update(db.produits)..where((p) => p.id.equals(id))).write(
        const ProduitsCompanion(synchro: Value(true)),
      );
      await repo.supprimerProduit(id);
      final p = await (db.select(
        db.produits,
      )..where((x) => x.id.equals(id))).getSingle();
      expect(p.supprimeLe, heure);
      expect(p.majLe, heure);
      expect(p.synchro, isFalse);
    });

    test('seuil par défaut : celui de la boutique, sinon 5', () async {
      expect(await repo.seuilParDefaut(), 5);
      await Donnees.inserer(db);
      expect(await repo.seuilParDefaut(), 5);
      await (db.update(db.boutiques))
          .write(const BoutiquesCompanion(seuilAlerteDefaut: Value(8)));
      expect(await repo.seuilParDefaut(), 8);
    });
  });

  group('saisie au clavier', () {
    test('montants', () {
      expect(Saisie.montant('3 500'), 3500);
      expect(Saisie.montant('0'), 0);
      expect(Saisie.montant('12,5'), isNull);
      expect(Saisie.montant(''), isNull);
      expect(Saisie.montant('-5'), isNull);
    });
    test('quantités', () {
      expect(Saisie.quantite('12'), 12);
      expect(Saisie.quantite('1,5'), 1.5);
      expect(Saisie.quantite('1.25'), 1.25);
      expect(Saisie.quantite('1,2345'), isNull);
      expect(Saisie.quantite('abc'), isNull);
    });
    test('recherche sans accents', () {
      expect(Saisie.pourRecherche('Épicerie Fine'), 'epicerie fine');
      expect(Saisie.pourRecherche('Bœuf'), 'boeuf');
    });
  });
}
