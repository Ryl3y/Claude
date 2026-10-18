// Parcours du tableau de bord admin : connexion, chiffres, boutiques et
// geste commercial, paiements, carte, déconnexion.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/admin/donnees/auth_admin.dart';
import 'package:kassa/admin/donnees/serveur_admin.dart';

import '../aide_app.dart' show stabiliser;
import '../aide_widgets.dart';
import 'aide_admin.dart';

Future<void> _toucher(WidgetTester tester, Finder f) async {
  // Les listes ne construisent que ce qui est visible : on fait défiler.
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      400,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await stabiliser(tester);
}

Future<void> _connecter(WidgetTester tester, String email, String mdp) async {
  await tester.enterText(
    find.widgetWithText(TextField, 'Adresse e-mail'),
    email,
  );
  await tester.enterText(find.widgetWithText(TextField, 'Mot de passe'), mdp);
  await _toucher(tester, find.text('Se connecter'));
}

void main() {
  setUpAll(preparerTestsWidgets);

  testWidgets('connexion : vide, mauvais mot de passe, pas admin, puis OK', (
    tester,
  ) async {
    ecranBureau(tester);
    addTearDown(tester.view.reset);
    final auth = FauxAuthAdmin();
    await tester.pumpWidget(
      await adminDeTest(auth: auth, serveur: FauxServeurAdmin()),
    );
    await stabiliser(tester);
    expect(find.text('Espace admin'), findsOneWidget);

    await _toucher(tester, find.text('Se connecter'));
    expect(
      find.text('Saisissez l\'e-mail et le mot de passe.'),
      findsOneWidget,
    );

    await _connecter(tester, FauxAuthAdmin.emailAdmin, 'faux');
    expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);

    await _connecter(
      tester,
      FauxAuthAdmin.emailCommercant,
      FauxAuthAdmin.motDePasse,
    );
    expect(
      find.text('Ce compte n\'a pas accès à l\'espace admin.'),
      findsOneWidget,
    );

    auth.prochaineErreur = ErreurConnexionAdmin.reseau;
    await _connecter(
      tester,
      FauxAuthAdmin.emailAdmin,
      FauxAuthAdmin.motDePasse,
    );
    expect(find.textContaining('Pas de connexion internet'), findsOneWidget);

    await _connecter(
      tester,
      FauxAuthAdmin.emailAdmin,
      FauxAuthAdmin.motDePasse,
    );
    expect(find.text('Bonjour, rich@kassa.cm'), findsOneWidget);
    expect(find.text('Boutiques inscrites'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.textContaining('10'), findsWidgets);
    expect(find.text('2 nouvelles en 7 jours'), findsOneWidget);
    expect(find.text('Inscriptions, 30 derniers jours'), findsOneWidget);
    expect(find.text('Revenus, 6 derniers mois'), findsOneWidget);

    // Déconnexion : retour à l'écran de connexion.
    await _toucher(tester, find.text('Se déconnecter'));
    expect(find.text('Espace admin'), findsOneWidget);
  });

  testWidgets('boutiques : recherche, fiche, offrir des jours', (tester) async {
    ecranBureau(tester);
    addTearDown(tester.view.reset);
    final serveur = FauxServeurAdmin();
    await tester.pumpWidget(
      await adminDeTest(
        auth: FauxAuthAdmin(dejaConnecte: true),
        serveur: serveur,
      ),
    );
    await stabiliser(tester);
    await _toucher(tester, find.text('Boutiques').first);
    expect(find.text('6 sur 6'), findsOneWidget);
    expect(
      find.text('Choisissez une boutique pour voir sa fiche.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'douala');
    await tester.pump(const Duration(milliseconds: 400));
    await stabiliser(tester);
    expect(find.text('2 sur 2'), findsOneWidget);
    expect(find.text('Quincaillerie Ngono'), findsNothing);

    await _toucher(tester, find.text('Beauté Divine'));
    expect(find.textContaining('Terminé le'), findsWidgets);
    expect(find.text('Aucun geste pour cette boutique.'), findsOneWidget);

    await _toucher(tester, find.text('Offrir des jours'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre de jours'),
      '0',
    );
    await _toucher(tester, find.text('Offrir'));
    expect(
      find.text('Saisissez un nombre de jours de 1 à 366.'),
      findsOneWidget,
    );
    expect(find.text('Expliquez le geste en quelques mots.'), findsOneWidget);
    expect(serveur.gestes, isEmpty);

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre de jours'),
      '10',
    );
    await _toucher(tester, find.text('Jours de Pro'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Motif'),
      'Geste après une panne réseau',
    );
    await _toucher(tester, find.text('Offrir'));

    expect(serveur.gestes, [('b3', 10, 'pro', 'Geste après une panne réseau')]);
    expect(
      find.textContaining('Beauté Divine : abonnement jusqu\'au'),
      findsOneWidget,
    );
    expect(find.textContaining('Kassa Pro jusqu\'au'), findsWidgets);
    expect(find.text('Geste après une panne réseau'), findsOneWidget);
  });

  testWidgets('paiements : filtres par statut', (tester) async {
    ecranBureau(tester);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      await adminDeTest(
        auth: FauxAuthAdmin(dejaConnecte: true),
        serveur: FauxServeurAdmin(),
      ),
    );
    await stabiliser(tester);
    await _toucher(tester, find.text('Paiements').first);
    expect(find.text('4 sur 4'), findsOneWidget);
    await _toucher(tester, find.text('Échoués'));
    expect(find.text('1 sur 1'), findsOneWidget);
    expect(find.text('Beauté Divine'), findsOneWidget);
    expect(find.text('Chez Awa'), findsNothing);
    await _toucher(tester, find.text('En attente').first);
    expect(find.text('Quincaillerie Ngono'), findsOneWidget);
  });

  testWidgets('carte : villes placées et ville inconnue à part', (
    tester,
  ) async {
    ecranBureau(tester);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      await adminDeTest(
        auth: FauxAuthAdmin(dejaConnecte: true),
        serveur: FauxServeurAdmin(),
      ),
    );
    await stabiliser(tester);
    await _toucher(tester, find.text('Carte').first);
    expect(find.text('Zones couvertes'), findsOneWidget);
    expect(find.text('Douala'), findsOneWidget);
    expect(find.text('2 boutiques · 1 Pro'), findsOneWidget);
    expect(find.text('Pas sur la carte (ville inconnue)'), findsOneWidget);
    expect(find.text('Mora'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Carte du Cameroun : 4 villes')),
      findsOneWidget,
    );
  });

  testWidgets('serveur injoignable : message et « Réessayer »', (tester) async {
    ecranBureau(tester);
    addTearDown(tester.view.reset);
    final serveur = FauxServeurAdmin()..enPanne = true;
    await tester.pumpWidget(
      await adminDeTest(
        auth: FauxAuthAdmin(dejaConnecte: true),
        serveur: serveur,
      ),
    );
    await stabiliser(tester);
    expect(find.textContaining('Impossible de charger'), findsOneWidget);
    serveur.enPanne = false;
    await _toucher(tester, find.text('Réessayer'));
    expect(find.text('Boutiques inscrites'), findsOneWidget);
  });

  testWidgets('« Afficher plus » : pages suivantes jusqu\'au total', (
    tester,
  ) async {
    ecranBureau(tester);
    addTearDown(tester.view.reset);
    final serveur = FauxServeurAdmin()..ajouterBoutiques(114);
    await tester.pumpWidget(
      await adminDeTest(
        auth: FauxAuthAdmin(dejaConnecte: true),
        serveur: serveur,
      ),
    );
    await stabiliser(tester);
    await _toucher(tester, find.text('Boutiques').first);
    expect(find.text('50 sur 120'), findsOneWidget);
    Future<void> enHaut() async {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 30000));
      await stabiliser(tester);
    }

    await _toucher(tester, find.text('Afficher plus'));
    await enHaut();
    expect(find.text('100 sur 120'), findsOneWidget);
    await _toucher(tester, find.text('Afficher plus'));
    await enHaut();
    expect(find.text('120 sur 120'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Boutique 113'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Boutique 113'), findsOneWidget);
    expect(find.text('Afficher plus'), findsNothing);
  });

  testWidgets('session révoquée : retour à la connexion', (tester) async {
    ecranBureau(tester);
    addTearDown(tester.view.reset);
    final auth = FauxAuthAdmin(dejaConnecte: true);
    await tester.pumpWidget(
      await adminDeTest(auth: auth, serveur: FauxServeurAdmin()),
    );
    await stabiliser(tester);
    expect(find.text('Boutiques inscrites'), findsOneWidget);
    auth.terminerSession();
    await stabiliser(tester);
    expect(find.text('Espace admin'), findsOneWidget);
  });

  testWidgets('geste refusé par le serveur : le champ est signalé', (
    tester,
  ) async {
    ecranBureau(tester);
    addTearDown(tester.view.reset);
    final serveur = FauxServeurAdmin()..prochainRefus = RefusAjustement.motif;
    await tester.pumpWidget(
      await adminDeTest(
        auth: FauxAuthAdmin(dejaConnecte: true),
        serveur: serveur,
      ),
    );
    await stabiliser(tester);
    await _toucher(tester, find.text('Boutiques').first);
    await _toucher(tester, find.text('Chez Awa'));
    await _toucher(tester, find.text('Offrir des jours'));
    await tester.enterText(find.widgetWithText(TextField, 'Motif'), 'Test');
    await _toucher(tester, find.text('Offrir'));
    expect(find.text('Expliquez le geste en quelques mots.'), findsOneWidget);
    expect(find.textContaining('Impossible de charger'), findsNothing);
    expect(serveur.gestes, isEmpty);
  });

  testWidgets('petit écran : menu en bas, fiche en plein écran', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(412, 915);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      await adminDeTest(
        auth: FauxAuthAdmin(dejaConnecte: true),
        serveur: FauxServeurAdmin(),
      ),
    );
    await stabiliser(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
    await _toucher(tester, find.text('Boutiques').last);
    await _toucher(tester, find.text('Chez Awa'));
    expect(find.text('Offrir des jours'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    // Geste depuis la fiche seule : elle montre tout de suite la nouvelle fin.
    await _toucher(tester, find.text('Offrir des jours'));
    await tester.enterText(find.widgetWithText(TextField, 'Motif'), 'Fidélité');
    await _toucher(tester, find.text('Offrir'));
    expect(find.textContaining('Kassa Pro jusqu\'au 11 nov.'), findsOneWidget);
  });

  testWidgets('lieux : corriger une faute, doublon refusé, retirer', (
    tester,
  ) async {
    ecranBureau(tester);
    addTearDown(tester.view.reset);
    final serveur = FauxServeurAdmin();
    await tester.pumpWidget(
      await adminDeTest(
        auth: FauxAuthAdmin(dejaConnecte: true),
        serveur: serveur,
      ),
    );
    await stabiliser(tester);
    await _toucher(tester, find.text('Lieux').first);
    expect(find.text('4 sur 4'), findsOneWidget);
    expect(find.text('Baleveng'), findsOneWidget);
    expect(find.text('Dschang, Menoua'), findsWidgets);
    expect(find.text('Quartier de Koutaba'), findsNWidgets(2));
    expect(
      find.text('Liste des villages : © contributeurs OpenStreetMap'),
      findsOneWidget,
    );

    // « Haousa » est une faute pour « Haoussa », qui existe déjà : refusé.
    await _toucher(tester, find.text('Corriger').first);
    expect(find.text('Corriger « Haousa »'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Nom correct'),
      'Haoussa',
    );
    await _toucher(tester, find.text('Enregistrer'));
    expect(
      find.text(
        'Ce nom existe déjà au même endroit : retirez plutôt ce doublon.',
      ),
      findsOneWidget,
    );
    await _toucher(tester, find.text('Annuler'));

    // On retire donc le doublon.
    await _toucher(tester, find.text('Retirer').first);
    expect(find.text('Retirer « Haousa » ?'), findsOneWidget);
    await _toucher(tester, find.text('Retirer').last);
    expect(serveur.suppressions, ['q1']);
    expect(find.text('« Haousa » retiré.'), findsOneWidget);
    expect(find.text('3 sur 3'), findsOneWidget);

    // Et on corrige un nom de village.
    await _toucher(tester, find.text('Corriger').first);
    await tester.enterText(
      find.widgetWithText(TextField, 'Nom correct'),
      '  Baleveng   Centre ',
    );
    await _toucher(tester, find.text('Enregistrer'));
    expect(serveur.renommages, [('l1', 'Baleveng Centre')]);
    expect(find.text('Baleveng Centre'), findsOneWidget);
  });
}
