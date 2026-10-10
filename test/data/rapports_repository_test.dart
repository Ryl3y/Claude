import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/db/champs_synchro.dart';
import 'package:kassa/data/db/kassa_database.dart';
import 'package:kassa/data/db/tables.dart';
import 'package:kassa/data/repositories/boutique_repository.dart';
import 'package:kassa/data/repositories/clients_repository.dart';
import 'package:kassa/data/repositories/produits_repository.dart';
import 'package:kassa/data/repositories/rapports_repository.dart';
import 'package:kassa/data/repositories/ventes_repository.dart';
import 'package:kassa/domain/panier.dart';
import 'package:kassa/domain/periode.dart';
import 'package:kassa/domain/produit_saisie.dart';

import 'aide_base.dart';

void main() {
  late KassaDatabase db;
  late DateTime heure;
  late ProduitsRepository produits;
  late VentesRepository ventes;
  late ClientsRepository clients;
  late RapportsRepository rapports;
  late String utilisateurId;
  late String riz;
  late String sucre;

  setUp(() async {
    db = baseEnMemoire();
    // Samedi 10 octobre 2026, 10 h à Douala.
    heure = DateTime.utc(2026, 10, 10, 9);
    final champs = ChampsSynchro(appareilId: 'tel-1', horloge: () => heure);
    produits = ProduitsRepository(db, champs);
    ventes = VentesRepository(db, champs);
    clients = ClientsRepository(db, champs);
    rapports = RapportsRepository(db);
    utilisateurId = (await BoutiqueRepository(
      db,
      champs,
    ).utilisateurCourant()).id;
    riz = await produits.creerProduit(
      const ProduitSaisie(
        nom: 'Riz',
        prixAchat: 3000,
        prixVente: 3500,
        quantite: 50,
        unite: 'sacs',
        seuilAlerte: 2,
      ),
    );
    sucre = await produits.creerProduit(
      const ProduitSaisie(
        nom: 'Sucre',
        prixAchat: 700,
        prixVente: 900,
        quantite: 20,
        unite: 'kg',
        seuilAlerte: 2,
      ),
    );
  });
  tearDown(() => db.close());

  LignePanier ligne(String id, String nom, int prix, int achat, double q) =>
      LignePanier(
        produitId: id,
        nom: nom,
        unite: '',
        prixUnitaire: prix,
        prixAchatUnitaire: achat,
        quantite: q,
        stockDisponible: 100,
      );

  Future<Vente> vendre(
    Panier panier, {
    ModeChoisi mode = ModeChoisi.especes,
    int? saisi,
    String? clientId,
  }) => ventes.enregistrerVente(
    panier: panier,
    mode: mode,
    paiement: CalculPaiement.pour(
      mode: mode,
      total: panier.total,
      saisi: saisi,
    ),
    utilisateurId: utilisateurId,
    clientId: clientId,
  );

  test('jour : totaux, bénéfice, argent reçu, modes, annulées', () async {
    final awa = await clients.creerClient(nom: 'Awa');
    // 2 riz en espèces : 7 000, bénéfice 1 000.
    await vendre(const Panier().ajouter(ligne(riz, 'Riz', 3500, 3000, 2)));
    // 1,5 kg de sucre en MoMo : 1 350, bénéfice 300.
    await vendre(
      const Panier().ajouter(ligne(sucre, 'Sucre', 900, 700, 1.5)),
      mode: ModeChoisi.momo,
    );
    // 1 riz à crédit, avance 500 : reste 3 000.
    await vendre(
      const Panier().ajouter(ligne(riz, 'Riz', 3500, 3000, 1)),
      mode: ModeChoisi.credit,
      saisi: 500,
      clientId: awa,
    );
    // Une vente annulée : ne compte pas.
    final annulee = await vendre(
      const Panier().ajouter(ligne(riz, 'Riz', 3500, 3000, 4)),
    );
    await ventes.annulerVente(annulee.id);
    // Versement de 1 000 sur la dette.
    await clients.enregistrerVersement(
      clientId: awa,
      montant: 1000,
      mode: ModeChoisi.especes,
    );

    final r = await rapports.calculer(
      Periode.contenant(TypePeriode.jour, heure),
    );
    expect(r.nombreVentes, 3);
    expect(r.total, 7000 + 1350 + 3500);
    expect(r.benefice, 1000 + 300 + 500);
    expect(r.payeSurVentes, 7000 + 1350 + 500);
    expect(r.venduACredit, 3000);
    expect(r.versements, 1000);
    expect(r.totalEncaisse, 7000 + 1350 + 500 + 1000);
    expect(r.parMode, {
      ModePaiement.especes: 7000,
      ModePaiement.momo: 1350,
      ModePaiement.credit: 3500,
    });
    expect(r.annulees, 1);
    expect(r.panierMoyen, ((7000 + 1350 + 3500) / 3).round());

    // Meilleurs produits : Riz (3 sacs, 10 500) puis Sucre (1,5 kg).
    expect(r.top.map((p) => p.nom), ['Riz', 'Sucre']);
    expect(r.top[0].quantite, 3);
    expect(r.top[0].montant, 10500);
    expect(r.top[0].benefice, 1500);
    expect(r.top[0].unite, 'sacs');
    expect(r.top[1].quantite, 1.5);
    expect(r.top[1].montant, 1350);
  });

  test('limites : la veille et le lendemain ne comptent pas', () async {
    // Vendredi 9, 23 h 59 à Douala.
    heure = DateTime.utc(2026, 10, 9, 22, 59);
    await vendre(const Panier().ajouter(ligne(riz, 'Riz', 3500, 3000, 1)));
    // Samedi 10, 0 h 00 à Douala.
    heure = DateTime.utc(2026, 10, 9, 23);
    await vendre(const Panier().ajouter(ligne(riz, 'Riz', 3500, 3000, 2)));
    // Dimanche 11, 0 h 00.
    heure = DateTime.utc(2026, 10, 10, 23);
    await vendre(const Panier().ajouter(ligne(riz, 'Riz', 3500, 3000, 4)));

    final samedi = Periode.contenant(
      TypePeriode.jour,
      DateTime.utc(2026, 10, 10, 9),
    );
    expect((await rapports.calculer(samedi)).total, 7000);
    expect((await rapports.calculer(samedi.precedente)).total, 3500);
    expect((await rapports.calculer(samedi.suivante)).total, 14000);
    final semaine = Periode.contenant(
      TypePeriode.semaine,
      DateTime.utc(2026, 10, 10, 9),
    );
    expect((await rapports.calculer(semaine)).total, 3500 + 7000 + 14000);
  });

  test(
    'top : 5 produits au plus, nom copié si le produit est supprimé',
    () async {
      final ids = <String>[];
      for (var i = 1; i <= 6; i++) {
        ids.add(
          await produits.creerProduit(
            ProduitSaisie(
              nom: 'Produit $i',
              prixAchat: 100,
              prixVente: 100 * i + 100,
              quantite: 10,
              unite: 'pièces',
              seuilAlerte: 1,
            ),
          ),
        );
      }
      for (var i = 0; i < 6; i++) {
        await vendre(
          const Panier().ajouter(
            ligne(ids[i], 'Produit ${i + 1}', 100 * (i + 1) + 100, 100, 1),
          ),
        );
      }
      await produits.supprimerProduit(ids[5]);
      final r = await rapports.calculer(
        Periode.contenant(TypePeriode.jour, heure),
      );
      expect(r.top, hasLength(RapportsRepository.tailleTop));
      expect(r.top.first.nom, 'Produit 6');
      expect(r.top.last.nom, 'Produit 2');
    },
  );

  test('aucune vente : tout à zéro', () async {
    final r = await rapports.calculer(
      Periode.contenant(TypePeriode.mois, heure),
    );
    expect(r.nombreVentes, 0);
    expect(r.total, 0);
    expect(r.panierMoyen, 0);
    expect(r.top, isEmpty);
    expect(r.parMode, isEmpty);
  });

  test('le rapport se met à jour après une vente', () async {
    final flux = rapports.surveillerRapport(
      Periode.contenant(TypePeriode.jour, heure),
    );
    final attendu = expectLater(flux.map((r) => r.total), emitsThrough(3500));
    await vendre(const Panier().ajouter(ligne(riz, 'Riz', 3500, 3000, 1)));
    await attendu;
  });
}
