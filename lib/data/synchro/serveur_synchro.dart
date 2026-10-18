/// Repère de téléchargement : la dernière ligne reçue d'une table, dans
/// l'ordre du serveur (heure du serveur, puis identifiant).
class CurseurSynchro {
  const CurseurSynchro({required this.serveurMajLe, required this.id});

  final DateTime serveurMajLe;
  final String id;

  /// Texte gardé dans les préférences (« 2026-10-10T09:00:00.000Z|uuid »).
  String encoder() => '${serveurMajLe.toUtc().toIso8601String()}|$id';

  static CurseurSynchro? decoder(String? texte) {
    if (texte == null) return null;
    final i = texte.indexOf('|');
    if (i < 0) return null;
    final date = DateTime.tryParse(texte.substring(0, i));
    if (date == null) return null;
    return CurseurSynchro(
      serveurMajLe: date.toUtc(),
      id: texte.substring(i + 1),
    );
  }
}

/// Le serveur de sauvegarde vu par la synchronisation (Supabase en vrai,
/// un faux serveur en mémoire dans les tests).
///
/// Les lignes sont des cartes « nom de colonne SQL → valeur JSON » :
/// dates en texte ISO 8601 UTC, booléens, nombres, textes.
abstract interface class ServeurSynchro {
  /// Envoie des lignes (insertion ou mise à jour par id). Le serveur garde
  /// la version au maj_le le plus récent. Lève une exception en cas d'échec
  /// (pas de réseau, refus) : rien n'est alors considéré comme envoyé.
  Future<void> envoyer(String table, List<Map<String, Object?>> lignes);

  /// Lignes de [table] reçues par le serveur après [apres] (toutes si null),
  /// triées par heure du serveur puis par id, au plus [limite].
  /// Chaque ligne contient `serveur_maj_le`.
  Future<List<Map<String, Object?>>> telecharger(
    String table, {
    CurseurSynchro? apres,
    required int limite,
  });

  /// Boutique du compte [utilisateurId] sur le serveur, ou null s'il n'a
  /// pas encore de boutique (nouveau compte).
  Future<String?> boutiqueDe(String utilisateurId);
}

/// Où la synchronisation garde ses repères de téléchargement.
abstract interface class StockageCurseurs {
  String? lire(String table);
  Future<void> ecrire(String table, String curseur);
  Future<void> toutEffacer();

  /// Vrai entre le début et la fin d'une restauration (coupée sinon).
  bool get restaurationEnCours;

  Future<void> marquerRestauration({required bool enCours});
}
