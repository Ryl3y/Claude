import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Où l'on garde le jeton de notification de ce téléphone (table
/// jetons_notification sur le serveur).
abstract interface class JetonsNotification {
  Future<void> enregistrer({
    required String utilisateurId,
    required String appareilId,
    required String boutiqueId,
    required String jeton,
    required String langue,
  });
}

class SupabaseJetons implements JetonsNotification {
  SupabaseJetons(this._client);

  final SupabaseClient _client;

  @override
  Future<void> enregistrer({
    required String utilisateurId,
    required String appareilId,
    required String boutiqueId,
    required String jeton,
    required String langue,
  }) => _client.from('jetons_notification').upsert({
    'utilisateur_id': utilisateurId,
    'appareil_id': appareilId,
    'boutique_id': boutiqueId,
    'jeton': jeton,
    'langue': langue,
    'maj_le': DateTime.now().toUtc().toIso8601String(),
  }, onConflict: 'utilisateur_id,appareil_id');
}

/// Inscrit ce téléphone aux notifications : demande l'autorisation
/// (Android 13+), envoie le jeton au serveur, puis chaque nouveau jeton.
/// Un échec (pas de réseau) n'empêche rien : on réessaie au prochain
/// démarrage.
class Notifications {
  Notifications(
    this._jetons, {
    required this._lireJeton,
    required this._renouvellements,
    required this._demanderPermission,
  });

  final JetonsNotification _jetons;
  final Future<String?> Function() _lireJeton;
  final Stream<String> _renouvellements;
  final Future<void> Function() _demanderPermission;
  StreamSubscription<String>? _abonnement;

  Future<void> demarrer({
    required String utilisateurId,
    required String appareilId,
    required String boutiqueId,
    required String langue,
  }) async {
    Future<void> envoyer(String jeton) async {
      try {
        await _jetons.enregistrer(
          utilisateurId: utilisateurId,
          appareilId: appareilId,
          boutiqueId: boutiqueId,
          jeton: jeton,
          langue: langue,
        );
      } on Object {
        // Pas de réseau ou serveur injoignable : prochain démarrage.
      }
    }

    try {
      await _demanderPermission();
      final jeton = await _lireJeton();
      if (jeton != null) await envoyer(jeton);
    } on Object {
      // Services Google absents ou refus : l'app marche sans notifications.
    }
    _abonnement ??= _renouvellements.listen(envoyer);
  }

  Future<void> arreter() async {
    await _abonnement?.cancel();
    _abonnement = null;
  }
}
