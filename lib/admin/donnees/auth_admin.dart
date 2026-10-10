import 'package:supabase_flutter/supabase_flutter.dart';

/// Pourquoi la connexion au tableau de bord a échoué.
enum ErreurConnexionAdmin {
  /// E-mail ou mot de passe faux.
  identifiants,

  /// Compte valide, mais pas dans la liste des admins.
  pasAdmin,

  /// Trop d'essais : attendre.
  tropDeDemandes,

  /// Pas de réseau ou serveur injoignable.
  reseau,
}

class ConnexionAdminImpossible implements Exception {
  const ConnexionAdminImpossible(this.raison);

  final ErreurConnexionAdmin raison;

  @override
  String toString() => 'ConnexionAdminImpossible($raison)';
}

/// Connexion de l'équipe Kassa par e-mail et mot de passe (Supabase Auth en
/// vrai, un faux en test). Seuls les comptes de la table « admins » entrent.
abstract interface class AuthAdmin {
  /// E-mail du compte admin connecté, ou null.
  String? get email;

  /// Session gardée d'une visite précédente : vrai si elle est encore admin.
  Future<bool> sessionValide();

  /// Connecte ; lève [ConnexionAdminImpossible] (et déconnecte) si le compte
  /// n'est pas admin.
  Future<void> connecter(String email, String motDePasse);

  Future<void> deconnecter();

  /// Se déclenche quand la session se termine sans qu'on l'ait demandé
  /// (jeton révoqué ou expiré).
  Stream<void> get sessionTerminee;
}

class SupabaseAuthAdmin implements AuthAdmin {
  SupabaseAuthAdmin(this._client);

  final SupabaseClient _client;

  @override
  String? get email => _client.auth.currentUser?.email;

  Future<bool> _estAdmin() async =>
      (await _client.rpc('admin_moi')) as bool? ?? false;

  @override
  Future<bool> sessionValide() async {
    if (_client.auth.currentSession == null) return false;
    try {
      if (await _estAdmin()) return true;
    } on Exception {
      return false;
    }
    await _client.auth.signOut();
    return false;
  }

  @override
  Future<void> connecter(String email, String motDePasse) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: motDePasse,
      );
    } on AuthRetryableFetchException {
      throw const ConnexionAdminImpossible(ErreurConnexionAdmin.reseau);
    } on AuthException catch (e) {
      throw ConnexionAdminImpossible(
        e.statusCode == '429'
            ? ErreurConnexionAdmin.tropDeDemandes
            : ErreurConnexionAdmin.identifiants,
      );
    } on Exception {
      throw const ConnexionAdminImpossible(ErreurConnexionAdmin.reseau);
    }
    final bool admin;
    try {
      admin = await _estAdmin();
    } on Exception {
      await _client.auth.signOut();
      throw const ConnexionAdminImpossible(ErreurConnexionAdmin.reseau);
    }
    if (!admin) {
      await _client.auth.signOut();
      throw const ConnexionAdminImpossible(ErreurConnexionAdmin.pasAdmin);
    }
  }

  @override
  Future<void> deconnecter() => _client.auth.signOut();

  @override
  Stream<void> get sessionTerminee => _client.auth.onAuthStateChange
      .where((e) => e.event == AuthChangeEvent.signedOut)
      .map((_) {});
}
