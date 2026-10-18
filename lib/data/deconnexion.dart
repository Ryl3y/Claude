import 'auth/service_auth.dart';
import 'db/kassa_database.dart';
import 'photos_produits.dart';
import 'preferences/preferences_locales.dart';
import 'synchro/synchro_service.dart';

/// Déconnexion : le téléphone redevient vierge. Les données déjà
/// sauvegardées restent sur le serveur et reviennent à la prochaine
/// connexion ; celles qui ne l'étaient pas sont perdues (l'écran prévient).
class Deconnexion {
  Deconnexion({
    required this._db,
    required this._prefs,
    this._auth,
    this._effacerPhoto = PhotosProduits.effacer,
  });

  final KassaDatabase _db;
  final PreferencesLocales _prefs;
  final ServiceAuth? _auth;
  final Future<void> Function(String? chemin) _effacerPhoto;

  Future<void> deconnecter() async {
    // D'abord la session du serveur : sans réseau, supabase_flutter
    // l'oublie quand même sur le téléphone.
    try {
      await _auth?.deconnecter();
    } on Exception {
      // Le jeton expirera seul ; le téléphone est vidé quand même.
    }
    final photos =
        await (_db.selectOnly(_db.produits)
              ..addColumns([_db.produits.photoLocale])
              ..where(_db.produits.photoLocale.isNotNull()))
            .map((r) => r.read(_db.produits.photoLocale))
            .get();
    await _db.transaction(() async {
      // Chaque table avant celles dont elle dépend.
      for (final table in SynchroService.ordreTables.reversed) {
        await _db.customStatement('DELETE FROM $table');
      }
    });
    await _prefs.oublierCompte();
    for (final p in photos) {
      try {
        await _effacerPhoto(p);
      } on Object {
        // Une photo restée sur le disque ne bloque pas la déconnexion.
      }
    }
  }
}
