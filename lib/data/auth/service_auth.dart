import 'package:supabase_flutter/supabase_flutter.dart';

/// Ce qui peut mal se passer pendant la connexion par SMS.
enum ErreurConnexion {
  /// Code faux ou trop vieux (Supabase ne les distingue pas).
  codeRefuse,

  /// Le SMS n'a pas pu partir (numéro refusé par le fournisseur).
  envoiSms,

  /// Trop de demandes : attendre avant d'en refaire une.
  tropDeDemandes,

  /// Pas de réseau ou serveur injoignable.
  reseau,

  /// Autre refus.
  autre,
}

class ConnexionImpossible implements Exception {
  const ConnexionImpossible(this.raison);

  final ErreurConnexion raison;

  @override
  String toString() => 'ConnexionImpossible($raison)';
}

/// Connexion par code SMS (Supabase Auth en vrai, un faux dans les tests).
/// Les numéros sont au format international, chiffres seulement
/// (« 237677123456 »).
abstract interface class ServiceAuth {
  /// Identifiant du compte connecté (null si personne).
  String? get utilisateurId;

  /// Numéro confirmé du compte connecté.
  String? get telephone;

  /// Envoie un code par SMS au [telephone].
  Future<void> envoyerCode(String telephone);

  /// Vérifie le [code] reçu ; renvoie l'identifiant du compte.
  Future<String> verifierCode(String telephone, String code);

  Future<void> deconnecter();
}

/// Connexion par SMS avec Supabase Auth. La session est gardée sur le
/// téléphone par supabase_flutter et renouvelée quand il y a du réseau.
class SupabaseAuth implements ServiceAuth {
  SupabaseAuth(this._auth);

  final GoTrueClient _auth;

  @override
  String? get utilisateurId => _auth.currentUser?.id;

  @override
  String? get telephone => _auth.currentUser?.phone;

  @override
  Future<void> envoyerCode(String telephone) => _traduire(
    () => _auth.signInWithOtp(phone: '+$telephone', channel: OtpChannel.sms),
  );

  @override
  Future<String> verifierCode(String telephone, String code) =>
      _traduire(() async {
        final r = await _auth.verifyOTP(
          phone: '+$telephone',
          token: code,
          type: OtpType.sms,
        );
        final id = r.user?.id ?? r.session?.user.id;
        if (id == null) {
          throw const ConnexionImpossible(ErreurConnexion.codeRefuse);
        }
        return id;
      });

  @override
  Future<void> deconnecter() => _auth.signOut();

  static Future<T> _traduire<T>(Future<T> Function() appel) async {
    try {
      return await appel();
    } on ConnexionImpossible {
      rethrow;
    } on AuthRetryableFetchException {
      throw const ConnexionImpossible(ErreurConnexion.reseau);
    } on AuthException catch (e) {
      throw ConnexionImpossible(raisonDe(e.code, e.statusCode));
    } on Exception {
      // SocketException, ClientException… : pas de réseau.
      throw const ConnexionImpossible(ErreurConnexion.reseau);
    }
  }

  /// Traduit un code d'erreur Supabase Auth.
  static ErreurConnexion raisonDe(String? code, String? statut) =>
      switch (code) {
        // « Token has expired or is invalid » : faux ou périmé, même code.
        'otp_expired' || 'invalid_credentials' => ErreurConnexion.codeRefuse,
        'sms_send_failed' => ErreurConnexion.envoiSms,
        'over_sms_send_rate_limit' ||
        'over_request_rate_limit' => ErreurConnexion.tropDeDemandes,
        _ when statut == '429' => ErreurConnexion.tropDeDemandes,
        _ when statut == '403' => ErreurConnexion.codeRefuse,
        _ => ErreurConnexion.autre,
      };
}
