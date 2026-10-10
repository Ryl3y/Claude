import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/db/champs_synchro.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/db/tables.dart';
import 'package:kassa/data/repositories/boutique_repository.dart';
import 'package:kassa/data/repositories/clients_repository.dart';
import 'package:kassa/data/repositories/produits_repository.dart';
import 'package:kassa/data/repositories/ventes_repository.dart';
import 'package:kassa/domain/client_saisie.dart';
import 'package:kassa/domain/panier.dart';
import 'package:kassa/domain/produit_saisie.dart';

import 'aide_base.dart';

void main() {
  late KassaDatabase db;
  late DateTime heure;
  late ClientsRepository clients;
  late VentesRepository ventes;
  late ProduitsRepository produits;
  late String utilisateurId;

  setUp(() async {
    db = baseEnMemoire();
    heure = DateTime.utc(2026, 10, 10, 9);
    final champs = ChampsSynchro(appareilId: 'tel-1', horloge: () => heure);
    clients = ClientsRepository(db, champs);
    ventes = VentesRepository(db, champs);
    produits = ProduitsRepository(db, champs);
    utilisateurId = (await BoutiqueRepository(
      db,
      champs,
    ).utilisateurCourant()).id;
  });
  tearDown(() => db.close());

  Future<Client> lire(String id) =>
      (db.select(db.clients)..where((c) => c.id.equals(id))).getSingle();

  /// Vente à crédit de [total] FCFA (un article), avec [avance].
  Future<Vente> credit(String clientId, int total, {int avance = 0}) async {
    final produitId = await produits.creerProduit(
      ProduitSaisie(
        nom: 'Article $total',
        prixAchat: total ~/ 2,
        prixVente: total,
        quantite: 10,
        unite: 'pièce',
        seuilAlerte: 1,
      ),
    );
    final panier = const Panier().ajouter(
      LignePanier(
        produitId: produitId,
        nom: 'Article $total',
        unite: 'pièce',
        prixUnitaire: total,
        prixAchatUnitaire: total ~/ 2,
        quantite: 1,
        stockDisponible: 10,
      ),
    );
    return ventes.enregistrerVente(
      panier: panier,
      mode: ModeChoisi.credit,
      paiement: CalculPaiement.pour(
        mode: ModeChoisi.credit,
        total: total,
        saisi: avance,
      ),
      utilisateurId: utilisateurId,
      clientId: clientId,
    );
  }

  group('création et modification', () {
    test('saisie nettoyée et champs de synchro remplis', () async {
      final id = await clients.creerClient(
        nom: ' Maman Brigitte ',
        telephone: ' 690000001 ',
        note: ' ',
      );
      final c = await lire(id);
      expect(c.nom, 'Maman Brigitte');
      expect(c.telephone, '690000001');
      expect(c.note, isNull);
      expect(c.soldeDette, 0);
      expect(c.synchro, isFalse);
      expect(c.appareilId, 'tel-1');
    });

    test('téléphone invalide : refusé', () {
      expect(
        () => clients.creerClient(nom: 'Paul', telephone: '12345'),
        throwsA(
          isA<ClientInvalide>().having((e) => e.erreurs, 'erreurs', {
            ErreurClient.telephoneInvalide,
          }),
        ),
      );
    });

    test('modifier : nom, téléphone, note ; solde inchangé', () async {
      final id = await clients.creerClient(nom: 'Paul');
      await credit(id, 3000);
      heure = heure.add(const Duration(hours: 1));
      await clients.modifierClient(
        id,
        const ClientSaisie(
          nom: 'Paul Ngando',
          telephone: '677123456',
          note: 'Paie le samedi',
        ),
      );
      final c = await lire(id);
      expect(c.nom, 'Paul Ngando');
      expect(c.telephone, '677123456');
      expect(c.note, 'Paie le samedi');
      expect(c.soldeDette, 3000);
      expect(c.majLe, heure);
    });
  });

  group('versements', () {
    test('le versement baisse la dette ; reste renvoyé', () async {
      final id = await clients.creerClient(nom: 'Awa');
      await credit(id, 12500, avance: 2500);
      expect((await lire(id)).soldeDette, 10000);
      heure = heure.add(const Duration(days: 1));
      final r = await clients.enregistrerVersement(
        clientId: id,
        montant: 4000,
        mode: ModeChoisi.momo,
      );
      expect(r.reste, 6000);
      expect(r.versement.montant, 4000);
      expect(r.versement.modePaiement, ModePaiement.momo);
      expect(r.versement.dateVersement, heure);
      expect(r.versement.synchro, isFalse);
      expect((await lire(id)).soldeDette, 6000);
    });

    test('toute la dette : solde à 0', () async {
      final id = await clients.creerClient(nom: 'Awa');
      await credit(id, 5000);
      final r = await clients.enregistrerVersement(
        clientId: id,
        montant: 5000,
        mode: ModeChoisi.especes,
      );
      expect(r.reste, 0);
    });

    test('plus que la dette : refusé, rien enregistré', () async {
      final id = await clients.creerClient(nom: 'Awa');
      await credit(id, 5000);
      await expectLater(
        clients.enregistrerVersement(
          clientId: id,
          montant: 5001,
          mode: ModeChoisi.especes,
        ),
        throwsA(
          isA<VersementTropGrand>().having((e) => e.soldeDette, 'solde', 5000),
        ),
      );
      expect(await db.select(db.versementsDette).get(), isEmpty);
      expect((await lire(id)).soldeDette, 5000);
    });

    test('montant nul ou mode crédit : refusé', () async {
      final id = await clients.creerClient(nom: 'Awa');
      await credit(id, 5000);
      expect(
        () => clients.enregistrerVersement(
          clientId: id,
          montant: 0,
          mode: ModeChoisi.especes,
        ),
        throwsArgumentError,
      );
      expect(
        () => clients.enregistrerVersement(
          clientId: id,
          montant: 1000,
          mode: ModeChoisi.credit,
        ),
        throwsArgumentError,
      );
    });
  });

  group('suppression', () {
    test('refusée tant que le client doit', () async {
      final id = await clients.creerClient(nom: 'Awa');
      await credit(id, 5000);
      await expectLater(
        clients.supprimerClient(id),
        throwsA(isA<ClientEndette>()),
      );
      expect((await lire(id)).supprimeLe, isNull);
    });

    test('client à jour : suppression logique, sorti de la liste', () async {
      final id = await clients.creerClient(nom: 'Awa');
      await clients.supprimerClient(id);
      final c = await lire(id);
      expect(c.supprimeLe, heure);
      expect(c.majLe, heure);
      expect(c.synchro, isFalse);
      expect(await clients.surveillerClients().first, isEmpty);
      expect(await clients.surveillerClient(id).first, isNull);
    });
  });

  group('lecture', () {
    test('liste : plus grosse dette d\'abord, dernier achat', () async {
      final petit = await clients.creerClient(nom: 'Petit');
      final gros = await clients.creerClient(nom: 'Gros');
      final jamais = await clients.creerClient(nom: 'Aïcha');
      await credit(petit, 1000);
      heure = heure.add(const Duration(days: 1));
      await credit(gros, 9000);
      final liste = await clients.surveillerResumes().first;
      expect(liste.map((r) => r.client.id), [gros, petit, jamais]);
      expect(liste[0].dernierAchat, heure);
      expect(liste[1].dernierAchat, heure.subtract(const Duration(days: 1)));
      expect(liste[2].dernierAchat, isNull);
    });

    test('historique : achats et versements, plus récents d\'abord', () async {
      final id = await clients.creerClient(nom: 'Awa');
      final v = await credit(id, 5000);
      heure = heure.add(const Duration(hours: 2));
      await clients.enregistrerVersement(
        clientId: id,
        montant: 2000,
        mode: ModeChoisi.orangeMoney,
      );
      final h = await clients.surveillerHistorique(id).first;
      expect(h, hasLength(2));
      expect(h[0], isA<VersementClient>());
      expect((h[0] as VersementClient).versement.montant, 2000);
      expect(h[1], isA<AchatClient>());
      expect((h[1] as AchatClient).vente.id, v.id);
    });

    test('l\'historique se met à jour après un versement', () async {
      final id = await clients.creerClient(nom: 'Awa');
      await credit(id, 5000);
      final flux = clients.surveillerHistorique(id);
      final attendu = expectLater(flux.map((h) => h.length), emitsThrough(2));
      await clients.enregistrerVersement(
        clientId: id,
        montant: 1000,
        mode: ModeChoisi.especes,
      );
      await attendu;
    });
  });
}
