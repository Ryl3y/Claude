/// Numéros de téléphone camerounais (+237, 9 chiffres).
abstract final class Telephone {
  static const indicatif = '237';

  /// Numéro saisi (« 6 77 12 34 56 », « +237 677123456 »…) au format
  /// international, chiffres seulement (« 237677123456 »), ou null s'il
  /// n'est pas un numéro camerounais (9 chiffres commençant par 2 ou 6).
  static String? versInternational(String saisie) {
    var chiffres = saisie.replaceAll(RegExp(r'[^0-9]'), '');
    if (chiffres.startsWith('00$indicatif')) chiffres = chiffres.substring(2);
    if (chiffres.length == 12 && chiffres.startsWith(indicatif)) {
      chiffres = chiffres.substring(3);
    }
    if (!RegExp(r'^[26]\d{8}$').hasMatch(chiffres)) return null;
    return '$indicatif$chiffres';
  }

  /// « 237677123456 » → « +237 6 77 12 34 56 ».
  static String afficher(String international) {
    final local = international.startsWith(indicatif)
        ? international.substring(indicatif.length)
        : international;
    if (local.length != 9) return '+$international';
    return '+$indicatif ${local[0]} ${local.substring(1, 3)} '
        '${local.substring(3, 5)} ${local.substring(5, 7)} '
        '${local.substring(7)}';
  }
}
