import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/lieux.dart';

/// Pourquoi un ajout de lieu a été refusé.
enum RefusLieu { nomInvalide, tropDAjouts, reseau }

class LieuRefuse implements Exception {
  const LieuRefuse(this.raison, {this.surQuartier = false});
  final RefusLieu raison;

  /// Vrai si c'est le quartier qui est refusé (pas la ville ou le village).
  final bool surQuartier;

  @override
  String toString() => 'LieuRefuse($raison, quartier: $surQuartier)';
}

/// Listes partagées des villes, villages et quartiers (Supabase en vrai,
/// un faux en test). Un ajout est visible tout de suite par tous.
abstract interface class ServiceLieux {
  /// Villes et villages d'un arrondissement, par ordre alphabétique.
  Future<List<Lieu>> localites(String arrondissement);

  /// Quartiers d'une ville ou d'un village.
  Future<List<Lieu>> quartiers(String localiteId);

  /// Ajoute (ou retrouve, même nom sans accents ni majuscules) un village.
  Future<Lieu> ajouterLocalite(String arrondissement, String nom);

  /// Ajoute (ou retrouve) un quartier.
  Future<Lieu> ajouterQuartier(String localiteId, String nom);
}

class SupabaseLieux implements ServiceLieux {
  SupabaseLieux(this._client);

  final SupabaseClient _client;

  Future<List<Lieu>> _appel(
    String fonction,
    Map<String, Object?> params,
  ) async {
    try {
      final r = await _client.rpc(fonction, params: params);
      return [
        for (final l in (r as List? ?? const []).cast<Map>())
          Lieu(l['id'] as String, l['nom'] as String),
      ];
    } on PostgrestException catch (e) {
      throw LieuRefuse(switch (e.message) {
        'trop_d_ajouts' => RefusLieu.tropDAjouts,
        'nom_invalide' => RefusLieu.nomInvalide,
        _ => RefusLieu.reseau,
      });
    } on Exception {
      throw const LieuRefuse(RefusLieu.reseau);
    }
  }

  @override
  Future<List<Lieu>> localites(String arrondissement) =>
      _appel('lieux_localites', {'p_arrondissement': arrondissement});

  @override
  Future<List<Lieu>> quartiers(String localiteId) =>
      _appel('lieux_quartiers', {'p_localite_id': localiteId});

  @override
  Future<Lieu> ajouterLocalite(String arrondissement, String nom) async =>
      (await _appel('lieux_ajouter_localite', {
        'p_arrondissement': arrondissement,
        'p_nom': nom,
      })).first;

  @override
  Future<Lieu> ajouterQuartier(String localiteId, String nom) async =>
      (await _appel('lieux_ajouter_quartier', {
        'p_localite_id': localiteId,
        'p_nom': nom,
      })).first;
}

/// Enregistre dans les listes partagées les noms nouveaux du lieu choisi,
/// puis renvoie le lieu avec ses identifiants. Sans serveur ou sans réseau,
/// les noms sont gardés tels quels (identifiants vides) : la boutique se
/// crée quand même. Lève [LieuRefuse] pour un nom refusé (trop d'ajouts,
/// nom invalide) : la saisie est à corriger.
Future<LieuChoisi> enregistrerLieu(
  ServiceLieux? service,
  LieuChoisi lieu,
) async {
  final arrondissement = lieu.arrondissement;
  var localite = lieu.localite;
  var quartier = lieu.quartier;
  if (service == null || arrondissement == null || localite == null) {
    return lieu;
  }
  try {
    if (localite.id == null) {
      localite = await service.ajouterLocalite(
        arrondissement,
        nomLieu(localite.nom),
      );
    }
    if (quartier != null && quartier.id == null) {
      try {
        quartier = await service.ajouterQuartier(
          localite.id!,
          nomLieu(quartier.nom),
        );
      } on LieuRefuse catch (e) {
        throw LieuRefuse(e.raison, surQuartier: true);
      }
    }
  } on LieuRefuse catch (e) {
    if (e.raison != RefusLieu.reseau) rethrow;
    // Hors ligne : on garde les noms ; ils pourront être ajoutés plus tard
    // depuis Réglages.
  }
  return LieuChoisi(
    region: lieu.region,
    departement: lieu.departement,
    arrondissement: arrondissement,
    localite: localite,
    quartier: quartier,
  );
}
