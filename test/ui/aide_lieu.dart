import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../aide_app.dart';

/// Choisit [valeur] dans la liste déroulante intitulée [libelle].
Future<void> choisirDansListe(
  WidgetTester tester,
  String libelle,
  String valeur,
) async {
  final liste = find.widgetWithText(DropdownButtonFormField<String>, libelle);
  await tester.ensureVisible(liste);
  await tester.pump();
  await tester.tap(liste);
  await stabiliser(tester);
  await tester.tap(find.text(valeur).last);
  await stabiliser(tester);
}

/// Tape [saisie] dans le champ [libelle] puis touche la proposition
/// [choix] (un nom de la liste ou « Ajouter « … » »).
Future<void> saisirLieu(
  WidgetTester tester,
  String libelle,
  String saisie, {
  required String choix,
}) async {
  final champ = find.widgetWithText(TextField, libelle);
  await tester.ensureVisible(champ);
  await tester.pump();
  await tester.tap(champ);
  await tester.pump();
  await tester.enterText(champ, saisie);
  await stabiliser(tester);
  final proposition = find.text(choix).last;
  await tester.ensureVisible(proposition);
  await tester.pump();
  await tester.tap(proposition);
  await stabiliser(tester);
}

/// Région → Département → Arrondissement (libellés en français, ou en
/// anglais avec [anglais]).
Future<void> choisirArrondissement(
  WidgetTester tester,
  String region,
  String departement,
  String arrondissement, {
  bool anglais = false,
}) async {
  await choisirDansListe(tester, anglais ? 'Region' : 'Région', region);
  await choisirDansListe(
    tester,
    anglais ? 'Division' : 'Département',
    departement,
  );
  await choisirDansListe(
    tester,
    anglais ? 'Subdivision' : 'Arrondissement',
    arrondissement,
  );
}
