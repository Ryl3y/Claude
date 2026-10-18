// Parcours de l'étape 6, hors ligne sur une base en mémoire : ajout et
// modification d'un client, encaissement de dette (partiel, total, trop
// grand) avec reçu WhatsApp, rappel depuis la liste, suppression.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/core/heure_douala.dart';
import 'package:kassa/data/db/tables.dart';
import 'package:kassa/ui/widgets/widgets.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';

const _e = ' ';

Future<AppDeTest> _demarrer(WidgetTester tester, {String langue = 'fr'}) async {
  tester.view.physicalSize = const Size(412 * 3, 915 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final app = await AppDeTest.creer(langue: langue);
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

Future<void> _taper(WidgetTester tester, String chiffres) async {
  for (final c in chiffres.split('')) {
    await tester.tap(
      find.descendant(of: find.byType(NumPad), matching: find.text(c)),
    );
    await tester.pump();
  }
  await stabiliser(tester);
}

/// Un client « Awa » (téléphone camerounais) qui doit 7 000 FCFA.
Future<String> _awaQuiDoit(WidgetTester tester, AppDeTest app) async {
  final riz = await app.ajouterProduit(tester, nom: 'Riz', prixVente: 3500);
  final awa = await app.ajouterClient(
    tester,
    nom: 'Awa',
    telephone: '6 90 00 00 01',
  );
  await app.vendreACredit(tester, clientId: awa, produitId: riz, quantite: 2);
  return awa;
}

void main() {
  setUpAll(() async {
    await preparerTestsWidgets();
    // Date figée : le reçu dit toujours « le 10 oct. ».
    HeureDouala.horloge = () => DateTime.utc(2026, 10, 10, 9);
  });
  tearDownAll(() => HeureDouala.horloge = DateTime.now);

  testWidgets('ajouter un client : il s\'ouvre sur sa fiche, à jour', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    await ouvrirClients(tester);
    expect(find.text('Aucun client pour l\'instant'), findsOneWidget);

    await _toucher(tester, find.text('Nouveau client'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nom du client'),
      'Maman Brigitte',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Téléphone (facultatif)'),
      '6 90 00 00 01',
    );
    await _toucher(tester, find.text('Ajouter le client'));

    expect(find.text('Maman Brigitte'), findsOneWidget); // titre de la fiche
    expect(find.text('À jour'), findsOneWidget);
    expect(
      find.text('Aucun achat ni versement pour l\'instant.'),
      findsOneWidget,
    );
    final c = await tester.runAsync(
      () => app.db.select(app.db.clients).getSingle(),
    );
    expect(c!.nom, 'Maman Brigitte');
    expect(c.telephone, '6 90 00 00 01');
    await app.fermer(tester);
  });

  testWidgets('téléphone invalide : message qui dit quoi faire', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    await ouvrirClients(tester);
    await _toucher(tester, find.text('Nouveau client'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nom du client'),
      'Paul',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Téléphone (facultatif)'),
      '1234',
    );
    await _toucher(tester, find.text('Ajouter le client'));
    expect(
      find.text(
        'Numéro invalide. Saisissez 9 chiffres, par exemple 6 77 12 34 56.',
      ),
      findsOneWidget,
    );
    expect(
      await tester.runAsync(() => app.db.select(app.db.clients).get()),
      isEmpty,
    );
    await app.fermer(tester);
  });

  testWidgets('encaissement partiel et reçu WhatsApp', (tester) async {
    final app = await _demarrer(tester);
    await _awaQuiDoit(tester, app);
    await ouvrirClients(tester);
    expect(find.text('Doit${_e}7${_e}000${_e}F'), findsWidgets);

    await _toucher(tester, find.text('Awa'));
    expect(find.text('Doit${_e}7${_e}000${_e}FCFA'), findsOneWidget);
    expect(find.text('Achat à crédit · N°1'), findsOneWidget);

    await _toucher(tester, find.text('Encaisser'));
    expect(find.text('Encaisser une dette'), findsOneWidget);
    await _taper(tester, '5000');
    expect(find.text('Il restera à payer'), findsOneWidget);
    expect(find.text('Doit${_e}2${_e}000${_e}FCFA'), findsOneWidget);
    await _toucher(tester, find.text('Encaisser 5${_e}000${_e}FCFA'));

    expect(find.text('Versement enregistré'), findsOneWidget);
    expect(find.text('Il reste 2${_e}000${_e}FCFA à payer.'), findsOneWidget);
    await _toucher(tester, find.text('Envoyer le reçu'));
    final lien = app.liens.single;
    expect(lien.host, 'wa.me');
    expect(lien.path, '/237690000001');
    expect(
      lien.queryParameters['text'],
      'Bonjour Awa, le 10 oct., nous avons bien reçu 5${_e}000${_e}FCFA.\n'
      'Il vous reste 2${_e}000${_e}FCFA à payer. Merci.\n'
      'Chez Awa',
    );

    await _toucher(tester, find.text('Terminer'));
    expect(find.text('Doit${_e}2${_e}000${_e}FCFA'), findsOneWidget);
    expect(find.text('Versement · Espèces'), findsOneWidget);
    final versement = await tester.runAsync(
      () => app.db.select(app.db.versementsDette).getSingle(),
    );
    expect(versement!.montant, 5000);
    expect(versement.modePaiement, ModePaiement.especes);
    await app.fermer(tester);
  });

  testWidgets('toute la dette en MoMo : le client est à jour', (tester) async {
    final app = await _demarrer(tester);
    await _awaQuiDoit(tester, app);
    await ouvrirClients(tester);
    await _toucher(tester, find.text('Awa'));
    await _toucher(tester, find.text('Encaisser'));
    await _toucher(tester, find.text('MTN MoMo'));
    await _toucher(tester, find.text('Toute la dette · 7${_e}000${_e}F'));
    expect(find.text('Dette soldée'), findsOneWidget);
    await _toucher(tester, find.text('Encaisser 7${_e}000${_e}FCFA'));
    expect(find.text('Sa dette est soldée.'), findsOneWidget);
    await _toucher(tester, find.text('Terminer'));

    expect(find.text('À jour'), findsOneWidget);
    expect(find.text('Encaisser'), findsNothing);
    expect(find.text('Versement · MTN MoMo'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('plus que la dette : message et bouton désactivé', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    await _awaQuiDoit(tester, app);
    await ouvrirClients(tester);
    await _toucher(tester, find.text('Awa'));
    await _toucher(tester, find.text('Encaisser'));
    await _taper(tester, '9000');
    expect(
      find.text('Awa ne doit que 7${_e}000${_e}FCFA. Baissez le montant.'),
      findsOneWidget,
    );
    final bouton = tester.widget<KassaButton>(
      find.widgetWithText(KassaButton, 'Encaisser 9${_e}000${_e}FCFA'),
    );
    expect(bouton.onPressed, isNull);
    await app.fermer(tester);
  });

  for (final langue in ['fr', 'en']) {
    testWidgets('rappel WhatsApp depuis la liste ($langue)', (tester) async {
      final app = await _demarrer(tester, langue: langue);
      await _awaQuiDoit(tester, app);
      await ouvrirClients(
        tester,
        libelle: langue == 'fr' ? 'Clients' : 'Customers',
      );
      await _toucher(
        tester,
        find.byTooltip(
          langue == 'fr'
              ? 'Rappeler Awa sur WhatsApp'
              : 'Remind Awa on WhatsApp',
        ),
      );
      expect(
        app.liens.single.queryParameters['text'],
        langue == 'fr'
            ? 'Bonjour Awa, il vous reste 7${_e}000${_e}FCFA à payer. Merci.\n'
                  'Chez Awa'
            : 'Hello Awa, you still owe 7,000${_e}FCFA. Thank you.\nChez Awa',
      );
      await app.fermer(tester);
    });
  }

  testWidgets('client sans numéro : pas de rappel, aide affichée', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    final riz = await app.ajouterProduit(tester, nom: 'Riz', prixVente: 3500);
    final paul = await app.ajouterClient(tester, nom: 'Paul');
    await app.vendreACredit(tester, clientId: paul, produitId: riz);
    await ouvrirClients(tester);
    expect(find.byTooltip('Rappeler Paul sur WhatsApp'), findsNothing);
    await _toucher(tester, find.text('Paul'));
    expect(
      find.text('Ajoutez son numéro pour lui envoyer un rappel WhatsApp.'),
      findsOneWidget,
    );
    await app.fermer(tester);
  });

  testWidgets('modifier le client', (tester) async {
    final app = await _demarrer(tester);
    await app.ajouterClient(tester, nom: 'Paul');
    await ouvrirClients(tester);
    await _toucher(tester, find.text('Paul'));
    await _toucher(tester, find.text('Modifier'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nom du client'),
      'Paul Ngando',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Note (facultatif)'),
      'Paie le samedi',
    );
    await _toucher(tester, find.text('Enregistrer'));
    expect(find.text('Paul Ngando'), findsOneWidget);
    expect(find.text('Paie le samedi'), findsOneWidget);
    await app.fermer(tester);
  });

  testWidgets('suppression : refusée avec une dette, sinon confirmée', (
    tester,
  ) async {
    final app = await _demarrer(tester);
    await _awaQuiDoit(tester, app);
    await app.ajouterClient(tester, nom: 'Paul');
    await ouvrirClients(tester);

    await _toucher(tester, find.text('Awa'));
    await _toucher(tester, find.text('Modifier'));
    await _toucher(tester, find.text('Supprimer le client'));
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.text(
        'Awa doit encore 7${_e}000${_e}FCFA. Encaissez sa dette avant de le '
        'supprimer.',
      ),
      findsWidgets,
    );
    await tester.tap(find.byType(BackButton));
    await stabiliser(tester);
    await tester.tap(find.byType(BackButton));
    await stabiliser(tester);

    await _toucher(tester, find.text('Paul'));
    await _toucher(tester, find.text('Modifier'));
    await _toucher(tester, find.text('Supprimer le client'));
    expect(find.text('Supprimer Paul ?'), findsOneWidget);
    await _toucher(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Supprimer'),
      ),
    );
    expect(find.text('Paul a été supprimé.'), findsOneWidget);
    expect(find.text('Paul'), findsNothing);
    expect(find.text('Awa'), findsOneWidget);
    await app.fermer(tester);
  });
}
