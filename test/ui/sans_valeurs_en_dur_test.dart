// Vérifie que les widgets et les écrans ne contiennent ni couleur, ni taille,
// ni espacement écrits en dur : tout doit venir du thème (lib/ui/theme).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _interdits = <String, RegExp>{
  'couleur écrite en dur': RegExp(
    r'Color\(0x|Color\.fromRGBO|Colors\.(?!transparent)',
  ),
  'taille de police en dur': RegExp(r'fontSize:\s*\d'),
  'espacement en dur': RegExp(r'EdgeInsets\.[a-zA-Z]+\([^)]*\b\d+(\.\d+)?\b'),
  'boîte de taille fixe en dur': RegExp(r'SizedBox\((width|height):\s*\d'),
  'rayon en dur': RegExp(r'(Radius|BorderRadius)\.circular\(\s*\d'),
  'taille d\'icône en dur': RegExp(r'size:\s*\d'),
};

void main() {
  for (final dossier in ['lib/ui/widgets', 'lib/ui/screens']) {
    test('$dossier : aucune valeur de style en dur', () {
      final fautes = <String>[];
      for (final f in Directory(
        dossier,
      ).listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final lignes = f.readAsLinesSync();
        for (var i = 0; i < lignes.length; i++) {
          final ligne = lignes[i].trim();
          if (ligne.startsWith('//')) continue;
          _interdits.forEach((motif, regle) {
            if (regle.hasMatch(ligne)) {
              fautes.add('${f.path}:${i + 1} $motif : $ligne');
            }
          });
        }
      }
      expect(fautes, isEmpty, reason: fautes.join('\n'));
    });
  }
}
