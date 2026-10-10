import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/db/champs_synchro.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/inscription.dart';
import 'package:kassa/data/repositories/boutique_repository.dart';
import 'package:kassa/data/repositories/clients_repository.dart';
import 'package:kassa/data/repositories/compte_repository.dart';
import 'package:kassa/data/repositories/produits_repository.dart';
import 'package:kassa/data/repositories/ventes_repository.dart';
import 'package:kassa/data/synchro/synchro_service.dart';
import 'package:kassa/domain/code_pin.dart';
import 'package:kassa/domain/panier.dart';
import 'package:kassa/domain/produit_saisie.dart';

import 'aide_base.dart';
import 'faux_auth.dart';
import 'synchro/faux_serveur.dart';

const _numero = '237677123456';
const _saisie = BoutiqueSaisie(
  nom: ' Chez Awa ',
  typeCommerce: 'alimentation',
  ville: 'Douala',
  quartier: 'Akwa',
);

/// Un téléphone avec sa base et ses dépôts.
class _Tel {
  _Tel(this.serveur, this.auth, {String appareil = 'tel-a'})
    : db = baseEnMemoire() {
    final champs = ChampsSynchro(appareilId: appareil, horloge: () => heure);
    comptes = CompteRepository(db, champs);
    produits = ProduitsRepository(db, champs);
    ventes = VentesRepository(db, champs);
    clients = ClientsRepository(db, champs);
    boutique = BoutiqueRepository(db, champs);
    inscription = Inscription(
      auth: auth,
      serveur: serveur,
      comptes: comptes,
      synchroPour: synchroPour,
    );
  }

  final FauxServeur serveur;
  final FauxAuth auth;
  final KassaDatabase db;
  final curseurs = FauxCurseurs();
  DateTime heure = DateTime.utc(2026, 10, 10, 9);
  late final CompteRepository comptes;
  late final ProduitsRepository produits;
  late final VentesRepository ventes;
  late final ClientsRepository clients;
  late final BoutiqueRepository boutique;
  late final Inscription inscription;

  SynchroService synchroPour(String boutiqueId) =>
      SynchroService(db, serveur, curseurs, boutiqueId: boutiqueId);

  /// Vente comptant d'un riz, faite avant l'inscription.
  Future<void> vendreRiz() async {
    final id = await produits.creerProduit(
      const ProduitSaisie(
        nom: 'Riz',
        prixAchat: 3000,
        prixVente: 3500,
        quantite: 10,
        unite: 'sacs',
        seuilAlerte: 2,
      ),
    );
    final panier = const Panier().ajouter(
      LignePanier(
        produitId: id,
        nom: 'Riz',
        unite: 'sacs',
        prixUnitaire: 3500,
        prixAchatUnitaire: 3000,
        quantite: 1,
        stockDisponible: 10,
      ),
    );
    await ventes.enregistrerVente(
      panier: panier,
      mode: ModeChoisi.especes,
      paiement: CalculPaiement.pour(
        mode: ModeChoisi.especes,
        total: panier.total,
      ),
      utilisateurId: (await boutique.utilisateurCourant()).id,
    );
  }
}

void main() {
  late FauxServeur serveur;
  late FauxAuth auth;
  late _Tel a;

  setUp(() {
    serveur = FauxServeur();
    auth = FauxAuth();
    a = _Tel(serveur, auth);
  });
  tearDown(() => a.db.close());

  test('nouveau numéro : créer la boutique', () async {
    final uid = await auth.verifierCode(_numero, '123456');
    expect(
      await a.inscription.apresConnexion(uid),
      SuiteConnexion.creerBoutique,
    );

    final compte = await a.inscription.creerBoutique(_saisie, '2580');
    expect(compte.id, uid);
    expect(compte.telephone, _numero);
    expect(CodePin.verifier('2580', compte.codePin), isTrue);
    final b = await a.db.select(a.db.boutiques).getSingle();
    expect(b.nom, 'Chez Awa');
    expect(b.telephone, _numero);
    expect(b.synchro, isFalse);
    expect(await a.comptes.verifierPin('2580'), isTrue);
    expect(await a.comptes.verifierPin('0000'), isFalse);
  });

  test(
    'données saisies avant l\'inscription : reprises dans la boutique',
    () async {
      await a.vendreRiz();
      final provisoire = await a.db.select(a.db.boutiques).getSingle();
      final uid = await auth.verifierCode(_numero, '123456');
      await a.inscription.apresConnexion(uid);
      await a.inscription.creerBoutique(_saisie, '2580');

      final boutiques = await a.db.select(a.db.boutiques).get();
      expect(boutiques.single.id, provisoire.id);
      expect(boutiques.single.telephone, _numero);
      final utilisateurs = await a.db.select(a.db.utilisateurs).get();
      expect(utilisateurs.single.id, uid);
      expect((await a.db.select(a.db.ventes).getSingle()).utilisateurId, uid);

      // Tout part au serveur, rattaché à la boutique.
      final bilan = await a.synchroPour(provisoire.id).synchroniser();
      expect(bilan.reussi, isTrue, reason: '${bilan.erreur}');
      expect(
        serveur.tables['boutiques']![provisoire.id]!['telephone'],
        _numero,
      );
      expect(serveur.tables['ventes']!.values.single['utilisateur_id'], uid);
    },
  );

  test('nouveau téléphone : restauration, puis le même code PIN', () async {
    final uid = await auth.verifierCode(_numero, '123456');
    await a.inscription.apresConnexion(uid);
    final compte = await a.inscription.creerBoutique(_saisie, '2580');
    await a.vendreRiz();
    await a.synchroPour(compte.boutiqueId).synchroniser();

    final b = _Tel(serveur, auth, appareil: 'tel-b');
    addTearDown(b.db.close);
    // Une vente faite sur le nouveau téléphone avant de se connecter.
    await b.vendreRiz();
    expect(await b.inscription.apresConnexion(uid), SuiteConnexion.codePin);
    expect(await b.comptes.verifierPin('2580'), isTrue);
    final boutiques = await b.db.select(b.db.boutiques).get();
    expect(boutiques.single.id, compte.boutiqueId);
    final ventes = await b.db.select(b.db.ventes).get();
    expect(ventes, hasLength(2));
    expect(ventes.every((v) => v.utilisateurId == uid), isTrue);

    // La vente du nouveau téléphone part dans la boutique restaurée.
    await b.synchroPour(compte.boutiqueId).synchroniser();
    expect(serveur.tables['ventes'], hasLength(2));
    expect(
      serveur.tables['ventes']!.values.map((v) => v['boutique_id']).toSet(),
      {compte.boutiqueId},
    );
  });

  test('restauration sans réseau : erreur, rien de cassé', () async {
    final uid = await auth.verifierCode(_numero, '123456');
    await a.inscription.apresConnexion(uid);
    final compte = await a.inscription.creerBoutique(_saisie, '2580');
    await a.synchroPour(compte.boutiqueId).synchroniser();

    final b = _Tel(serveur, auth, appareil: 'tel-b');
    addTearDown(b.db.close);
    serveur.horsLigne = true;
    await expectLater(b.inscription.apresConnexion(uid), throwsA(anything));
    expect(await b.comptes.compteLocal(), isNull);
    serveur.horsLigne = false;
    expect(await b.inscription.apresConnexion(uid), SuiteConnexion.codePin);
  });

  test('même téléphone, même numéro : directement le code PIN', () async {
    final uid = await auth.verifierCode(_numero, '123456');
    await a.inscription.apresConnexion(uid);
    await a.inscription.creerBoutique(_saisie, '2580');
    expect(await a.inscription.apresConnexion(uid), SuiteConnexion.codePin);
  });

  test('autre numéro sur un téléphone qui a déjà un compte : refusé', () async {
    final uid = await auth.verifierCode(_numero, '123456');
    await a.inscription.apresConnexion(uid);
    await a.inscription.creerBoutique(_saisie, '2580');
    final autre = await auth.verifierCode('237699000000', '123456');
    await expectLater(
      a.inscription.apresConnexion(autre),
      throwsA(isA<AutreCompteSurCeTelephone>()),
    );
    expect(auth.utilisateurId, isNull);
  });

  test('changer le code PIN', () async {
    final uid = await auth.verifierCode(_numero, '123456');
    await a.inscription.apresConnexion(uid);
    await a.inscription.creerBoutique(_saisie, '2580');
    await a.comptes.changerPin(uid, '1397');
    expect(await a.comptes.verifierPin('1397'), isTrue);
    expect(await a.comptes.verifierPin('2580'), isFalse);
  });
}
