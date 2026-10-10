import 'package:supabase_flutter/supabase_flutter.dart';

/// Abonnement tel que le serveur le connaît.
class AbonnementServeur {
  const AbonnementServeur({required this.formule, required this.dateFin});

  /// « gratuit » (essai) ou « pro ».
  final String formule;

  /// Dernier jour inclus, « 2026-11-09 ».
  final String dateFin;
}

/// Opérateurs Mobile Money acceptés par Notch Pay au Cameroun.
enum Operateur {
  mtn('cm.mtn'),
  orange('cm.orange');

  const Operateur(this.code);

  final String code;
}

enum StatutPaiement { enAttente, reussi, echoue }

/// Pourquoi une demande de paiement n'a pas pu partir.
enum ErreurPaiement {
  /// Une demande est déjà en attente : la valider sur le téléphone.
  demandeEnCours,

  /// Numéro refusé.
  numero,

  /// Pas de réseau ou serveur injoignable.
  reseau,

  /// Notch Pay a refusé ou ne répond pas.
  autre,
}

class PaiementImpossible implements Exception {
  const PaiementImpossible(this.raison);

  final ErreurPaiement raison;

  @override
  String toString() => 'PaiementImpossible($raison)';
}

/// Abonnement Kassa Pro côté serveur (Supabase en vrai, un faux en test).
/// La clé Notch Pay reste sur le serveur (Edge Function abonnement-payer).
abstract interface class ServeurAbonnement {
  /// Abonnement de la boutique ; null s'il n'existe pas encore.
  Future<AbonnementServeur?> lire(String boutiqueId);

  /// Lance un débit Mobile Money de 5 000 FCFA ; renvoie la référence du
  /// paiement. [telephone] : format international, chiffres seulement.
  Future<String> demanderPaiement({
    required Operateur operateur,
    required String telephone,
  });

  Future<StatutPaiement> statut(String reference);
}

class SupabaseAbonnement implements ServeurAbonnement {
  SupabaseAbonnement(this._client);

  final SupabaseClient _client;

  @override
  Future<AbonnementServeur?> lire(String boutiqueId) async {
    final ligne = await _client
        .from('abonnements')
        .select('formule, date_fin')
        .eq('boutique_id', boutiqueId)
        .maybeSingle();
    final fin = ligne?['date_fin'] as String?;
    if (ligne == null || fin == null) return null;
    return AbonnementServeur(formule: ligne['formule'] as String, dateFin: fin);
  }

  @override
  Future<String> demanderPaiement({
    required Operateur operateur,
    required String telephone,
  }) async {
    try {
      final r = await _client.functions.invoke(
        'abonnement-payer',
        body: {'operateur': operateur.code, 'telephone': telephone},
      );
      final corps = r.data;
      final reference = corps is Map ? corps['reference'] : null;
      if (reference is! String) {
        throw const PaiementImpossible(ErreurPaiement.autre);
      }
      return reference;
    } on FunctionException catch (e) {
      throw PaiementImpossible(raisonDe(e.status));
    } on PaiementImpossible {
      rethrow;
    } on Exception {
      throw const PaiementImpossible(ErreurPaiement.reseau);
    }
  }

  /// Traduit le code de réponse de l'Edge Function.
  static ErreurPaiement raisonDe(int statut) => switch (statut) {
    429 => ErreurPaiement.demandeEnCours,
    400 => ErreurPaiement.numero,
    _ => ErreurPaiement.autre,
  };

  @override
  Future<StatutPaiement> statut(String reference) async {
    final ligne = await _client
        .from('paiements_abonnement')
        .select('statut')
        .eq('reference', reference)
        .maybeSingle();
    return switch (ligne?['statut']) {
      'reussi' => StatutPaiement.reussi,
      'echoue' => StatutPaiement.echoue,
      _ => StatutPaiement.enAttente,
    };
  }
}
