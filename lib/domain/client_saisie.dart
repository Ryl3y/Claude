import '../core/whatsapp.dart';

/// Ce que l'utilisateur saisit pour créer ou modifier un client.
class ClientSaisie {
  const ClientSaisie({required this.nom, this.telephone, this.note});

  final String nom;
  final String? telephone;
  final String? note;

  /// Nom sans espaces autour.
  String get nomPropre => nom.trim();

  /// Téléphone tel que saisi (espaces autour retirés), null si vide.
  String? get telephonePropre => _ouNull(telephone);

  /// Note sans espaces autour, null si vide.
  String? get notePropre => _ouNull(note);

  static String? _ouNull(String? texte) {
    final propre = texte?.trim();
    return propre == null || propre.isEmpty ? null : propre;
  }
}

/// Erreurs de saisie d'un client.
enum ErreurClient { nomVide, telephoneInvalide }

abstract final class ReglesClient {
  /// Erreurs de [s] (vide = saisie correcte). Le téléphone est facultatif ;
  /// s'il est rempli, il doit pouvoir recevoir un message WhatsApp. Un
  /// numéro déjà enregistré ([telephoneActuel]) et non modifié est gardé
  /// tel quel, pour pouvoir changer le nom ou la note d'un ancien client.
  static Set<ErreurClient> verifier(
    ClientSaisie s, {
    String? telephoneActuel,
  }) => {
    if (s.nomPropre.isEmpty) ErreurClient.nomVide,
    if (s.telephonePropre != null &&
        s.telephonePropre != telephoneActuel &&
        WhatsApp.numeroInternational(s.telephonePropre) == null)
      ErreurClient.telephoneInvalide,
  };
}
