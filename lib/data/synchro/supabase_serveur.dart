import 'package:supabase_flutter/supabase_flutter.dart';

import 'serveur_synchro.dart';

/// Le serveur de sauvegarde Supabase. Les droits viennent des règles RLS :
/// l'utilisateur connecté ne lit et n'écrit que sa boutique.
class SupabaseServeur implements ServeurSynchro {
  SupabaseServeur(this._client);

  final SupabaseClient _client;

  @override
  Future<void> envoyer(String table, List<Map<String, Object?>> lignes) async {
    if (lignes.isEmpty) return;
    // Insertion ou mise à jour par id ; le trigger du serveur garde la
    // version au maj_le le plus récent et date l'écriture.
    await _client.from(table).upsert(lignes, onConflict: 'id');
  }

  @override
  Future<List<Map<String, Object?>>> telecharger(
    String table, {
    CurseurSynchro? apres,
    required int limite,
  }) async {
    var requete = _client.from(table).select();
    if (apres != null) {
      final heure = apres.serveurMajLe.toUtc().toIso8601String();
      // Après le repère : heure plus récente, ou même heure et id plus grand.
      requete = requete.or(
        'serveur_maj_le.gt."$heure",'
        'and(serveur_maj_le.eq."$heure",id.gt.${apres.id})',
      );
    }
    final lignes = await requete
        .order('serveur_maj_le', ascending: true)
        .order('id', ascending: true)
        .limit(limite);
    return [for (final l in lignes) Map<String, Object?>.from(l)];
  }

  @override
  Future<String?> boutiqueDe(String utilisateurId) async {
    final ligne = await _client
        .from('utilisateurs')
        .select('boutique_id')
        .eq('id', utilisateurId)
        .isFilter('supprime_le', null)
        .maybeSingle();
    return ligne?['boutique_id'] as String?;
  }
}
