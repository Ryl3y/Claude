// Synchronisation drift ↔ serveur : envoi, coupure réseau, conflits,
// restauration sur un nouveau téléphone. Le serveur est un faux en mémoire
// qui suit les règles du vrai (voir faux_serveur.dart).
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/db/champs_synchro.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/repositories/clients_repository.dart';
import 'package:kassa/data/repositories/produits_repository.dart';
import 'package:kassa/data/repositories/ventes_repository.dart';
import 'package:kassa/data/synchro/synchro_service.dart';
import 'package:kassa/domain/panier.dart';
import 'package:kassa/domain/produit_saisie.dart';

import '../aide_base.dart';
import 'faux_serveur.dart';

/// Un téléphone : sa base, son horloge, ses dépôts et sa synchronisation.
class Telephone {
  Telephone(this.serveur, {String appareil = 'tel-a'})
    : db = baseEnMemoire(),
      curseurs = FauxCurseurs() {
    final champs = ChampsSynchro(appareilId: appareil, horloge: () => heure);
    produits = ProduitsRepository(db, champs);
    ventes = VentesRepository(db, champs);
    clients = ClientsRepository(db, champs);
    synchro = SynchroService(
      db,
      serveur,
      curseurs,
      boutiqueId: Donnees.boutiqueId,
      taillePaquet: 3,
    );
  }

  final FauxServeur serveur;
  final KassaDatabase db;
  final FauxCurseurs curseurs;
  DateTime heure = DateTime.utc(2026, 10, 10, 9);
  late final ProduitsRepository produits;
  late final VentesRepository ventes;
  late final ClientsRepository clients;
  late final SynchroService synchro;

  Future<Produit> produit(String id) =>
      (db.select(db.produits)..where((p) => p.id.equals(id))).getSingle();

  Future<Client> client(String id) =>
      (db.select(db.clients)..where((c) => c.id.equals(id))).getSingle();

  /// Vente à crédit de [quantite] riz à [clientId].
  Future<Vente> vendreACredit(String produitId, String clientId, double q) {
    final panier = const Panier().ajouter(
      LignePanier(
        produitId: produitId,
        nom: 'Riz',
        unite: 'sacs',
        prixUnitaire: 3500,
        prixAchatUnitaire: 3000,
        quantite: q,
        stockDisponible: 100,
      ),
    );
    return ventes.enregistrerVente(
      panier: panier,
      mode: ModeChoisi.credit,
      paiement: CalculPaiement.pour(
        mode: ModeChoisi.credit,
        total: panier.total,
        saisi: 0,
      ),
      utilisateurId: Donnees.utilisateurId,
      clientId: clientId,
    );
  }
}

void main() {
  late FauxServeur serveur;
  late Telephone a;

  setUp(() async {
    serveur = FauxServeur();
    a = Telephone(serveur);
    // Boutique et propriétaire (déjà créés à l'inscription).
    await Donnees.inserer(a.db);
  });
  tearDown(() => a.db.close());

  Future<String> riz(Telephone t, {double stock = 10}) =>
      t.produits.creerProduit(
        ProduitSaisie(
          nom: 'Riz',
          prixAchat: 3000,
          prixVente: 3500,
          quantite: stock,
          unite: 'sacs',
          seuilAlerte: 2,
        ),
      );

  group('envoi', () {
    test(
      'tout part, dans l\'ordre, avec boutique_id, puis synchro = true',
      () async {
        final id = await riz(a);
        final bilan = await a.synchro.synchroniser();
        expect(bilan.reussi, isTrue);
        expect(await a.synchro.enAttente(), 0);

        final p = serveur.tables['produits']![id]!;
        expect(p['boutique_id'], Donnees.boutiqueId);
        expect(p['nom'], 'Riz');
        expect(p['prix_vente'], 3500);
        expect(p['maj_le'], '2026-10-10T09:00:00.000Z');
        expect(p.containsKey('synchro'), isFalse);
        expect(p.containsKey('photo_locale'), isFalse);
        expect(
          serveur.tables['boutiques']![Donnees.boutiqueId]!.containsKey(
            'boutique_id',
          ),
          isFalse,
        );
        // Le mouvement « entree » du stock initial est parti aussi.
        expect(serveur.tables['mouvements_stock'], hasLength(1));
      },
    );

    test('paquets : plus de lignes que la taille d\'un envoi', () async {
      for (var i = 0; i < 8; i++) {
        await a.clients.creerClient(nom: 'Client $i');
      }
      await a.synchro.synchroniser();
      expect(serveur.tables['clients'], hasLength(9));
      expect(await a.synchro.enAttente(), 0);
    });

    test(
      'coupure réseau : rien n\'est marqué, renvoyé au passage suivant',
      () async {
        await riz(a);
        serveur.horsLigne = true;
        final echec = await a.synchro.synchroniser();
        expect(echec.reussi, isFalse);
        expect(await a.synchro.enAttente(), greaterThan(0));
        expect(serveur.tables, isEmpty);

        serveur.horsLigne = false;
        final reprise = await a.synchro.synchroniser();
        expect(reprise.reussi, isTrue);
        expect(await a.synchro.enAttente(), 0);
        expect(serveur.tables['produits'], hasLength(2));
      },
    );

    test('refus sur une table : les précédentes restent envoyées', () async {
      final produitId = await riz(a);
      await a.vendreACredit(produitId, Donnees.clientId, 1);
      serveur.tableEnEchec = 'ventes';
      final bilan = await a.synchro.synchroniser();
      expect(bilan.reussi, isFalse);
      expect(serveur.tables['produits'], hasLength(2));
      expect(serveur.tables['clients'], hasLength(1));
      expect(serveur.tables['ventes'], isNull);
      expect(serveur.tables['lignes_vente'], isNull);
      final restantes = await a.db
          .customSelect('SELECT COUNT(*) AS n FROM ventes WHERE synchro = 0')
          .getSingle();
      expect(restantes.read<int>('n'), 1);
    });

    test('ligne modifiée pendant l\'envoi : reste à envoyer', () async {
      final id = await riz(a);
      final serveurLent = _ServeurQuiModifie(serveur, () async {
        a.heure = a.heure.add(const Duration(minutes: 1));
        await (a.db.update(a.db.produits)..where((p) => p.id.equals(id))).write(
          ProduitsCompanion(
            nom: const Value('Riz parfumé'),
            majLe: Value(a.heure),
            synchro: const Value(false),
          ),
        );
      });
      final s = SynchroService(
        a.db,
        serveurLent,
        a.curseurs,
        boutiqueId: Donnees.boutiqueId,
      );
      await s.synchroniser();
      final p = await a.produit(id);
      expect(p.synchro, isFalse);
      expect(p.nom, 'Riz parfumé');
      await s.synchroniser();
      expect(serveur.tables['produits']![id]!['nom'], 'Riz parfumé');
    });
  });

  group('conflits', () {
    test('modification distante plus récente : elle gagne', () async {
      final id = await riz(a);
      await a.synchro.synchroniser();
      // Changement local à 9 h 05, pas encore envoyé…
      a.heure = DateTime.utc(2026, 10, 10, 9, 5);
      await a.produits.modifierProduit(
        id,
        const ProduitSaisie(
          nom: 'Riz local',
          prixAchat: 3000,
          prixVente: 3600,
          quantite: 10,
          unite: 'sacs',
          seuilAlerte: 2,
        ),
        quantiteAffichee: 10,
      );
      // … et un autre téléphone a changé le prix à 9 h 10.
      serveur.ecrireDepuisAutreTelephone('produits', id, {
        'nom': 'Riz distant',
        'prix_vente': 4000,
        'maj_le': '2026-10-10T09:10:00.000Z',
      });
      await a.synchro.synchroniser();
      final p = await a.produit(id);
      expect(p.nom, 'Riz distant');
      expect(p.prixVente, 4000);
      expect(p.synchro, isTrue);
    });

    test('modification locale plus récente : elle gagne partout', () async {
      final id = await riz(a);
      await a.synchro.synchroniser();
      serveur.ecrireDepuisAutreTelephone('produits', id, {
        'nom': 'Riz distant',
        'maj_le': '2026-10-10T09:05:00.000Z',
      });
      a.heure = DateTime.utc(2026, 10, 10, 9, 10);
      await a.produits.modifierProduit(
        id,
        const ProduitSaisie(
          nom: 'Riz local',
          prixAchat: 3000,
          prixVente: 3500,
          quantite: 10,
          unite: 'sacs',
          seuilAlerte: 2,
        ),
        quantiteAffichee: 10,
      );
      await a.synchro.synchroniser();
      expect((await a.produit(id)).nom, 'Riz local');
      expect(serveur.tables['produits']![id]!['nom'], 'Riz local');
    });

    test('le serveur ignore une version plus ancienne', () async {
      final id = await riz(a);
      await a.synchro.synchroniser();
      serveur.ecrireDepuisAutreTelephone('produits', id, {
        'nom': 'Riz récent',
        'maj_le': '2026-10-10T12:00:00.000Z',
      });
      await serveur.envoyer('produits', [
        {
          ...serveur.tables['produits']![id]!,
          'nom': 'Riz ancien',
          'maj_le': '2026-10-10T10:00:00.000Z',
        },
      ]);
      expect(serveur.tables['produits']![id]!['nom'], 'Riz récent');
    });

    test(
      'stock et dette : toujours recalculés, jamais repris du serveur',
      () async {
        final id = await riz(a, stock: 10);
        await a.vendreACredit(id, Donnees.clientId, 2);
        await a.synchro.synchroniser();
        // Valeurs fausses sur le serveur (calculées ailleurs, en retard…).
        serveur.ecrireDepuisAutreTelephone('produits', id, {
          'quantite': 999.0,
          'maj_le': '2026-10-10T11:00:00.000Z',
        });
        serveur.ecrireDepuisAutreTelephone('clients', Donnees.clientId, {
          'solde_dette': 1,
          'maj_le': '2026-10-10T11:00:00.000Z',
        });
        await a.synchro.synchroniser();
        expect((await a.produit(id)).quantite, 8);
        expect((await a.client(Donnees.clientId)).soldeDette, 7000);
      },
    );

    test('horloge du téléphone en avance : corrigée par le serveur, puis acceptée', () async {
      a.heure = DateTime.utc(2026, 10, 12, 9); // deux jours d'avance
      final id = await riz(a);
      await a.synchro.synchroniser();
      final distant = serveur.tables['produits']![id]!;
      expect(DateTime.parse(distant['maj_le']! as String).day, 10);
      // Au passage suivant, la version corrigée revient et remplace la locale.
      await a.synchro.synchroniser();
      final p = await a.produit(id);
      expect(p.majLe.day, 10);
      expect(p.synchro, isTrue);
    });
  });

  group('restauration sur un nouveau téléphone', () {
    test('tout revient : produits, ventes, dettes, stock recalculé', () async {
      final id = await riz(a, stock: 10);
      await a.vendreACredit(id, Donnees.clientId, 3);
      await a.clients.enregistrerVersement(
        clientId: Donnees.clientId,
        montant: 2000,
        mode: ModeChoisi.especes,
      );
      await (a.db.update(a.db.produits)..where((p) => p.id.equals(id))).write(
        const ProduitsCompanion(photoLocale: Value('/photos/riz.jpg')),
      );
      expect((await a.synchro.synchroniser()).reussi, isTrue);

      final b = Telephone(serveur, appareil: 'tel-b');
      addTearDown(b.db.close);
      final bilan = await b.synchro.synchroniser();
      expect(bilan.reussi, isTrue);
      expect(bilan.recues, greaterThan(0));

      final p = await b.produit(id);
      expect(p.nom, 'Riz');
      expect(p.quantite, 7);
      expect(p.synchro, isTrue);
      expect(p.photoLocale, isNull);
      expect((await b.client(Donnees.clientId)).soldeDette, 10500 - 2000);
      expect(await b.db.select(b.db.ventes).get(), hasLength(1));
      expect(await b.db.select(b.db.lignesVente).get(), hasLength(1));
      expect(await b.db.select(b.db.versementsDette).get(), hasLength(1));
      expect(await b.synchro.enAttente(), 0);
      // Le repère est gardé : le passage suivant ne retélécharge rien.
      expect((await b.synchro.synchroniser()).recues, 0);
    });

    test(
      'pages de téléchargement avec la même heure serveur : rien perdu',
      () async {
        for (var i = 0; i < 7; i++) {
          await a.clients.creerClient(nom: 'Client $i');
        }
        await a.synchro.synchroniser();
        // Même heure serveur pour tous les clients.
        final heure = serveur.tables['clients']!.values.first['serveur_maj_le'];
        for (final c in serveur.tables['clients']!.values) {
          c['serveur_maj_le'] = heure;
        }
        final b = Telephone(serveur, appareil: 'tel-b');
        addTearDown(b.db.close);
        await b.synchro.synchroniser();
        expect(await b.db.select(b.db.clients).get(), hasLength(8));
      },
    );

    test('ligne supprimée sur un téléphone : supprimée sur l\'autre', () async {
      final id = await riz(a);
      await a.synchro.synchroniser();
      final b = Telephone(serveur, appareil: 'tel-b');
      addTearDown(b.db.close);
      await b.synchro.synchroniser();

      a.heure = a.heure.add(const Duration(hours: 1));
      await a.produits.supprimerProduit(id);
      await a.synchro.synchroniser();
      await b.synchro.synchroniser();
      expect((await b.produit(id)).supprimeLe, isNotNull);
    });
  });

  group('cas difficiles', () {
    test(
      'écriture validée en retard (heure serveur plus ancienne) : reçue',
      () async {
        final id = await riz(a);
        await a.synchro.synchroniser();
        final b = Telephone(serveur, appareil: 'tel-b');
        addTearDown(b.db.close);
        await b.synchro.synchroniser();

        // Un autre téléphone écrit à 12 h 00 min 30 s (heure du serveur),
        // mais sa transaction n'est validée qu'après une plus récente que b
        // a déjà reçue.
        serveur.avancer(const Duration(minutes: 1));
        await a.clients.creerClient(nom: 'Récent');
        await a.synchro.synchroniser();
        await b.synchro.synchroniser();
        serveur.tables['produits']![id]!
          ..['nom'] = 'Riz en retard'
          ..['maj_le'] = '2026-10-10T11:30:00.000Z'
          ..['serveur_maj_le'] = serveur.heure
              .subtract(const Duration(seconds: 30))
              .toIso8601String();
        await b.synchro.synchroniser();
        expect((await b.produit(id)).nom, 'Riz en retard');
      },
    );

    test('envoi refusé : le téléchargement se fait quand même', () async {
      final id = await riz(a);
      await a.synchro.synchroniser();
      serveur.ecrireDepuisAutreTelephone('produits', id, {
        'nom': 'Riz distant',
        'maj_le': '2026-10-10T11:00:00.000Z',
      });
      await a.clients.creerClient(nom: 'Refusé');
      serveur.tableEnEchec = 'clients';
      final bilan = await a.synchro.synchroniser();
      expect(bilan.reussi, isFalse);
      expect((await a.produit(id)).nom, 'Riz distant');
    });

    test('téléchargement coupé en route : dette déjà recalculée', () async {
      final id = await riz(a, stock: 10);
      await a.vendreACredit(id, Donnees.clientId, 4);
      await a.synchro.synchroniser();
      final b = Telephone(
        _CoupeApres(serveur, 'mouvements_stock'),
        appareil: 'tel-b',
      );
      addTearDown(b.db.close);
      final bilan = await b.synchro.synchroniser();
      expect(bilan.reussi, isFalse);
      // Ventes reçues avant la coupure : la dette du client est juste.
      expect((await b.client(Donnees.clientId)).soldeDette, 14000);
    });

    test(
      'données provisoires (avant l\'inscription) : jamais envoyées',
      () async {
        await a.db
            .into(a.db.boutiques)
            .insert(
              BoutiquesCompanion.insert(
                id: uuid(900),
                nom: 'Kassa',
                telephone: SynchroService.telephoneProvisoire,
                ville: '',
                quartier: '',
                typeCommerce: '',
                seuilAlerteDefaut: 5,
                creeLe: a.heure,
                majLe: a.heure,
                appareilId: 'tel-a',
              ),
            );
        final bilan = await a.synchro.synchroniser();
        expect(bilan.reussi, isTrue);
        expect(serveur.tables['boutiques']!.containsKey(uuid(900)), isFalse);
      },
    );
  });

  test('deux passages en même temps : un seul envoi', () async {
    await riz(a);
    await Future.wait([a.synchro.synchroniser(), a.synchro.synchroniser()]);
    expect(serveur.envois, greaterThan(0));
    final envois = serveur.envois;
    await a.synchro.synchroniser();
    expect(serveur.envois, envois); // plus rien à envoyer
  });
}

/// Serveur qui exécute [pendant] au milieu de l'envoi des produits.
class _ServeurQuiModifie extends FauxServeur {
  _ServeurQuiModifie(this._vrai, this._pendant);

  final FauxServeur _vrai;
  final Future<void> Function() _pendant;
  var _fait = false;

  @override
  Future<void> envoyer(String table, List<Map<String, Object?>> lignes) async {
    if (table == 'produits' && !_fait) {
      _fait = true;
      await _pendant();
    }
    await _vrai.envoyer(table, lignes);
  }

  @override
  Future<List<Map<String, Object?>>> telecharger(
    String table, {
    apres,
    required int limite,
  }) async => const [];
}

/// Serveur dont le téléchargement de [table] échoue toujours.
class _CoupeApres extends FauxServeur {
  _CoupeApres(this._vrai, this._table);

  final FauxServeur _vrai;
  final String _table;

  @override
  Future<void> envoyer(String table, List<Map<String, Object?>> lignes) =>
      _vrai.envoyer(table, lignes);

  @override
  Future<List<Map<String, Object?>>> telecharger(
    String table, {
    apres,
    required int limite,
  }) {
    if (table == _table) throw const FormatException('réseau coupé');
    return _vrai.telecharger(table, apres: apres, limite: limite);
  }
}
