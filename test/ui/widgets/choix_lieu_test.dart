import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/domain/lieux.dart';
import 'package:kassa/ui/state/lieux.dart';
import 'package:kassa/ui/widgets/choix_lieu.dart';

import '../../aide_app.dart';
import '../../aide_widgets.dart';
import '../../data/faux_lieux.dart';
import '../aide_lieu.dart';

/// Hôte qui garde le lieu choisi, comme l'écran de création.
class _Hote extends StatefulWidget {
  const _Hote(this.sortie);
  final ValueNotifier<LieuChoisi> sortie;

  @override
  State<_Hote> createState() => _HoteState();
}

class _HoteState extends State<_Hote> {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: ChoixLieu(
      lieu: widget.sortie.value,
      onChanged: (l) => setState(() => widget.sortie.value = l),
    ),
  );
}

void main() {
  setUpAll(preparerTestsWidgets);

  Future<ValueNotifier<LieuChoisi>> monter(
    WidgetTester tester,
    FauxLieux? lieux, {
    String langue = 'fr',
    bool sombre = false,
    double echelleTexte = 1,
    double largeur = 412,
  }) async {
    tester.view.physicalSize = Size(largeur * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final sortie = ValueNotifier(const LieuChoisi());
    await tester.pumpWidget(
      await appDeTest(
        _Hote(sortie),
        langue: langue,
        sombre: sombre,
        echelleTexte: echelleTexte,
        overrides: [serviceLieuxProvider.overrideWithValue(lieux)],
      ),
    );
    // Le découpage embarqué se lit en vrai (hors du temps simulé).
    final region = find.text(langue == 'fr' ? 'Région' : 'Region');
    for (var i = 0; i < 50 && region.evaluate().isEmpty; i++) {
      await stabiliser(tester);
    }
    expect(region, findsOneWidget);
    return sortie;
  }

  testWidgets('cascade : chaque liste dépend du choix au-dessus', (
    tester,
  ) async {
    final sortie = await monter(tester, FauxLieux());
    expect(find.text('Département'), findsNothing);

    await choisirDansListe(tester, 'Région', 'Ouest');
    await choisirDansListe(tester, 'Département', 'Menoua');
    await tester.tap(find.text('Arrondissement'));
    await stabiliser(tester);
    // Seuls les arrondissements de la Menoua sont proposés.
    expect(find.text('Santchou'), findsWidgets);
    expect(find.text('Koutaba'), findsNothing);
    await tester.tap(find.text('Dschang').last);
    await stabiliser(tester);
    expect(sortie.value.arrondissement, 'CM008005001');

    await saisirLieu(tester, 'Ville ou village', 'dsch', choix: 'Dschang');
    expect(sortie.value.localite?.nom, 'Dschang');

    // Changer de département efface ce qui est en dessous.
    await choisirDansListe(tester, 'Département', 'Noun');
    expect(sortie.value.departement, 'CM008008');
    expect(sortie.value.arrondissement, isNull);
    expect(sortie.value.localite, isNull);
    expect(find.text('Ville ou village'), findsNothing);
  });

  testWidgets('les noms proposés suivent la saisie, sans accents', (
    tester,
  ) async {
    final lieux = FauxLieux();
    final sortie = await monter(tester, lieux);
    await choisirArrondissement(tester, 'Ouest', 'Menoua', 'Dschang');
    await tester.enterText(
      find.widgetWithText(TextField, 'Ville ou village'),
      'FOREKE',
    );
    await stabiliser(tester);
    expect(find.text('Foréké-Dschang'), findsOneWidget);
    expect(find.text('Fongo-Ndeng'), findsNothing);
    // Le nom tapé n'est qu'un morceau : on peut encore l'ajouter.
    expect(find.text('Ajouter « FOREKE »'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Ville ou village'),
      'foreke dschang',
    );
    await stabiliser(tester);
    // Même nom, écrit autrement : c'est le village existant, pas un doublon.
    expect(sortie.value.localite, lieux.lieuNomme('Foréké-Dschang'));
    expect(find.textContaining('Ajouter'), findsNothing);
  });

  testWidgets('quartier déjà enregistré : proposé dès les premières '
      'lettres, dans son village seulement', (tester) async {
    final lieux = FauxLieux();
    final sortie = await monter(tester, lieux);
    await choisirArrondissement(tester, 'Ouest', 'Menoua', 'Dschang');
    await saisirLieu(tester, 'Ville ou village', 'dsch', choix: 'Dschang');
    await saisirLieu(tester, 'Quartier', 'hao', choix: 'Haoussa');
    expect(sortie.value.quartier, lieux.lieuNomme('Haoussa'));

    // À Koutaba, Haoussa n'est pas encore connu : on l'ajoute.
    await choisirArrondissement(tester, 'Ouest', 'Noun', 'Koutaba');
    await saisirLieu(tester, 'Ville ou village', 'kou', choix: 'Koutaba');
    await saisirLieu(
      tester,
      'Quartier',
      'Haoussa',
      choix: 'Ajouter « Haoussa »',
    );
    expect(sortie.value.quartier, const Lieu(null, 'Haoussa'));
    expect(
      find.text('Nouveau : « Haoussa » sera ajouté à la liste.'),
      findsOneWidget,
    );
  });

  testWidgets('village absent de la liste : on le tape et on l\'ajoute', (
    tester,
  ) async {
    final sortie = await monter(tester, FauxLieux());
    await choisirArrondissement(tester, 'Ouest', 'Menoua', 'Dschang');
    await saisirLieu(
      tester,
      'Ville ou village',
      'Baleveng',
      choix: 'Ajouter « Baleveng »',
    );
    expect(sortie.value.localite, const Lieu(null, 'Baleveng'));
    // Village nouveau : aucun quartier connu, on tape le sien.
    await saisirLieu(
      tester,
      'Quartier',
      'Chefferie',
      choix: 'Ajouter « Chefferie »',
    );
    expect(sortie.value.complet, isTrue);
  });

  testWidgets('sans internet : on tape le nom, il est gardé', (tester) async {
    final sortie = await monter(tester, FauxLieux()..horsLigne = true);
    await choisirArrondissement(tester, 'Ouest', 'Menoua', 'Dschang');
    expect(
      find.text(
        'Liste indisponible sans internet : tapez le nom, il sera '
        'gardé tel quel.',
      ),
      findsOneWidget,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Ville ou village'),
      'Dschang',
    );
    await stabiliser(tester);
    expect(sortie.value.localite, const Lieu(null, 'Dschang'));
    expect(find.text('Quartier'), findsOneWidget);
  });

  testWidgets('attribution OpenStreetMap affichée', (tester) async {
    await monter(tester, FauxLieux());
    await choisirArrondissement(tester, 'Ouest', 'Menoua', 'Dschang');
    expect(
      find.text('Liste des villages : © contributeurs OpenStreetMap'),
      findsOneWidget,
    );
  });

  for (final (langue, sombre) in [
    ('fr', false),
    ('fr', true),
    ('en', false),
    ('en', true),
  ]) {
    testWidgets('accessibilité — $langue ${sombre ? 'sombre' : 'clair'} : '
        'zones de toucher, libellés, contrastes des propositions', (
      tester,
    ) async {
      final semantique = tester.ensureSemantics();
      final fr = langue == 'fr';
      await monter(tester, FauxLieux(), langue: langue, sombre: sombre);
      await choisirArrondissement(
        tester,
        fr ? 'Ouest' : 'West',
        'Menoua',
        'Dschang',
        anglais: !fr,
      );
      await saisirLieu(
        tester,
        fr ? 'Ville ou village' : 'Town or village',
        'dsch',
        choix: 'Dschang',
      );
      final quartier = find.widgetWithText(
        TextField,
        fr ? 'Quartier' : 'Neighbourhood',
      );
      await tester.tap(quartier);
      await tester.enterText(quartier, 'ha');
      await stabiliser(tester);
      expect(find.text('Haoussa'), findsOneWidget);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantique.dispose();
    });
  }

  testWidgets('texte à 200 % sur écran étroit : aucun débordement', (
    tester,
  ) async {
    await monter(tester, FauxLieux(), echelleTexte: 2, largeur: 320);
    await choisirArrondissement(
      tester,
      'Extrême-Nord',
      'Mayo-Danay',
      'Kai-Kai',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Ville ou village'),
      'Un village au nom vraiment très long',
    );
    await stabiliser(tester);
    expect(tester.takeException(), isNull);
  });
}
