// Parcours de l'étape 9 : Réglages (langue, sauvegarde, déconnexion),
// fin d'essai en lecture seule, et paiement Kassa Pro avec Notch Pay.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/core/heure_douala.dart';
import 'package:kassa/data/abonnement/service_abonnement.dart';
import 'package:kassa/domain/abonnement.dart';
import 'package:kassa/ui/screens/abonnement/abonnement_screen.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';
import '../../data/faux_abonnement.dart';
import '../../data/faux_auth.dart';

/// Fait défiler l'écran jusqu'à [f] (les listes ne construisent que ce
/// qui est visible), puis le touche.
Future<void> _toucher(WidgetTester tester, Finder f) async {
  await _montrer(tester, f);
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await stabiliser(tester);
}

Future<void> _montrer(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
  }
}

/// Date de fin à [jours] d'aujourd'hui (Douala), au format du serveur.
String _dans(int jours) => EtatAbonnement.ecrireDate(
  EtatAbonnement.jourDouala(DateTime.now().toUtc()).add(Duration(days: jours)),
);

/// Attend une vérification du paiement (toutes les 3 secondes).
Future<void> _verification(WidgetTester tester) async {
  await tester.pump(AbonnementScreen.intervalle);
  await stabiliser(tester);
}

void main() {
  setUpAll(preparerTestsWidgets);

  testWidgets('Réglages : passer l\'app en anglais', (tester) async {
    final app = await AppDeTest.creer();
    await tester.pumpWidget(app.widget);
    await stabiliser(tester);

    await _toucher(tester, find.text('Réglages'));
    expect(find.text('Essai gratuit : 30 jours restants'), findsOneWidget);
    await _toucher(tester, find.text('English'));
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Free trial: 30 days left'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('déconnexion : confirmation, téléphone vidé, retour à '
      'la bienvenue', (tester) async {
    final auth = FauxAuth();
    await auth.verifierCode(AppDeTest.telephone, auth.codeAttendu);
    final app = await AppDeTest.creer(auth: auth);
    await tester.pumpWidget(app.widget);
    await stabiliser(tester);
    await app.ajouterProduit(tester, nom: 'Riz parfumé 5 kg');

    await _toucher(tester, find.text('Réglages'));
    await _montrer(tester, find.text('+237 6 90 00 00 00'));
    expect(find.text('+237 6 90 00 00 00'), findsOneWidget);
    await _toucher(tester, find.text('Se déconnecter'));
    // Sans serveur de sauvegarde : rien n'est en ligne, on prévient.
    expect(
      find.text(
        'Cette boutique n\'est pas sauvegardée en ligne : toutes ses '
        'données seront perdues.',
      ),
      findsOneWidget,
    );
    await _toucher(tester, find.text('Annuler'));
    expect(find.text('Se déconnecter de ce téléphone ?'), findsNothing);
    expect(
      await tester.runAsync(() => app.db.select(app.db.produits).get()),
      isNotEmpty,
    );

    await _toucher(tester, find.text('Se déconnecter'));
    await _toucher(tester, find.text('Effacer et se déconnecter'));
    await stabiliser(tester);

    expect(find.text('Réglages'), findsNothing);
    expect(find.text('Votre caisse, même sans internet'), findsOneWidget);
    expect(auth.utilisateurId, isNull);
    final lignes = await tester.runAsync(
      () => app.db.select(app.db.boutiques).get(),
    );
    expect(lignes, isEmpty);
    await app.fermer(tester);
  });

  testWidgets('essai bientôt fini : l\'accueil prévient', (tester) async {
    final app = await AppDeTest.creer(abonnementGarde: ('gratuit', _dans(3)));
    await tester.pumpWidget(app.widget);
    await stabiliser(tester);
    expect(find.text('Essai gratuit : 3 jours restants'), findsOneWidget);
    expect(find.text('Passer à Pro'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('essai terminé : lecture seule, puis paiement Pro réussi', (
    tester,
  ) async {
    final serveur = FauxAbonnement(
      abonnement: AbonnementServeur(formule: 'gratuit', dateFin: _dans(-1)),
    );
    final app = await AppDeTest.creer(
      abonnementGarde: ('gratuit', _dans(-1)),
      abonnement: serveur,
    );
    await tester.pumpWidget(app.widget);
    await stabiliser(tester);
    expect(find.text('Votre essai gratuit est terminé'), findsOneWidget);

    // Nouvelle vente : bloquée, l'offre Pro est proposée.
    await _toucher(tester, find.text('Nouvelle vente'));
    expect(find.text('Plus tard'), findsOneWidget);
    await _toucher(tester, find.text('Plus tard'));
    expect(find.text('Ventes du jour'), findsOneWidget);

    // Les données restent visibles : les onglets s'ouvrent.
    await _toucher(tester, find.text('Nouvelle vente'));
    await _toucher(tester, find.text('Passer à Pro').last);
    expect(find.textContaining('FCFA / mois'), findsOneWidget);

    // Paiement Orange Money, numéro du compte déjà rempli.
    await _toucher(tester, find.text('Orange Money'));
    await _toucher(tester, find.textContaining(RegExp(r'^Payer 5.000.FCFA$')));
    expect(serveur.demandes, [(Operateur.orange, AppDeTest.telephone)]);
    expect(
      find.text('Validez le paiement sur votre téléphone'),
      findsOneWidget,
    );

    // Toujours en attente, puis confirmé par Notch Pay.
    await _verification(tester);
    expect(
      find.text('Validez le paiement sur votre téléphone'),
      findsOneWidget,
    );
    serveur
      ..statutPaiement = StatutPaiement.reussi
      ..abonnement = AbonnementServeur(formule: 'pro', dateFin: _dans(30));
    await _verification(tester);
    expect(
      find.textContaining('Kassa Pro est activé jusqu\'au'),
      findsOneWidget,
    );

    await _toucher(tester, find.text('Terminer'));
    expect(find.text('Votre essai gratuit est terminé'), findsNothing);
    await _toucher(tester, find.text('Nouvelle vente'));
    expect(find.text('Plus tard'), findsNothing);
    await app.fermer(tester);
  });

  testWidgets('paiement refusé, demande déjà en cours, numéro faux', (
    tester,
  ) async {
    final serveur = FauxAbonnement();
    final app = await AppDeTest.creer(abonnement: serveur);
    await tester.pumpWidget(app.widget);
    await stabiliser(tester);
    await _toucher(tester, find.text('Réglages'));
    await _toucher(tester, find.text('Passer à Pro'));

    serveur.prochaineErreur = ErreurPaiement.demandeEnCours;
    await _toucher(tester, find.textContaining(RegExp(r'^Payer 5.000.FCFA$')));
    await _montrer(
      tester,
      find.textContaining('Un paiement attend déjà votre validation'),
    );
    expect(
      find.textContaining('Un paiement attend déjà votre validation'),
      findsOneWidget,
    );

    await _toucher(tester, find.textContaining(RegExp(r'^Payer 5.000.FCFA$')));
    serveur.statutPaiement = StatutPaiement.echoue;
    await _verification(tester);
    await _montrer(
      tester,
      find.text(
        'Le paiement n\'a pas abouti. Vérifiez votre solde Mobile Money, '
        'puis réessayez.',
      ),
    );
    expect(
      find.text(
        'Le paiement n\'a pas abouti. Vérifiez votre solde Mobile Money, '
        'puis réessayez.',
      ),
      findsOneWidget,
    );
    expect(serveur.demandes.single.$1, Operateur.mtn);

    await tester.enterText(find.byType(TextField), '12345');
    await _toucher(tester, find.textContaining(RegExp(r'^Payer 5.000.FCFA$')));
    await _montrer(tester, find.textContaining('Numéro invalide'));
    expect(find.textContaining('Numéro invalide'), findsOneWidget);
    expect(serveur.demandes, hasLength(1));
    await app.fermer(tester);
  });

  testWidgets('sans réponse du serveur, l\'app ne se bloque pas seule', (
    tester,
  ) async {
    // Boutique créée il y a 60 jours (restaurée sur un nouveau téléphone),
    // abonnement jamais lu : le serveur a le dernier mot.
    final app = await AppDeTest.creer(abonnement: FauxAbonnement());
    HeureDouala.horloge = () => DateTime.now().add(const Duration(days: 60));
    addTearDown(() => HeureDouala.horloge = DateTime.now);
    await tester.pumpWidget(app.widget);
    await stabiliser(tester);
    expect(find.text('Votre essai gratuit est terminé'), findsNothing);
    await _toucher(tester, find.text('Nouvelle vente'));
    expect(find.text('Plus tard'), findsNothing);
    await app.fermer(tester);
  });

  testWidgets('sans serveur : le paiement est indisponible', (tester) async {
    final app = await AppDeTest.creer();
    await tester.pumpWidget(app.widget);
    await stabiliser(tester);
    await _toucher(tester, find.text('Réglages'));
    await _toucher(tester, find.text('Passer à Pro'));
    expect(
      find.text(
        'Le paiement en ligne n\'est pas disponible sur cette version de '
        'Kassa.',
      ),
      findsOneWidget,
    );
    await app.fermer(tester);
  });
}
