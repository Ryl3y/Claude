import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _lire(String nom) =>
    jsonDecode(File('lib/l10n/$nom').readAsStringSync()) as Map<String, dynamic>;

Set<String> _cles(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  final fr = _lire('app_fr.arb');
  final en = _lire('app_en.arb');

  test('mêmes clés en français et en anglais', () {
    expect(_cles(en), _cles(fr));
  });

  test('lexique de la charte', () {
    const lexique = {
      'navHome': ('Accueil', 'Home'),
      'navSell': ('Vendre', 'Sell'),
      'navStock': ('Stock', 'Stock'),
      'navCustomers': ('Clients', 'Customers'),
      'newSale': ('Nouvelle vente', 'New sale'),
      'collectPayment': ('Encaisser', 'Collect payment'),
      'add': ('Ajouter', 'Add'),
      'restock': ('Réappro', 'Restock'),
      'owes': ('Doit {montant}', 'Owes {montant}'),
      'paidUp': ('À jour', 'Paid up'),
      'remind': ('Rappeler', 'Remind'),
      'lowStock': ('Stock bas', 'Low stock'),
      'todaySales': ('Ventes du jour', "Today's sales"),
      'moneyOwed': ('Dettes à recevoir', 'Money owed to you'),
      'saved': ('Sauvegardé', 'Saved'),
      'goPro': ('Passer à Pro', 'Go Pro'),
      'cancelSale': ('Annuler la vente', 'Cancel sale'),
    };
    lexique.forEach((cle, v) {
      expect(fr[cle], v.$1, reason: cle);
      expect(en[cle], v.$2, reason: cle);
    });
  });

  test('ton : ni point d\'exclamation, ni « synchronisation »', () {
    for (final arb in [fr, en]) {
      for (final k in _cles(arb)) {
        final texte = arb[k] as String;
        expect(texte.contains('!'), isFalse, reason: k);
        expect(texte.toLowerCase().contains('synchro'), isFalse, reason: k);
      }
    }
  });
}
