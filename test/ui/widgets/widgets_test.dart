import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/ui/theme/kassa_tokens.dart';
import 'package:kassa/ui/widgets/widgets.dart';

import '../../aide_widgets.dart';

void main() {
  setUpAll(preparerTestsWidgets);

  group('KassaButton', () {
    testWidgets('toucher appelle onPressed ; 48 px minimum', (tester) async {
      var appuis = 0;
      await tester.pumpWidget(
        await appDeTest(
          Center(
            child: KassaButton(label: 'Encaisser', onPressed: () => appuis++),
          ),
        ),
      );
      await tester.tap(find.text('Encaisser'));
      expect(appuis, 1);
      expect(
        tester.getSize(find.byType(TextButton)).height,
        greaterThanOrEqualTo(KassaSize.touchMin),
      );
    });

    testWidgets('taille principale : 56 px, pleine largeur', (tester) async {
      await tester.pumpWidget(
        await appDeTest(
          KassaButton(
            label: 'Encaisser',
            size: KassaButtonSize.main,
            fullWidth: true,
            onPressed: () {},
          ),
        ),
      );
      final taille = tester.getSize(find.byType(TextButton));
      expect(taille.height, greaterThanOrEqualTo(KassaSize.buttonMain));
      expect(taille.width, tester.getSize(find.byType(Scaffold)).width);
    });

    testWidgets('désactivé : aucun appel, état lu par le lecteur d\'écran', (
      tester,
    ) async {
      await tester.pumpWidget(
        await appDeTest(
          const Center(child: KassaButton(label: 'Ajouter', onPressed: null)),
        ),
      );
      await tester.tap(find.text('Ajouter'), warnIfMissed: false);
      final noeud = tester.getSemantics(find.byType(TextButton));
      expect(
        noeud.getSemanticsData().flagsCollection.isEnabled,
        Tristate.isFalse,
      );
    });

    testWidgets('chaque variante s\'affiche', (tester) async {
      await tester.pumpWidget(
        await appDeTest(
          Column(
            children: [
              for (final v in KassaButtonVariant.values)
                KassaButton(label: v.name, variant: v, onPressed: () {}),
            ],
          ),
        ),
      );
      for (final v in KassaButtonVariant.values) {
        expect(find.text(v.name), findsOneWidget);
      }
    });
  });

  testWidgets('KassaBadge affiche son libellé', (tester) async {
    await tester.pumpWidget(
      await appDeTest(
        const KassaBadge(label: 'Stock bas', tone: KassaBadgeTone.alerte),
      ),
    );
    expect(find.text('Stock bas'), findsOneWidget);
  });

  group('AmountText', () {
    testWidgets('dette en français : « Doit 7 500 F »', (tester) async {
      await tester.pumpWidget(
        await appDeTest(
          const AmountText(value: 7500, tone: AmountTone.dette, short: true),
        ),
      );
      expect(find.text('Doit 7 500 F', findRichText: true), findsOneWidget);
      expect(libelleDe(tester, find.byType(AmountText)), 'Doit 7 500 F');
    });

    testWidgets('dette en anglais : « Owes 7,500 F »', (tester) async {
      await tester.pumpWidget(
        await appDeTest(
          const AmountText(value: 7500, tone: AmountTone.dette, short: true),
          langue: 'en',
        ),
      );
      expect(libelleDe(tester, find.byType(AmountText)), 'Owes 7,500 F');
    });

    testWidgets('encaissé : pas de « Doit »', (tester) async {
      await tester.pumpWidget(
        await appDeTest(
          const AmountText(value: 45000, tone: AmountTone.encaisse),
        ),
      );
      expect(find.text('45 000 FCFA'), findsOneWidget);
    });

    testWidgets('montant négatif : signe moins', (tester) async {
      await tester.pumpWidget(await appDeTest(const AmountText(value: -200)));
      expect(find.text('−200 FCFA'), findsOneWidget);
    });
  });

  testWidgets('StatTile : libellé, montant, aide', (tester) async {
    await tester.pumpWidget(
      await appDeTest(
        const StatTile(
          label: 'Ventes du jour',
          value: 45000,
          tone: AmountTone.encaisse,
          hint: '23 ventes',
        ),
      ),
    );
    expect(find.text('Ventes du jour'), findsOneWidget);
    expect(find.text('23 ventes'), findsOneWidget);
    expect(find.text('45 000 FCFA'), findsOneWidget);
  });

  group('ProductCard', () {
    Future<void> monter(
      WidgetTester tester, {
      double stock = 12,
      double panier = 0,
      VoidCallback? onTap,
      VoidCallback? onLong,
    }) async {
      await tester.pumpWidget(
        await appDeTest(
          Center(
            child: SizedBox(
              width: 120,
              child: ProductCard(
                nom: 'Riz 5 kg',
                prix: 3500,
                stock: stock,
                unite: 'sacs',
                seuilAlerte: 3,
                quantiteDansPanier: panier,
                onTap: onTap,
                onLongPress: onLong,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('toucher = +1, appui long = quantité', (tester) async {
      var touches = 0, longs = 0;
      await monter(tester, onTap: () => touches++, onLong: () => longs++);
      await tester.tap(find.byType(ProductCard));
      await tester.longPress(find.byType(ProductCard));
      expect(touches, 1);
      expect(longs, 1);
    });

    testWidgets('initiales sur kassa-soft sans photo, prix court', (
      tester,
    ) async {
      await monter(tester);
      expect(find.text('RI'), findsOneWidget);
      expect(find.text('3 500 F'), findsOneWidget);
      expect(find.text('12 sacs'), findsOneWidget);
    });

    testWidgets('stock bas : mention et libellé lecteur d\'écran', (
      tester,
    ) async {
      await monter(tester, stock: 2);
      expect(find.text('2 sacs · Stock bas'), findsOneWidget);
      expect(
        libelleDe(tester, find.byType(ProductCard)),
        contains('Stock bas'),
      );
    });

    testWidgets('lecteur d\'écran : toucher et appui long disponibles', (
      tester,
    ) async {
      var touches = 0, longs = 0;
      await monter(tester, onTap: () => touches++, onLong: () => longs++);
      final noeud = tester.getSemantics(find.byType(ProductCard));
      final donnees = noeud.getSemanticsData();
      expect(donnees.hasAction(SemanticsAction.tap), isTrue);
      expect(donnees.hasAction(SemanticsAction.longPress), isTrue);
      tester.semantics.tap(find.semantics.byLabel(RegExp('Ajouter Riz')));
      expect(touches, 1);
    });

    testWidgets('pastille avec la quantité au panier', (tester) async {
      await monter(tester, panier: 3);
      expect(find.text('3'), findsOneWidget);
      expect(
        libelleDe(tester, find.byType(ProductCard)),
        'Ajouter Riz 5 kg au panier, 3 500 F, 12 sacs, 3 dans le panier',
      );
    });
  });

  group('ClientRow', () {
    testWidgets('dette : « Doit » et bouton WhatsApp', (tester) async {
      var rappels = 0;
      await tester.pumpWidget(
        await appDeTest(
          ClientRow(
            nom: 'Maman Brigitte',
            meta: '690 00 00 01',
            montantDu: 7500,
            onRappel: () => rappels++,
          ),
        ),
      );
      expect(
        find.byTooltip('Rappeler Maman Brigitte sur WhatsApp'),
        findsOneWidget,
      );
      await tester.tap(find.byType(IconButton));
      expect(rappels, 1);
      expect(find.text('À jour'), findsNothing);
    });

    testWidgets('à jour : « À jour », pas de bouton', (tester) async {
      await tester.pumpWidget(
        await appDeTest(
          ClientRow(nom: 'Paul', meta: '', montantDu: 0, onRappel: () {}),
        ),
      );
      expect(find.text('À jour'), findsOneWidget);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('toucher la ligne ouvre la fiche', (tester) async {
      var ouvertures = 0;
      await tester.pumpWidget(
        await appDeTest(
          ClientRow(
            nom: 'Paul',
            meta: '',
            montantDu: 0,
            onTap: () => ouvertures++,
          ),
        ),
      );
      await tester.tap(find.text('Paul'));
      expect(ouvertures, 1);
    });
  });

  group('NumPad', () {
    test('mode quantité : virgule, 3 décimales, pas de « 000 »', () {
      const q = NumPadMode.quantite;
      expect(NumPad.appuyer('', NumPad.virgule, mode: q), '0.');
      expect(NumPad.appuyer('1', NumPad.virgule, mode: q), '1.');
      expect(NumPad.appuyer('1.', NumPad.virgule, mode: q), '1.');
      expect(NumPad.appuyer('1.25', '5', mode: q), '1.255');
      expect(NumPad.appuyer('1.255', '5', mode: q), '1.255');
      expect(NumPad.appuyer('0', '7', mode: q), '7');
      expect(NumPad.appuyer('0.', '0', mode: q), '0.0');
      expect(NumPad.enQuantite('1.5'), 1.5);
      expect(NumPad.enQuantite(''), 0);
    });

    test('règles de saisie', () {
      expect(NumPad.appuyer('', '5'), '5');
      expect(NumPad.appuyer('5', '000'), '5000');
      expect(NumPad.appuyer('', '000'), '');
      expect(NumPad.appuyer('', '0'), '0');
      expect(NumPad.appuyer('0', '7'), '7');
      expect(NumPad.appuyer('12', NumPad.effacer), '1');
      expect(NumPad.appuyer('', NumPad.effacer), '');
      expect(NumPad.appuyer('123456789', '1'), '123456789');
      expect(NumPad.appuyer('1234567', '000'), '1234567');
      expect(NumPad.enEntier(''), 0);
      expect(NumPad.enEntier('12500'), 12500);
    });

    testWidgets('touches, affichage formaté, effacer', (tester) async {
      var valeur = '';
      await tester.pumpWidget(
        await appDeTest(
          StatefulBuilder(
            builder: (context, setState) => NumPad(
              valeur: valeur,
              onChanged: (v) => setState(() => valeur = v),
            ),
          ),
        ),
      );
      for (final touche in ['1', '2', '5', '000']) {
        await tester.tap(find.text(touche));
        await tester.pump();
      }
      expect(valeur, '125000');
      expect(find.text('125 000 FCFA'), findsOneWidget);
      await tester.tap(find.text('Effacer'));
      await tester.pump();
      expect(valeur, '12500');
      await tester.longPress(find.text('Effacer'));
      await tester.pump();
      expect(valeur, '');
    });

    testWidgets(
      'lecteur d\'écran : Effacer garde l\'appui long (tout effacer)',
      (tester) async {
        await tester.pumpWidget(
          await appDeTest(NumPad(valeur: '12', onChanged: (_) {})),
        );
        final effacer = tester.getSemantics(find.bySemanticsLabel('Effacer'));
        expect(
          effacer.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
        expect(
          effacer.getSemanticsData().hasAction(SemanticsAction.longPress),
          isTrue,
        );
      },
    );

    testWidgets('touches d\'au moins 56 px', (tester) async {
      await tester.pumpWidget(
        await appDeTest(NumPad(valeur: '', onChanged: (_) {})),
      );
      final touche = find.ancestor(
        of: find.text('7'),
        matching: find.byType(InkWell),
      );
      expect(
        tester.getSize(touche).height,
        greaterThanOrEqualTo(KassaSize.buttonMain),
      );
    });
  });

  group('KassaBottomNav', () {
    testWidgets('quatre onglets, changement d\'onglet', (tester) async {
      KassaOnglet? choisi;
      await tester.pumpWidget(
        await appDeTest(
          Align(
            alignment: Alignment.bottomCenter,
            child: KassaBottomNav(
              actif: KassaOnglet.accueil,
              onChanged: (o) => choisi = o,
            ),
          ),
        ),
      );
      for (final mot in ['Accueil', 'Vendre', 'Stock', 'Clients']) {
        expect(find.text(mot), findsOneWidget);
      }
      await tester.tap(find.text('Clients'));
      expect(choisi, KassaOnglet.clients);
    });

    testWidgets('pastille or sur Stock avec le nombre d\'alertes', (
      tester,
    ) async {
      await tester.pumpWidget(
        await appDeTest(
          Align(
            alignment: Alignment.bottomCenter,
            child: KassaBottomNav(
              actif: KassaOnglet.stock,
              alertesStock: 3,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.byType(Badge), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('3 produits en stock bas')),
        findsOneWidget,
      );
    });

    testWidgets('pas de pastille sans alerte', (tester) async {
      await tester.pumpWidget(
        await appDeTest(
          Align(
            alignment: Alignment.bottomCenter,
            child: KassaBottomNav(
              actif: KassaOnglet.accueil,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.byType(Badge), findsNothing);
    });
  });
}
