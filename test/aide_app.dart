import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/app.dart';
import 'package:kassa/data/auth/service_auth.dart';
import 'package:kassa/data/db/champs_synchro.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/preferences/preferences_locales.dart';
import 'package:kassa/data/providers.dart';
import 'package:kassa/data/repositories/boutique_repository.dart';
import 'package:kassa/data/repositories/clients_repository.dart';
import 'package:kassa/data/repositories/compte_repository.dart';
import 'package:kassa/data/repositories/produits_repository.dart';
import 'package:kassa/data/repositories/ventes_repository.dart';
import 'package:kassa/data/synchro/serveur_synchro.dart';
import 'package:kassa/domain/panier.dart';
import 'package:kassa/domain/produit_saisie.dart';
import 'package:kassa/ui/state/clients.dart';
import 'package:kassa/ui/state/langue.dart';
import 'package:kassa/ui/state/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/aide_base.dart';

/// L'app Kassa complète sur une base en mémoire.
class AppDeTest {
  AppDeTest._(this.db, this.widget, this.liens);

  final KassaDatabase db;
  final Widget widget;

  /// Liens que l'app a voulu ouvrir (WhatsApp), au lieu de quitter l'app.
  final List<Uri> liens;

  ClientsRepository get clients =>
      ClientsRepository(db, ChampsSynchro(appareilId: 'tel-test'));

  VentesRepository get ventes =>
      VentesRepository(db, ChampsSynchro(appareilId: 'tel-test'));

  ProduitsRepository get produits =>
      ProduitsRepository(db, ChampsSynchro(appareilId: 'tel-test'));

  /// Compte du téléphone de test (numéro et code PIN).
  static const telephone = '237690000000';
  static const codePin = '1234';
  static const utilisateurId = '00000000-0000-4000-9000-000000000001';

  /// [compte] : le téléphone a déjà sa boutique et l'app s'ouvre sans code
  /// PIN (parcours des écrans 5 à 14). Sinon : premier lancement.
  /// [auth] et [serveur] : connexion et sauvegarde simulées (null : pas de
  /// serveur, comme une version sans réglages).
  static Future<AppDeTest> creer({
    String langue = 'fr',
    bool compte = true,
    bool pinAuDemarrage = false,
    ServiceAuth? auth,
    ServeurSynchro? serveur,
    Stream<bool>? reseau,
  }) async {
    SharedPreferences.setMockInitialValues({'langue': langue});
    final prefs = await PreferencesLocales.ouvrir();
    final db = baseEnMemoire();
    if (compte) {
      await CompteRepository(
        db,
        ChampsSynchro(appareilId: 'tel-test'),
      ).creerBoutique(
        utilisateurId: utilisateurId,
        telephone: telephone,
        saisie: const BoutiqueSaisie(
          nom: 'Chez Awa',
          typeCommerce: 'alimentation',
          ville: 'Douala',
          quartier: 'Akwa',
        ),
        pin: codePin,
      );
    }
    final liens = <Uri>[];
    return AppDeTest._(
      db,
      ProviderScope(
        overrides: [
          ouvrirLienProvider.overrideWithValue((uri) async {
            liens.add(uri);
            return true;
          }),
          preferencesLocalesProvider.overrideWithValue(prefs),
          appareilIdProvider.overrideWithValue('tel-test'),
          kassaDatabaseProvider.overrideWithValue(db),
          pinAuDemarrageProvider.overrideWithValue(pinAuDemarrage),
          serviceAuthProvider.overrideWithValue(auth),
          serveurSynchroProvider.overrideWithValue(serveur),
          reseauProvider.overrideWithValue(reseau ?? const Stream.empty()),
        ],
        child: const KassaApp(),
      ),
      liens,
    );
  }

  /// Ajoute un client directement en base.
  Future<String> ajouterClient(
    WidgetTester tester, {
    required String nom,
    String? telephone,
  }) async {
    final id = await tester.runAsync(
      () => clients.creerClient(nom: nom, telephone: telephone),
    );
    await stabiliser(tester);
    return id!;
  }

  /// Vend [quantite] × [produitId] au montant exact, payé en [mode].
  /// Une vente par appel : la base et l'écran se mettent à jour entre deux
  /// ventes (plusieurs écritures dans un seul runAsync peuvent bloquer).
  Future<void> vendreComptant(
    WidgetTester tester, {
    required String produitId,
    double quantite = 1,
    ModeChoisi mode = ModeChoisi.especes,
  }) async {
    await tester.runAsync(() async {
      final panier = await _panier(produitId, quantite);
      await ventes.enregistrerVente(
        panier: panier,
        mode: mode,
        paiement: CalculPaiement.pour(mode: mode, total: panier.total),
        utilisateurId: (await _utilisateur()).id,
      );
    });
    await stabiliser(tester);
  }

  Future<Panier> _panier(String produitId, double quantite) async {
    final p = await (db.select(
      db.produits,
    )..where((x) => x.id.equals(produitId))).getSingle();
    return const Panier().ajouter(
      LignePanier(
        produitId: p.id,
        nom: p.nom,
        unite: p.unite,
        prixUnitaire: p.prixVente,
        prixAchatUnitaire: p.prixAchat,
        quantite: quantite,
        stockDisponible: p.quantite,
      ),
    );
  }

  Future<Utilisateur> _utilisateur() => BoutiqueRepository(
    db,
    ChampsSynchro(appareilId: 'tel-test'),
  ).utilisateurCourant();

  /// Vend [quantite] × [produitId] à crédit à [clientId], avec [avance].
  Future<void> vendreACredit(
    WidgetTester tester, {
    required String clientId,
    required String produitId,
    double quantite = 1,
    int avance = 0,
  }) async {
    await tester.runAsync(() async {
      final panier = await _panier(produitId, quantite);
      final utilisateur = await _utilisateur();
      await ventes.enregistrerVente(
        panier: panier,
        mode: ModeChoisi.credit,
        paiement: CalculPaiement.pour(
          mode: ModeChoisi.credit,
          total: panier.total,
          saisi: avance,
        ),
        utilisateurId: utilisateur.id,
        clientId: clientId,
      );
    });
    await stabiliser(tester);
  }

  /// Ajoute un produit directement en base.
  Future<String> ajouterProduit(
    WidgetTester tester, {
    required String nom,
    double quantite = 10,
    double seuil = 3,
    int prixAchat = 3000,
    int prixVente = 3500,
    String unite = 'sacs',
    String? categorieId,
  }) async {
    final id = await tester.runAsync(
      () => produits.creerProduit(
        ProduitSaisie(
          nom: nom,
          categorieId: categorieId,
          prixAchat: prixAchat,
          prixVente: prixVente,
          quantite: quantite,
          unite: unite,
          seuilAlerte: seuil,
        ),
      ),
    );
    await stabiliser(tester);
    return id!;
  }

  /// Ferme la base à la fin du test.
  Future<void> fermer(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(db.close);
  }
}

/// Laisse la base (vraie attente) et les animations (temps simulé) avancer.
/// Remplace pumpAndSettle, qui ne voit pas les requêtes drift et ne se
/// termine jamais avec un curseur qui clignote ou un indicateur de chargement.
Future<void> stabiliser(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Va sur l'onglet Stock.
Future<void> ouvrirStock(WidgetTester tester) async {
  await tester.tap(find.text('Stock').last);
  await stabiliser(tester);
}

/// Va sur l'onglet Clients.
Future<void> ouvrirClients(
  WidgetTester tester, {
  String libelle = 'Clients',
}) async {
  await tester.tap(find.text(libelle).last);
  await stabiliser(tester);
}
