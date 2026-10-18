/// Lien WhatsApp (wa.me) avec un message pré-rempli, sans frais.
abstract final class WhatsApp {
  /// Indicatif du Cameroun, ajouté aux numéros locaux à 9 chiffres.
  static const indicatifCameroun = '237';

  /// Garde les chiffres seulement. Numéro local camerounais (9 chiffres) :
  /// l'indicatif 237 est ajouté. Numéro en 237 : 12 chiffres exactement.
  /// Autre numéro international : 10 à 15 chiffres. Sinon null (par exemple
  /// un ancien numéro à 8 chiffres, qui partirait vers un autre pays).
  static String? numeroInternational(String? telephone) {
    if (telephone == null) return null;
    var chiffres = telephone.replaceAll(RegExp(r'[^0-9]'), '');
    if (chiffres.startsWith('00')) chiffres = chiffres.substring(2);
    if (chiffres.length == 9) return '$indicatifCameroun$chiffres';
    if (chiffres.startsWith(indicatifCameroun)) {
      return chiffres.length == 12 ? chiffres : null;
    }
    return chiffres.length >= 10 && chiffres.length <= 15 ? chiffres : null;
  }

  /// `https://wa.me/<numéro>?text=<message>`, ou null sans numéro valide.
  static Uri? lien({required String? telephone, required String message}) {
    final numero = numeroInternational(telephone);
    if (numero == null) return null;
    return Uri.https('wa.me', '/$numero', {'text': message});
  }
}
