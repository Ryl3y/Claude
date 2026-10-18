/// Lecture des nombres saisis au clavier.
abstract final class Saisie {
  /// Montant en FCFA : chiffres seulement (espaces tolérés). Null si invalide.
  static int? montant(String texte) {
    final propre = texte.replaceAll(RegExp('[\\s\\u00A0\\u202F]'), '');
    if (propre.isEmpty || !RegExp(r'^\d{1,9}$').hasMatch(propre)) return null;
    return int.parse(propre);
  }

  /// Quantité décimale : « 12 », « 1,5 », « 1.5 » ou « -2 » (un stock peut
  /// être négatif après des ventes non saisies en stock). Null si invalide.
  static double? quantite(String texte) {
    final propre = texte
        .replaceAll(RegExp('[\\s\\u00A0\\u202F]'), '')
        .replaceAll(',', '.');
    if (!RegExp(r'^-?\d{1,7}(\.\d{1,3})?$').hasMatch(propre)) return null;
    return double.parse(propre);
  }

  /// Texte sans accents ni majuscules, pour la recherche (« Épicerie » → « epicerie »).
  static String pourRecherche(String texte) {
    const remplacements = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'á': 'a',
      'ã': 'a',
      'å': 'a',
      'ç': 'c',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ñ': 'n',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ý': 'y',
      'ÿ': 'y',
      'œ': 'oe',
      'æ': 'ae',
    };
    final sortie = StringBuffer();
    for (final c in texte.toLowerCase().split('')) {
      sortie.write(remplacements[c] ?? c);
    }
    return sortie.toString().trim();
  }
}
