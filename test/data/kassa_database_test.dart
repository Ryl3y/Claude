import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/db/champs_synchro.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/db/tables.dart';

import 'aide_base.dart';

void main() {
  late KassaDatabase db;

  setUp(() async {
    db = baseEnMemoire();
    await Donnees.inserer(db);
  });

  tearDown(() => db.close());

  group('tables : chaque écriture part en attente d\'envoi', () {
    test('boutiques', () async {
      final b = await db.select(db.boutiques).getSingle();
      expect(b.nom, 'Chez Maman Brigitte');
      expect(b.synchro, isFalse);
      expect(b.supprimeLe, isNull);
      expect(b.creeLe, maintenant);
      expect(b.creeLe.isUtc, isTrue);
    });

    test('utilisateurs : rôle propriétaire par défaut', () async {
      final u = await db.select(db.utilisateurs).getSingle();
      expect(u.role, Role.proprietaire);
      expect(u.boutiqueId, Donnees.boutiqueId);
      expect(u.synchro, isFalse);
    });

    test('categories', () async {
      final c = await db.select(db.categories).getSingle();
      expect(c.nom, 'Épicerie');
      expect(c.appareilId, appareil);
    });

    test('produits : stock à 0 au départ', () async {
      final p = await db.select(db.produits).getSingle();
      expect(p.quantite, 0);
      expect(p.prixVente, 3500);
      expect(p.photoLocale, isNull);
    });

    test('clients : dette à 0 au départ', () async {
      final c = await db.select(db.clients).getSingle();
      expect(c.soldeDette, 0);
      expect(c.synchro, isFalse);
    });

    test('ventes et lignes_vente : nom et prix copiés', () async {
      await Donnees.vente(db, 1, total: 7000, paye: 7000, mode: ModePaiement.especes);
      await db.into(db.lignesVente).insert(LignesVenteCompanion.insert(
            id: uuid(400),
            venteId: uuid(201),
            produitId: Donnees.produitId,
            nomProduit: 'Riz 5 kg',
            quantite: 2,
            prixUnitaire: 3500,
            prixAchatUnitaire: 3000,
            majLe: maintenant,
            appareilId: appareil,
          ));
      // Le prix du produit change ensuite : la ligne garde l'ancien prix.
      await (db.update(db.produits)..where((p) => p.id.equals(Donnees.produitId)))
          .write(const ProduitsCompanion(prixVente: Value(4000)));
      final ligne = await db.select(db.lignesVente).getSingle();
      expect(ligne.prixUnitaire, 3500);
      expect(ligne.nomProduit, 'Riz 5 kg');
      final vente = await db.select(db.ventes).getSingle();
      expect(vente.annulee, isFalse);
      expect(vente.resteAPayer, 0);
    });

    test('versements_dette', () async {
      await Donnees.versement(db, 1, 2000);
      final v = await db.select(db.versementsDette).getSingle();
      expect(v.montant, 2000);
      expect(v.modePaiement, ModePaiement.especes);
    });

    test('mouvements_stock', () async {
      await Donnees.mouvement(db, 1, 10);
      final m = await db.select(db.mouvementsStock).getSingle();
      expect(m.type, TypeMouvement.entree);
      expect(m.quantite, 10);
    });
  });

  group('contraintes', () {
    test('mode de paiement inconnu refusé', () async {
      expect(
        () => Donnees.vente(db, 1, total: 100, paye: 100, mode: 'cheque'),
        throwsA(isA<Exception>()),
      );
    });

    test('pas de crédit pour un versement', () async {
      expect(
        () => db.into(db.versementsDette).insert(VersementsDetteCompanion.insert(
              id: uuid(399),
              clientId: Donnees.clientId,
              montant: 100,
              modePaiement: ModePaiement.credit,
              dateVersement: maintenant,
              majLe: maintenant,
              appareilId: appareil,
            )),
        throwsA(isA<Exception>()),
      );
    });

    test('téléphone de boutique au mauvais format refusé (comme le serveur)', () async {
      expect(
        () => (db.update(db.boutiques)..where((b) => b.id.equals(Donnees.boutiqueId)))
            .write(const BoutiquesCompanion(telephone: Value('+237 690 00 00 00'))),
        throwsA(isA<Exception>()),
      );
    });

    test('prix d\'achat négatif refusé dans un mouvement', () async {
      expect(
        () => db.into(db.mouvementsStock).insert(MouvementsStockCompanion.insert(
              id: uuid(151),
              produitId: Donnees.produitId,
              type: TypeMouvement.entree,
              quantite: 1,
              prixAchatUnitaire: const Value(-1),
              dateMouvement: maintenant,
              majLe: maintenant,
              appareilId: appareil,
            )),
        throwsA(isA<Exception>()),
      );
    });

    test('type de mouvement inconnu refusé', () async {
      expect(() => Donnees.mouvement(db, 1, 1, type: 'vol'), throwsA(isA<Exception>()));
    });

    test('clé étrangère vérifiée : produit inexistant refusé', () async {
      expect(
        () => db.into(db.mouvementsStock).insert(MouvementsStockCompanion.insert(
              id: uuid(150),
              produitId: uuid(999),
              type: TypeMouvement.entree,
              quantite: 1,
              dateMouvement: maintenant,
              majLe: maintenant,
              appareilId: appareil,
            )),
        throwsA(isA<Exception>()),
      );
    });

    test('quantité vendue nulle refusée', () async {
      await Donnees.vente(db, 1, total: 0, paye: 0, mode: ModePaiement.especes);
      expect(
        () => db.into(db.lignesVente).insert(LignesVenteCompanion.insert(
              id: uuid(401),
              venteId: uuid(201),
              produitId: Donnees.produitId,
              nomProduit: 'Riz 5 kg',
              quantite: 0,
              prixUnitaire: 3500,
              prixAchatUnitaire: 3000,
              majLe: maintenant,
              appareilId: appareil,
            )),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('stock recalculé depuis mouvements_stock', () {
    test('entrée, ventes, perte, annulation', () async {
      await Donnees.mouvement(db, 1, 10);
      await Donnees.mouvement(db, 2, -2, type: TypeMouvement.vente, reference: uuid(201));
      await Donnees.mouvement(db, 3, -1, type: TypeMouvement.perte);
      await Donnees.mouvement(db, 4, 2, type: TypeMouvement.annulation, reference: uuid(201));
      expect(await db.calculerStock(Donnees.produitId), 9);
    });

    test('vrac décimal', () async {
      await Donnees.mouvement(db, 1, 5);
      await Donnees.mouvement(db, 2, -1.5, type: TypeMouvement.vente);
      await Donnees.mouvement(db, 3, -1.25, type: TypeMouvement.vente);
      expect(await db.calculerStock(Donnees.produitId), 2.25);
    });

    test('mouvement supprimé ignoré', () async {
      await Donnees.mouvement(db, 1, 10);
      await Donnees.mouvement(db, 2, -3, type: TypeMouvement.correction, supprimeLe: maintenant);
      expect(await db.calculerStock(Donnees.produitId), 10);
    });

    test('sans mouvement : 0', () async {
      expect(await db.calculerStock(Donnees.produitId), 0);
    });

    test('recalculerStock écrit la quantité sans repasser en attente d\'envoi', () async {
      await (db.update(db.produits)..where((p) => p.id.equals(Donnees.produitId)))
          .write(const ProduitsCompanion(synchro: Value(true)));
      await Donnees.mouvement(db, 1, 7);
      expect(await db.recalculerStock(Donnees.produitId), 7);
      final p = await db.select(db.produits).getSingle();
      expect(p.quantite, 7);
      expect(p.synchro, isTrue);
      expect(p.majLe, maintenant);
    });
  });

  group('solde_dette recalculé', () {
    test('ventes à crédit − versements', () async {
      await Donnees.vente(db, 1, total: 7000, paye: 2000);
      await Donnees.vente(db, 2, total: 3000, paye: 0);
      await Donnees.versement(db, 1, 4000);
      expect(await db.calculerSoldeDette(Donnees.clientId), 4000);
    });

    test('vente annulée retirée de la dette', () async {
      await Donnees.vente(db, 1, total: 7000, paye: 2000);
      await Donnees.vente(db, 2, total: 3000, paye: 0, annulee: true);
      expect(await db.calculerSoldeDette(Donnees.clientId), 5000);
    });

    test('versement supprimé ignoré', () async {
      await Donnees.vente(db, 1, total: 5000, paye: 0);
      await Donnees.versement(db, 1, 1000, supprimeLe: maintenant);
      expect(await db.calculerSoldeDette(Donnees.clientId), 5000);
    });

    test('vente payée comptant : aucune dette', () async {
      await Donnees.vente(db, 1, total: 5000, paye: 5000, mode: ModePaiement.especes);
      expect(await db.calculerSoldeDette(Donnees.clientId), 0);
    });

    test('recalculerSoldeDette', () async {
      await Donnees.vente(db, 1, total: 6000, paye: 1000);
      expect(await db.recalculerSoldeDette(Donnees.clientId), 5000);
      final c = await db.select(db.clients).getSingle();
      expect(c.soldeDette, 5000);
    });

    test('recalculerTout donne les mêmes résultats que les calculs un par un', () async {
      await Donnees.vente(db, 1, total: 6000, paye: 1000);
      await Donnees.vente(db, 2, total: 2000, paye: 0, annulee: true);
      await Donnees.versement(db, 1, 1500);
      await Donnees.versement(db, 2, 700, supprimeLe: maintenant);
      await Donnees.mouvement(db, 1, 5);
      await Donnees.mouvement(db, 2, -1.5, type: TypeMouvement.vente);
      await Donnees.mouvement(db, 3, -0.25, type: TypeMouvement.perte);
      await Donnees.mouvement(db, 4, -9, type: TypeMouvement.perte, supprimeLe: maintenant);
      await db.recalculerTout();
      final c = await db.select(db.clients).getSingle();
      final p = await db.select(db.produits).getSingle();
      expect(c.soldeDette, 3500);
      expect(c.soldeDette, await db.calculerSoldeDette(Donnees.clientId));
      expect(p.quantite, 3.25);
      expect(p.quantite, await db.calculerStock(Donnees.produitId));
    });
  });

  group('synchro', () {
    test('ordre d\'envoi des tables', () {
      expect(db.ordreSynchro.map((t) => t.actualTableName), [
        'boutiques',
        'categories',
        'produits',
        'clients',
        'ventes',
        'lignes_vente',
        'versements_dette',
        'mouvements_stock',
      ]);
    });

    test('ChampsSynchro : suppression avec une seule heure', () {
      var appels = 0;
      final champs = ChampsSynchro(
        appareilId: 'tel-1',
        horloge: () => DateTime.utc(2026, 10, 10, 12, 0, 0, appels++),
      );
      final s = champs.suppression();
      expect(s.majLe.value, s.supprimeLe.value);
      expect(appels, 1);
    });

    test('ChampsSynchro : maj_le en UTC, synchro=false, appareil', () {
      final champs = ChampsSynchro(
        appareilId: 'tel-1',
        horloge: () => DateTime.utc(2026, 10, 10, 12),
      );
      expect(champs.majLe.value, DateTime.utc(2026, 10, 10, 12));
      expect(champs.majLe.value.isUtc, isTrue);
      expect(champs.synchro.value, isFalse);
      expect(champs.appareil.value, 'tel-1');
    });

    test('dates gardées à la milliseconde (conflits départagés)', () async {
      final precis = DateTime.utc(2026, 10, 10, 9, 0, 0, 123);
      await (db.update(db.clients)..where((c) => c.id.equals(Donnees.clientId)))
          .write(ClientsCompanion(majLe: Value(precis)));
      final c = await db.select(db.clients).getSingle();
      expect(c.majLe, precis);
    });

    test('lignes en attente d\'envoi', () async {
      final enAttente = await (db.select(db.produits)..where((p) => p.synchro.equals(false))).get();
      expect(enAttente, hasLength(1));
    });
  });
}
