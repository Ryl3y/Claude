import 'package:kassa/data/synchro/serveur_synchro.dart';

/// Serveur en mémoire qui suit les règles du vrai (trigger
/// private.horodater_ecriture) : maj_le futur ramené à l'heure du serveur,
/// version plus ancienne ignorée, serveur_maj_le = heure du serveur.
class FauxServeur implements ServeurSynchro {
  /// L'horloge du serveur part de midi, après les écritures des tests
  /// (faites entre 9 h et 11 h, heure UTC des téléphones).
  FauxServeur({DateTime? debut})
    : _heure = debut ?? DateTime.utc(2026, 10, 10, 12);

  /// Tables → id → ligne.
  final Map<String, Map<String, Map<String, Object?>>> tables = {};

  /// Simule une coupure réseau : chaque appel échoue.
  bool horsLigne = false;

  /// Fait échouer l'envoi de cette table seulement.
  String? tableEnEchec;

  /// Nombre d'appels d'envoi reçus.
  int envois = 0;

  DateTime _heure;

  /// Heure du serveur : avance d'une milliseconde à chaque écriture.
  DateTime get heure => _heure;

  void avancer(Duration d) => _heure = _heure.add(d);

  @override
  Future<void> envoyer(String table, List<Map<String, Object?>> lignes) async {
    if (horsLigne) throw const FormatException('pas de réseau');
    if (table == tableEnEchec) throw StateError('refus du serveur');
    envois++;
    final t = tables.putIfAbsent(table, () => {});
    for (final l in lignes) {
      _heure = _heure.add(const Duration(milliseconds: 1));
      final nouvelle = {...l};
      var maj = DateTime.parse(nouvelle['maj_le']! as String);
      if (maj.isAfter(_heure.add(const Duration(minutes: 5)))) {
        maj = _heure;
        nouvelle['maj_le'] = maj.toIso8601String();
      }
      final ancienne = t[nouvelle['id']];
      if (ancienne != null &&
          maj.isBefore(DateTime.parse(ancienne['maj_le']! as String))) {
        continue; // version plus ancienne : ignorée
      }
      nouvelle['serveur_maj_le'] = _heure.toIso8601String();
      t[nouvelle['id']! as String] = nouvelle;
    }
  }

  @override
  Future<List<Map<String, Object?>>> telecharger(
    String table, {
    CurseurSynchro? apres,
    required int limite,
  }) async {
    if (horsLigne) throw const FormatException('pas de réseau');
    final lignes = [...(tables[table] ?? {}).values]
      ..sort((a, b) {
        final c = (a['serveur_maj_le']! as String).compareTo(
          b['serveur_maj_le']! as String,
        );
        return c != 0 ? c : (a['id']! as String).compareTo(b['id']! as String);
      });
    return [
      for (final l in lignes)
        if (apres == null || _apres(l, apres)) {...l},
    ].take(limite).toList();
  }

  @override
  Future<String?> boutiqueDe(String utilisateurId) async {
    if (horsLigne) throw const FormatException('pas de réseau');
    final u = tables['utilisateurs']?[utilisateurId];
    return u == null || u['supprime_le'] != null
        ? null
        : u['boutique_id'] as String?;
  }

  bool _apres(Map<String, Object?> l, CurseurSynchro c) {
    final s = DateTime.parse(l['serveur_maj_le']! as String);
    if (s.isAfter(c.serveurMajLe)) return true;
    return s.isAtSameMomentAs(c.serveurMajLe) &&
        (l['id']! as String).compareTo(c.id) > 0;
  }

  /// Modifie une ligne comme le ferait un autre téléphone.
  void ecrireDepuisAutreTelephone(
    String table,
    String id,
    Map<String, Object?> changements,
  ) {
    _heure = _heure.add(const Duration(milliseconds: 1));
    final l = tables[table]![id]!;
    l.addAll(changements);
    l['serveur_maj_le'] = _heure.toIso8601String();
  }
}

/// Repères gardés en mémoire.
class FauxCurseurs implements StockageCurseurs {
  final Map<String, String> valeurs = {};

  @override
  String? lire(String table) => valeurs[table];

  @override
  Future<void> ecrire(String table, String curseur) async =>
      valeurs[table] = curseur;

  @override
  Future<void> toutEffacer() async => valeurs.clear();
}
