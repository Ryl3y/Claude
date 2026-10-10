import 'package:drift/drift.dart';

import '../db/kassa_database.dart';
import 'serveur_synchro.dart';

/// Résultat d'un passage de synchronisation.
class BilanSynchro {
  const BilanSynchro({
    required this.envoyees,
    required this.recues,
    this.erreur,
  });

  final int envoyees;
  final int recues;

  /// Problème rencontré (pas de réseau…) ; null si tout s'est bien passé.
  final Object? erreur;

  bool get reussi => erreur == null;
}

/// Synchronisation maison drift ↔ serveur.
///
/// 1. Envoi : les lignes `synchro = false`, table par table dans l'ordre des
///    dépendances, avec `boutique_id`. Succès → `synchro = true` (si la ligne
///    n'a pas changé pendant l'envoi) ; échec → on réessaie au passage suivant.
/// 2. Téléchargement : les lignes reçues par le serveur depuis le dernier
///    repère (heure du serveur, pas celle du téléphone). Sert aussi à
///    restaurer un nouveau téléphone.
/// 3. Conflits : le `maj_le` le plus récent gagne, sauf `quantite` et
///    `solde_dette`, toujours recalculés sur le téléphone après coup.
class SynchroService {
  SynchroService(
    this._db,
    this._serveur,
    this._curseurs, {
    required this.boutiqueId,
    this.taillePaquet = 500,
  });

  final KassaDatabase _db;
  final ServeurSynchro _serveur;
  final StockageCurseurs _curseurs;

  /// Boutique de ce téléphone, ajoutée à chaque ligne envoyée.
  final String boutiqueId;

  /// Lignes par envoi ou par page téléchargée.
  final int taillePaquet;

  /// Ordre des tables : chaque table après celles dont elle dépend.
  static const ordreTables = [
    'boutiques',
    'utilisateurs',
    'categories',
    'produits',
    'clients',
    'ventes',
    'lignes_vente',
    'versements_dette',
    'mouvements_stock',
  ];

  /// Colonnes propres au téléphone : jamais envoyées, jamais remplacées
  /// (le chemin d'une photo n'a de sens que sur ce téléphone).
  static const colonnesLocales = {'synchro', 'photo_locale'};

  /// Valeurs dérivées : envoyées pour information, mais recalculées sur le
  /// téléphone après chaque téléchargement (jamais reprises du serveur).
  static const colonnesRecalculees = {
    'produits': 'quantite',
    'clients': 'solde_dette',
  };

  Future<BilanSynchro>? _enCours;

  /// Un passage complet (envoi puis téléchargement). Deux appels en même
  /// temps partagent le même passage.
  Future<BilanSynchro> synchroniser() =>
      _enCours ??= _passage().whenComplete(() => _enCours = null);

  /// Nombre de lignes pas encore envoyées.
  Future<int> enAttente() async {
    var total = 0;
    for (final nom in ordreTables) {
      final r = await _db
          .customSelect('SELECT COUNT(*) AS n FROM $nom WHERE synchro = 0')
          .getSingle();
      total += r.read<int>('n');
    }
    return total;
  }

  /// Restauration sur un nouveau téléphone : tout télécharger depuis le
  /// début, sans rien envoyer (les données locales éventuelles partiront au
  /// passage suivant, une fois rattachées à la boutique restaurée).
  /// Lève une exception si le téléchargement échoue.
  Future<int> restaurer() async {
    await _curseurs.toutEffacer();
    final recues = await _telecharger();
    await _db.recalculerTout();
    return recues;
  }

  /// Nombre de lignes pas encore envoyées, mis à jour en direct.
  Stream<int> surveillerEnAttente() => _db
      .customSelect(
        'SELECT ${[for (final t in ordreTables) '(SELECT COUNT(*) FROM $t WHERE synchro = 0)'].join(' + ')} AS n',
        readsFrom: {for (final t in ordreTables) _table(t)},
      )
      .watch()
      .map((l) => l.single.read<int>('n'));

  /// Oublie les repères (nouvelle connexion, autre boutique).
  Future<void> oublierRepere() => _curseurs.toutEffacer();

  Future<BilanSynchro> _passage() async {
    var envoyees = 0;
    var recues = 0;
    try {
      envoyees = await _envoyer();
      recues = await _telecharger();
      if (recues > 0) await _db.recalculerTout();
      return BilanSynchro(envoyees: envoyees, recues: recues);
    } on Object catch (e) {
      // Ce qui est déjà téléchargé reste juste : on recalcule quand même.
      if (recues > 0) await _db.recalculerTout();
      return BilanSynchro(envoyees: envoyees, recues: recues, erreur: e);
    }
  }

  TableInfo<Table, dynamic> _table(String nom) =>
      _db.allTables.firstWhere((t) => t.actualTableName == nom);

  // --- Envoi -----------------------------------------------------------------

  Future<int> _envoyer() async {
    var total = 0;
    for (final nom in ordreTables) {
      final table = _table(nom);
      while (true) {
        final lignes = await _db
            .customSelect(
              'SELECT * FROM $nom WHERE synchro = 0 ORDER BY maj_le LIMIT ?',
              variables: [Variable.withInt(taillePaquet)],
              readsFrom: {table},
            )
            .get();
        if (lignes.isEmpty) break;
        final json = [for (final l in lignes) _versServeur(table, l)];
        // Une table en échec arrête l'envoi : les suivantes en dépendent.
        await _serveur.envoyer(nom, json);
        await _marquerEnvoyees(table, lignes);
        total += lignes.length;
        if (lignes.length < taillePaquet) break;
      }
    }
    return total;
  }

  Map<String, Object?> _versServeur(
    TableInfo<Table, dynamic> table,
    QueryRow l,
  ) {
    final json = <String, Object?>{};
    for (final c in table.$columns) {
      if (colonnesLocales.contains(c.name)) continue;
      json[c.name] = _lireJson(l, c);
    }
    json['boutique_id'] ??= boutiqueId;
    // La boutique est sa propre « boutique » : pas de colonne boutique_id.
    if (table.actualTableName == 'boutiques') json.remove('boutique_id');
    return json;
  }

  Object? _lireJson(QueryRow l, GeneratedColumn c) {
    if (l.data[c.name] == null) return null;
    return switch (c.type) {
      DriftSqlType.dateTime =>
        l.read<DateTime>(c.name).toUtc().toIso8601String(),
      DriftSqlType.bool => l.read<bool>(c.name),
      DriftSqlType.int => l.read<int>(c.name),
      DriftSqlType.double => l.read<double>(c.name),
      _ => l.read<String>(c.name),
    };
  }

  /// Marque envoyées les lignes qui n'ont pas changé pendant l'envoi.
  Future<void> _marquerEnvoyees(
    TableInfo<Table, dynamic> table,
    List<QueryRow> lignes,
  ) => _db.transaction(() async {
    for (final l in lignes) {
      await _db.customUpdate(
        'UPDATE ${table.actualTableName} SET synchro = 1 '
        'WHERE id = ? AND maj_le = ?',
        variables: [
          Variable.withString(l.read<String>('id')),
          Variable.withDateTime(l.read<DateTime>('maj_le')),
        ],
        updates: {table},
      );
    }
  });

  // --- Téléchargement --------------------------------------------------------

  Future<int> _telecharger() async {
    var total = 0;
    for (final nom in ordreTables) {
      final table = _table(nom);
      var curseur = CurseurSynchro.decoder(_curseurs.lire(nom));
      while (true) {
        final lignes = await _serveur.telecharger(
          nom,
          apres: curseur,
          limite: taillePaquet,
        );
        if (lignes.isEmpty) break;
        await _db.transaction(() async {
          for (final l in lignes) {
            await _appliquer(table, l);
          }
        });
        total += lignes.length;
        final derniere = lignes.last;
        curseur = CurseurSynchro(
          serveurMajLe: DateTime.parse(derniere['serveur_maj_le']! as String)
              .toUtc(),
          id: derniere['id']! as String,
        );
        await _curseurs.ecrire(nom, curseur.encoder());
        if (lignes.length < taillePaquet) break;
      }
    }
    return total;
  }

  /// Écrit une ligne du serveur si elle est plus récente que la version
  /// locale, ou si la version locale est déjà envoyée (le serveur a pu
  /// corriger un maj_le venu d'une horloge en avance).
  Future<void> _appliquer(
    TableInfo<Table, dynamic> table,
    Map<String, Object?> distante,
  ) async {
    final nom = table.actualTableName;
    final id = distante['id']! as String;
    final majDistante = DateTime.parse(distante['maj_le']! as String).toUtc();
    final locale = await _db
        .customSelect(
          'SELECT maj_le, synchro FROM $nom WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    if (locale != null &&
        !locale.read<bool>('synchro') &&
        locale.read<DateTime>('maj_le').isAfter(majDistante)) {
      // Changement local plus récent, pas encore envoyé : il gagnera.
      return;
    }

    final colonnes = <String>[];
    final valeurs = <Variable>[];
    for (final c in table.$columns) {
      if (colonnesLocales.contains(c.name)) continue;
      if (!distante.containsKey(c.name)) continue;
      colonnes.add(c.name);
      valeurs.add(_variable(c, distante[c.name]));
    }
    final recalculee = colonnesRecalculees[nom];
    final misesAJour = [
      for (final c in colonnes)
        if (c != 'id' && c != recalculee) '$c = excluded.$c',
      'synchro = 1',
    ];
    await _db.customInsert(
      'INSERT INTO $nom (${[...colonnes, 'synchro'].join(', ')}) '
      'VALUES (${List.filled(colonnes.length, '?').join(', ')}, 1) '
      'ON CONFLICT(id) DO UPDATE SET ${misesAJour.join(', ')}',
      variables: valeurs,
      updates: {table},
    );
  }

  Variable _variable(GeneratedColumn c, Object? valeur) {
    if (valeur == null) return const Variable(null);
    return switch (c.type) {
      DriftSqlType.dateTime => Variable.withDateTime(
        DateTime.parse(valeur as String).toUtc(),
      ),
      DriftSqlType.bool => Variable.withBool(valeur as bool),
      DriftSqlType.int => Variable.withInt((valeur as num).toInt()),
      DriftSqlType.double => Variable.withReal((valeur as num).toDouble()),
      _ => Variable.withString(valeur.toString()),
    };
  }
}
