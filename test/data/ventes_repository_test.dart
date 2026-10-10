import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/db/champs_synchro.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/db/tables.dart';
import 'package:kassa/data/repositories/boutique_repository.dart';
import 'package:kassa/data/repositories/clients_repository.dart';
import 'package:kassa/data/repositories/produits_repository.dart';
import 'package:kassa/data/repositories/ventes_repository.dart';
import 'package:kassa/domain/panier.dart';
import 'package:kassa/domain/produit_saisie.dart';

import 'aide_base.dart';

void main() {
  late KassaDatabase db;
  late VentesRepository ventes;
  late ProduitsRepository produits;
  late ClientsRepository clients;
  late String utilisateurId;
  var heure = DateTime.utc(2026, 10, 10, 9);

  setUp(() async {
    db = baseEnMemoire();
    heure = DateTime.utc(2026, 10, 10, 9);
    final champs = ChampsSynchro(appareilId: 'tel-1', horloge: () => heure);
    ventes = VentesRepository(db, champs);
    produits = ProduitsRepository(db, champs);
    clients = ClientsRepository(db, champs);
    utilisateurId = (await BoutiqueRepository(
      db,
      champs,
    ).utilisateurCourant()).id;
  });
  tearDown(() => db.close());

  Future<LignePanier> ligne(
    String nom, {
    double quantite = 1,
    double stock = 10,
    int prix = 3500,
    int achat = 3000,
  }) async {
    final id = await produits.creerProduit(
      ProduitSaisie(
        nom: nom,
        prixAchat: achat,
        prixVente: prix,
        quantite: stock,
        unite: 'pièce',
        seuilAlerte: 2,
      ),
    );
    return LignePanier(
      produitId: id,
      nom: nom,
      unite: 'pièce',
      prixUnitaire: prix,
      prixAchatUnitaire: achat,
      quantite: quantite,
      stockDisponible: stock,
    );
  }

  Future<double> stock(String id) async => (await (db.select(
    db.produits,
  )..where((p) => p.id.equals(id))).getSingle()).quantite;

  test('utilisateur provisoire créé une seule fois', () async {
    final champs = ChampsSynchro(appareilId: 'tel-1');
    final a = await BoutiqueRepository(db, champs).utilisateurCourant();
    final b = await BoutiqueRepository(db, champs).utilisateurCourant();
    expect(a.id, b.id);
    expect(await db.select(db.boutiques).get(), hasLength(1));
  });

  group('vente espèces', () {
    test(
      'vente + lignes copiées + mouvements « vente » + baisse du stock',
      () async {
        final riz = await ligne('Riz', quantite: 2);
        final savon = await ligne('Savon', quantite: 3, prix: 250, achat: 200);
        final panier = const Panier().ajouter(riz).ajouter(savon);
        final paiement = CalculPaiement.pour(
          mode: ModeChoisi.especes,
          total: panier.total,
          saisi: 10000,
        );
        final v = await ventes.enregistrerVente(
          panier: panier,
          mode: ModeChoisi.especes,
          paiement: paiement,
          utilisateurId: utilisateurId,
        );
        expect(v.total, 7750);
        expect(v.montantPaye, 7750);
        expect(v.resteAPayer, 0);
        expect(v.benefice, 1150);
        expect(v.modePaiement, ModePaiement.especes);
        expect(v.numero, 1);
        expect(paiement.monnaie, 2250);
        final lignes = await db.select(db.lignesVente).get();
        expect(lignes.map((l) => l.nomProduit), containsAll(['Riz', 'Savon']));
        final mvts = await (db.select(
          db.mouvementsStock,
        )..where((m) => m.type.equals(TypeMouvement.vente))).get();
        expect(mvts.map((m) => m.quantite), containsAll([-2.0, -3.0]));
        expect(mvts.every((m) => m.referenceId == v.id), isTrue);
        expect(await stock(riz.produitId), 8);
        expect(await stock(savon.produitId), 7);
      },
    );

    test('montant reçu insuffisant : refusé', () async {
      final riz = await ligne('Riz');
      final panier = const Panier().ajouter(riz);
      final paiement = CalculPaiement.pour(
        mode: ModeChoisi.especes,
        total: panier.total,
        saisi: 1000,
      );
      expect(paiement.manque, 2500);
      expect(
        () => ventes.enregistrerVente(
          panier: panier,
          mode: ModeChoisi.especes,
          paiement: paiement,
          utilisateurId: utilisateurId,
        ),
        throwsArgumentError,
      );
    });

    test('panier vide : refusé', () {
      expect(
        () => ventes.enregistrerVente(
          panier: const Panier(),
          mode: ModeChoisi.especes,
          paiement: CalculPaiement.pour(mode: ModeChoisi.especes, total: 0),
          utilisateurId: utilisateurId,
        ),
        throwsArgumentError,
      );
    });

    test('vente plus grande que le stock : acceptée, stock négatif', () async {
      final riz = await ligne('Riz', quantite: 3, stock: 1);
      expect(riz.depasseLeStock, isTrue);
      final panier = const Panier().ajouter(riz);
      await ventes.enregistrerVente(
        panier: panier,
        mode: ModeChoisi.momo,
        paiement: CalculPaiement.pour(
          mode: ModeChoisi.momo,
          total: panier.total,
        ),
        utilisateurId: utilisateurId,
      );
      expect(await stock(riz.produitId), -2);
    });
  });

  group('numéro du jour (heure de Douala)', () {
    test('1, 2, puis 1 le lendemain', () async {
      final riz = await ligne('Riz', stock: 100);
      final panier = const Panier().ajouter(riz);
      final p = CalculPaiement.pour(
        mode: ModeChoisi.especes,
        total: panier.total,
      );
      Future<int> vendre() async => (await ventes.enregistrerVente(
        panier: panier,
        mode: ModeChoisi.especes,
        paiement: p,
        utilisateurId: utilisateurId,
      )).numero;
      expect(await vendre(), 1);
      expect(await vendre(), 2);
      heure = DateTime.utc(2026, 10, 10, 23, 30); // 0 h 30 le 11 à Douala
      expect(await vendre(), 1);
    });
  });

  group('vente à crédit', () {
    test('le reste à payer s\'ajoute à la dette du client', () async {
      final riz = await ligne('Riz', quantite: 2);
      final clientId = await clients.creerClient(
        nom: 'Maman Brigitte',
        telephone: '690000001',
      );
      final panier = const Panier().ajouter(riz);
      final paiement = CalculPaiement.pour(
        mode: ModeChoisi.credit,
        total: panier.total,
        saisi: 2000,
      );
      expect(paiement.resteAPayer, 5000);
      final v = await ventes.enregistrerVente(
        panier: panier,
        mode: ModeChoisi.credit,
        paiement: paiement,
        utilisateurId: utilisateurId,
        clientId: clientId,
      );
      expect(v.clientId, clientId);
      expect(v.modePaiement, ModePaiement.credit);
      final c = await (db.select(
        db.clients,
      )..where((x) => x.id.equals(clientId))).getSingle();
      expect(c.soldeDette, 5000);
    });

    test('avance 0 : toute la vente en dette', () async {
      final riz = await ligne('Riz');
      final clientId = await clients.creerClient(nom: 'Paul');
      final panier = const Panier().ajouter(riz);
      await ventes.enregistrerVente(
        panier: panier,
        mode: ModeChoisi.credit,
        paiement: CalculPaiement.pour(
          mode: ModeChoisi.credit,
          total: panier.total,
        ),
        utilisateurId: utilisateurId,
        clientId: clientId,
      );
      final c = await (db.select(
        db.clients,
      )..where((x) => x.id.equals(clientId))).getSingle();
      expect(c.soldeDette, 3500);
    });

    test('sans client : refusé', () async {
      final riz = await ligne('Riz');
      final panier = const Panier().ajouter(riz);
      expect(
        () => ventes.enregistrerVente(
          panier: panier,
          mode: ModeChoisi.credit,
          paiement: CalculPaiement.pour(
            mode: ModeChoisi.credit,
            total: panier.total,
          ),
          utilisateurId: utilisateurId,
        ),
        throwsArgumentError,
      );
    });
  });

  group('annulation', () {
    test('stock remis (mouvements « annulation ») et dette retirée', () async {
      final riz = await ligne('Riz', quantite: 2);
      final clientId = await clients.creerClient(nom: 'Awa');
      final panier = const Panier().ajouter(riz);
      final v = await ventes.enregistrerVente(
        panier: panier,
        mode: ModeChoisi.credit,
        paiement: CalculPaiement.pour(
          mode: ModeChoisi.credit,
          total: panier.total,
          saisi: 1000,
        ),
        utilisateurId: utilisateurId,
        clientId: clientId,
      );
      expect(await stock(riz.produitId), 8);
      heure = heure.add(const Duration(minutes: 10));
      await ventes.annulerVente(v.id);
      expect(await stock(riz.produitId), 10);
      final c = await (db.select(
        db.clients,
      )..where((x) => x.id.equals(clientId))).getSingle();
      expect(c.soldeDette, 0);
      final vente = await (db.select(
        db.ventes,
      )..where((x) => x.id.equals(v.id))).getSingle();
      expect(vente.annulee, isTrue);
      expect(vente.synchro, isFalse);
      expect(vente.majLe, heure);
      final annul = await (db.select(
        db.mouvementsStock,
      )..where((m) => m.type.equals(TypeMouvement.annulation))).get();
      expect(annul.single.quantite, 2);
      expect(annul.single.referenceId, v.id);
    });

    test('annuler deux fois : refusé', () async {
      final riz = await ligne('Riz');
      final panier = const Panier().ajouter(riz);
      final v = await ventes.enregistrerVente(
        panier: panier,
        mode: ModeChoisi.especes,
        paiement: CalculPaiement.pour(
          mode: ModeChoisi.especes,
          total: panier.total,
        ),
        utilisateurId: utilisateurId,
      );
      await ventes.annulerVente(v.id);
      expect(() => ventes.annulerVente(v.id), throwsStateError);
    });
  });

  group('lecture', () {
    test('historique du jour et détail avec lignes et client', () async {
      final riz = await ligne('Riz', stock: 50);
      final clientId = await clients.creerClient(nom: 'Awa');
      final panier = const Panier().ajouter(riz);
      final v = await ventes.enregistrerVente(
        panier: panier,
        mode: ModeChoisi.credit,
        paiement: CalculPaiement.pour(
          mode: ModeChoisi.credit,
          total: panier.total,
        ),
        utilisateurId: utilisateurId,
        clientId: clientId,
      );
      final liste = await ventes.surveillerVentes().first;
      expect(liste.single.id, v.id);
      final detail = await ventes.surveillerVente(v.id).first;
      expect(detail!.lignes.single.nomProduit, 'Riz');
      expect(detail.client!.nom, 'Awa');
    });
  });
}
