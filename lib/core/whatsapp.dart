/// Lien WhatsApp (wa.me) avec un message pré-rempli, sans frais.
abstract final class WhatsApp {
  /// Indicatif du Cameroun, ajouté aux numéros locaux à 9 chiffres.
  static const indicatifCameroun = '237';

  /// Garde les chiffres seulement et ajoute l'indicatif si le numéro
  /// est local (9 chiffres). Renvoie null si le numéro est inutilisable.
  static String? numeroInternational(String? telephone) {
    if (telephone == null) return null;
    var chiffres = telephone.replaceAll(RegExp(r'[^0-9]'), '');
    if (chiffres.startsWith('00')) chiffres = chiffres.substring(2);
    if (chiffres.length == 9) chiffres = '$indicatifCameroun$chiffres';
    if (chiffres.length < 8 || chiffres.length > 15) return null;
    return chiffres;
  }

  /// `https://wa.me/<numéro>?text=<message>`, ou null sans numéro valide.
  static Uri? lien({required String? telephone, required String message}) {
    final numero = numeroInternational(telephone);
    if (numero == null) return null;
    return Uri.https('wa.me', '/$numero', {'text': message});
  }
}
