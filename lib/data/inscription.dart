import 'auth/service_auth.dart';
import 'db/kassa_database.dart';
import 'repositories/compte_repository.dart';
import 'synchro/serveur_synchro.dart';
import 'synchro/synchro_service.dart';

/// Ce qui suit la connexion par SMS.
enum SuiteConnexion {
  /// Nouveau compte : créer la boutique (écran 3).
  creerBoutique,

  /// Compte connu (ce téléphone ou restauré) : demander le code PIN.
  codePin,
}

/// Ce téléphone a déjà le compte d'un autre numéro.
class AutreCompteSurCeTelephone implements Exception {
  const AutreCompteSurCeTelephone();
}

/// Les étapes de l'inscription et de la restauration (écrans 1 à 4).
class Inscription {
  Inscription({
    required this._auth,
    required this._serveur,
    required this._comptes,
    required this._synchroPour,
  });

  final ServiceAuth _auth;
  final ServeurSynchro _serveur;
  final CompteRepository _comptes;
  final SynchroService Function(String boutiqueId) _synchroPour;

  /// Après un code SMS correct : compte déjà sur ce téléphone, compte à
  /// restaurer depuis le serveur, ou boutique à créer.
  Future<SuiteConnexion> apresConnexion(String utilisateurId) async {
    final local = await _comptes.compteLocal();
    if (local != null) {
      if (local.id != utilisateurId) {
        // Un seul compte par téléphone (déconnexion : étape 9, Réglages).
        await _auth.deconnecter();
        throw const AutreCompteSurCeTelephone();
      }
      return SuiteConnexion.codePin;
    }
    final boutiqueId = await _serveur.boutiqueDe(utilisateurId);
    if (boutiqueId == null) return SuiteConnexion.creerBoutique;

    // Nouveau téléphone : tout revient du serveur, code PIN compris.
    await _synchroPour(boutiqueId).restaurer();
    await _comptes.adopterDonneesProvisoires(utilisateurId);
    return SuiteConnexion.codePin;
  }

  /// Crée la boutique du compte connecté.
  Future<Utilisateur> creerBoutique(BoutiqueSaisie saisie, String pin) async {
    final id = _auth.utilisateurId;
    final telephone = _auth.telephone;
    if (id == null || telephone == null) {
      throw StateError('Pas de compte connecté');
    }
    await _comptes.creerBoutique(
      utilisateurId: id,
      telephone: telephone,
      saisie: saisie,
      pin: pin,
    );
    return (await _comptes.compteLocal())!;
  }
}
