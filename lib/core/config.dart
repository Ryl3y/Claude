/// Réglages de connexion au serveur, donnés au moment de la compilation :
///
/// ```sh
/// flutter run --dart-define-from-file=config/kassa.json
/// ```
///
/// `config/kassa.json` n'est pas dans le dépôt (voir
/// `config/kassa.exemple.json`) : aucune clé dans le code.
abstract final class ConfigServeur {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Clé publiable (sb_publishable_…) : faite pour être dans l'app, les
  /// règles RLS protègent les données. Jamais la clé secrète.
  static const supabaseClePubliable = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Sans réglages (tests, démonstration), l'app marche sans serveur.
  static bool get serveurConfigure =>
      supabaseUrl.isNotEmpty && supabaseClePubliable.isNotEmpty;
}
