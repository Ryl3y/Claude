// Parcours de l'étape 8 : bienvenue, connexion par SMS, création de la
// boutique, restauration sur un nouveau téléphone, code PIN (essais,
// attente, code oublié) et état de la sauvegarde. Serveur et SMS simulés.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/auth/service_auth.dart';
import 'package:kassa/data/db/champs_synchro.dart';
import 'package:kassa/data/repositories/compte_repository.dart';
import 'package:kassa/data/repositories/produits_repository.dart';
import 'package:kassa/data/synchro/synchro_service.dart';
import 'package:kassa/domain/code_pin.dart';
import 'package:kassa/domain/produit_saisie.dart';
import 'package:kassa/ui/widgets/widgets.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';
import '../../data/aide_base.dart';
import '../../data/faux_auth.dart';
import '../../data/faux_lieux.dart';
import '../../data/synchro/faux_serveur.dart';
import '../aide_lieu.dart';

Future<AppDeTest> _demarrer(
  WidgetTester tester, {
  bool compte = false,
  bool pinAuDemarrage = true,
  FauxAuth? auth,
  FauxServeur? serveur,
  bool sansServeur = false,
  FauxLieux? lieux,
}) async {
  tester.view.physicalSize = const Size(412 * 3, 915 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final app = await AppDeTest.creer(
    compte: compte,
    pinAuDemarrage: pinAuDemarrage,
    auth: sansServeur ? null : auth ?? FauxAuth(),
    serveur: sansServeur ? null : serveur ?? FauxServeur(),
    lieux: lieux,
  );
  await tester.pumpWidget(app.widget);
  await stabiliser(tester);
  return app;
}

Future<void> _toucher(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await stabiliser(tester);
}

Future<void> _taperPin(WidgetTester tester, String pin) async {
  for (final c in pin.split('')) {
    await tester.tap(
      find.descendant(of: find.byType(NumPad), matching: find.text(c)),
    );
    await tester.pump();
  }
  // Vérification du code (PBKDF2) : un vrai calcul, hors du temps simulé.
  await stabiliser(tester);
  await stabiliser(tester);
}

Future<void> _saisirNumeroEtCode(
  WidgetTester tester,
  String numero, {
  String code = '123456',
}) async {
  await tester.enterText(find.byType(TextField), numero);
  await _toucher(tester, find.text('Recevoir le code'));
  await tester.enterText(find.byType(TextField), code);
  await stabiliser(tester);
  await stabiliser(tester);
}

void main() {
  setUpAll(preparerTestsWidgets);

  testWidgets('premier lancement : inscription complète', (tester) async {
    final auth = FauxAuth();
    final lieux = FauxLieux();
    final app = await _demarrer(tester, auth: auth, lieux: lieux);
    expect(find.text('Votre caisse, même sans internet'), findsOneWidget);

    await _toucher(tester, find.text('Commencer'));
    expect(find.text('Votre numéro'), findsOneWidget);

    // Numéro invalide : message qui dit quoi faire.
    await tester.enterText(find.byType(TextField), '677 12');
    await _toucher(tester, find.text('Recevoir le code'));
    expect(
      find.text(
        'Numéro invalide. Saisissez les 9 chiffres, par exemple '
        '6 77 12 34 56.',
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), '6 77 12 34 56');
    await _toucher(tester, find.text('Recevoir le code'));
    expect(auth.codesEnvoyes, ['237677123456']);
    expect(find.text('Code reçu par SMS'), findsOneWidget);
    expect(find.text('Renvoyer le code dans 60 s'), findsOneWidget);

    // Code faux.
    await tester.enterText(find.byType(TextField), '000000');
    await stabiliser(tester);
    expect(
      find.text(
        'Code incorrect ou trop ancien. Vérifiez le SMS ou demandez un '
        'nouveau code.',
      ),
      findsOneWidget,
    );

    // Bon code : nouveau compte, création de la boutique.
    await tester.enterText(find.byType(TextField), '123456');
    await stabiliser(tester);
    await stabiliser(tester);
    expect(find.text('Votre boutique'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Nom de la boutique'),
      'Chez Maman Brigitte',
    );
    // Lieu : listes officielles, puis village proposé, quartier nouveau.
    await choisirArrondissement(tester, 'Ouest', 'Menoua', 'Dschang');
    await saisirLieu(tester, 'Ville ou village', 'dsch', choix: 'Dschang');
    expect(find.text('Haoussa'), findsNothing);
    await saisirLieu(tester, 'Quartier', 'haou', choix: 'Haoussa');
    await saisirLieu(
      tester,
      'Quartier',
      'Foto  Marché',
      choix: 'Ajouter « Foto Marché »',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Code PIN à 4 chiffres'),
      '2580',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirmez le code PIN'),
      '2581',
    );
    await _toucher(tester, find.text('Créer ma boutique'));
    expect(
      find.text('Les deux codes ne sont pas pareils. Saisissez-les à nouveau.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Code PIN à 4 chiffres'),
      '2580',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirmez le code PIN'),
      '2580',
    );
    await _toucher(tester, find.text('Créer ma boutique'));
    await stabiliser(tester);
    expect(find.text('Ventes du jour'), findsOneWidget);

    final boutique = await tester.runAsync(
      () => app.db.select(app.db.boutiques).getSingle(),
    );
    expect(boutique!.nom, 'Chez Maman Brigitte');
    expect(boutique.telephone, '237677123456');
    expect(boutique.arrondissement, 'CM008005001');
    expect(boutique.ville, 'Dschang');
    expect(boutique.quartier, 'Foto Marché');
    expect(boutique.localiteId, lieux.lieuNomme('Dschang')!.id);
    expect(boutique.quartierId, lieux.lieuNomme('Foto Marché')!.id);
    // Le quartier nouveau est dans la liste partagée, pour les suivants.
    expect(lieux.ajouts, [(boutique.localiteId!, 'Foto Marché')]);
    final compte = await tester.runAsync(
      () => app.db.select(app.db.utilisateurs).getSingle(),
    );
    expect(compte!.id, auth.idPour('237677123456'));
    expect(CodePin.verifier('2580', compte.codePin), isTrue);
    await app.fermer(tester);
  });

  testWidgets('nouveau téléphone : tout revient, puis le code PIN', (
    tester,
  ) async {
    const numero = '237677123456';
    final auth = FauxAuth();
    final serveur = FauxServeur();
    // L'ancien téléphone : boutique, un produit, sauvegardés.
    await tester.runAsync(() async {
      final ancien = baseEnMemoire();
      final champs = ChampsSynchro(appareilId: 'ancien');
      final boutiqueId = await CompteRepository(ancien, champs).creerBoutique(
        utilisateurId: auth.idPour(numero),
        telephone: numero,
        saisie: const BoutiqueSaisie(
          nom: 'Chez Awa',
          typeCommerce: 'alimentation',
          ville: 'Douala',
          quartier: 'Akwa',
        ),
        pin: '2580',
      );
      await ProduitsRepository(ancien, champs).creerProduit(
        const ProduitSaisie(
          nom: 'Riz parfumé',
          prixAchat: 3000,
          prixVente: 3500,
          quantite: 12,
          unite: 'sacs',
          seuilAlerte: 2,
        ),
      );
      await SynchroService(
        ancien,
        serveur,
        FauxCurseurs(),
        boutiqueId: boutiqueId,
      ).synchroniser();
      await ancien.close();
    });

    final app = await _demarrer(tester, auth: auth, serveur: serveur);
    await _toucher(tester, find.text('Commencer'));
    await _saisirNumeroEtCode(tester, '677123456');
    expect(find.text('Entrez votre code PIN'), findsOneWidget);

    await _taperPin(tester, '2580');
    expect(find.text('Ventes du jour'), findsOneWidget);
    await ouvrirStock(tester);
    expect(find.text('Riz parfumé'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('code PIN : erreurs comptées, puis attente', (tester) async {
    final app = await _demarrer(tester, compte: true);
    expect(find.text('Entrez votre code PIN'), findsOneWidget);
    await _taperPin(tester, '0000');
    expect(find.text('Code incorrect. Il reste 4 essais.'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await _taperPin(tester, '0000');
    }
    expect(find.text('Trop d\'essais. Réessayez dans 30 s.'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('code PIN juste : l\'app s\'ouvre', (tester) async {
    final app = await _demarrer(tester, compte: true);
    await _taperPin(tester, AppDeTest.codePin);
    expect(find.text('Ventes du jour'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('code oublié : SMS, puis nouveau code PIN', (tester) async {
    final auth = FauxAuth()
      ..comptes[AppDeTest.telephone] = AppDeTest.utilisateurId;
    final app = await _demarrer(tester, compte: true, auth: auth);
    await _toucher(tester, find.text('Code oublié'));
    expect(
      find.text(
        'Nous vous envoyons un code par SMS, puis vous choisissez un '
        'nouveau code PIN.',
      ),
      findsOneWidget,
    );
    await _saisirNumeroEtCode(tester, '690000000');
    expect(find.text('Choisissez un nouveau code PIN'), findsOneWidget);
    await _taperPin(tester, '1397');
    expect(find.text('Saisissez-le encore une fois'), findsOneWidget);
    await _taperPin(tester, '1398');
    expect(
      find.text('Les deux codes ne sont pas pareils. Saisissez-les à nouveau.'),
      findsOneWidget,
    );
    await _taperPin(tester, '1397');
    await _taperPin(tester, '1397');
    expect(find.text('Ventes du jour'), findsOneWidget);
    final compte = await tester.runAsync(
      () => app.db.select(app.db.utilisateurs).getSingle(),
    );
    expect(CodePin.verifier('1397', compte!.codePin), isTrue);
    await app.fermer(tester);
  });

  testWidgets('code oublié avec un autre numéro : refusé avant le SMS', (
    tester,
  ) async {
    final auth = FauxAuth();
    final app = await _demarrer(tester, compte: true, auth: auth);
    await _toucher(tester, find.text('Code oublié'));
    await tester.enterText(find.byType(TextField), '699999999');
    await _toucher(tester, find.text('Recevoir le code'));
    expect(
      find.text('Ce numéro n\'est pas celui du compte de ce téléphone.'),
      findsOneWidget,
    );
    expect(auth.codesEnvoyes, isEmpty);
    await app.fermer(tester);
  });

  testWidgets('erreurs de connexion : messages qui disent quoi faire', (
    tester,
  ) async {
    final auth = FauxAuth();
    final app = await _demarrer(tester, auth: auth);
    await _toucher(tester, find.text('Commencer'));
    auth.prochaineErreur = ErreurConnexion.reseau;
    await tester.enterText(find.byType(TextField), '677123456');
    await _toucher(tester, find.text('Recevoir le code'));
    expect(
      find.text(
        'Pas de connexion internet. Vérifiez vos données mobiles, puis '
        'réessayez.',
      ),
      findsOneWidget,
    );
    auth.prochaineErreur = ErreurConnexion.tropDeDemandes;
    await _toucher(tester, find.text('Recevoir le code'));
    expect(
      find.text('Trop de demandes. Attendez une minute avant de réessayer.'),
      findsOneWidget,
    );
    await app.fermer(tester);
  });

  testWidgets('version sans serveur : on le dit, rien ne casse', (
    tester,
  ) async {
    final app = await _demarrer(tester, sansServeur: true);
    expect(
      find.text('Cette version de l\'app n\'est pas reliée au serveur Kassa.'),
      findsOneWidget,
    );
    final bouton = tester.widget<KassaButton>(
      find.widgetWithText(KassaButton, 'Commencer'),
    );
    expect(bouton.onPressed, isNull);
    await app.fermer(tester);
  });

  testWidgets('sauvegarde : « Sauvegardé », puis « en attente » hors ligne', (
    tester,
  ) async {
    final serveur = FauxServeur();
    final app = await _demarrer(
      tester,
      compte: true,
      pinAuDemarrage: false,
      serveur: serveur,
    );
    await stabiliser(tester);
    expect(find.text('Sauvegardé'), findsOneWidget);
    expect(serveur.tables['boutiques'], hasLength(1));

    serveur.horsLigne = true;
    await app.ajouterProduit(tester, nom: 'Riz');
    // Le changement part 30 s plus tard… mais il n'y a pas de réseau.
    await tester.pump(const Duration(seconds: 31));
    await stabiliser(tester);
    expect(find.text('Sauvegarde en attente'), findsOneWidget);

    serveur.horsLigne = false;
    await tester.pump(const Duration(minutes: 5));
    await stabiliser(tester);
    expect(find.text('Sauvegardé'), findsOneWidget);
    expect(serveur.tables['produits'], hasLength(1));
    await app.fermer(tester);
  });
}
