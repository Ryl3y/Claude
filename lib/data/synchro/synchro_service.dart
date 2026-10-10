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

  /// Marge du téléchargement : on relit les lignes reçues par le serveur
  /// pendant les dernières minutes avant le repère.
  static const margeTelechargement = Duration(minutes: 2);

  /// Téléphone des données provisoires (voir BoutiqueRepository).
  static const telephoneProvisoire = '000000000';

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
    // Repère « restauration en cours » : si elle est coupée (réseau), l'app
    // le voit au prochain démarrage et la recommence depuis le début.
    await _curseurs.marquerRestauration(enCours: true);
    await _curseurs.toutEffacer();
    final compteur = _Compteur();
    await _telecharger(compteur);
    await _db.recalculerTout();
    await _curseurs.marquerRestauration(enCours: false);
    return compteur.recues;
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
    final compteur = _Compteur();
    Object? erreur;
    try {
      await _envoyer(compteur);
    } on Object catch (e) {
      // Un envoi refusé n'empêche pas de recevoir les changements des autres
      // téléphones : le téléchargement ne dépend pas de l'envoi.
      erreur = e;
    }
    try {
      await _telecharger(compteur);
    } on Object catch (e) {
      erreur ??= e;
    }
    // Ce qui est déjà téléchargé reste juste, même après une erreur.
    if (compteur.recues > 0) await _db.recalculerTout();
    return BilanSynchro(
      envoyees: compteur.envoyees,
      recues: compteur.recues,
      erreur: erreur,
    );
  }

  TableInfo<Table, dynamic> _table(String nom) =>
      _db.allTables.firstWhere((t) => t.actualTableName == nom);

  // --- Envoi -----------------------------------------------------------------

  Future<void> _envoyer(_Compteur compteur) async {
    for (final nom in ordreTables) {
      final table = _table(nom);
      while (true) {
        // Les données provisoires (avant l'inscription) ne partent jamais :
        // le serveur les refuserait et bloquerait tout l'envoi.
        final provisoire = switch (nom) {
          'boutiques' ||
          'utilisateurs' => "AND telephone <> '$telephoneProvisoire' ",
          _ => '',
        };
        final lignes = await _db
            .customSelect(
              'SELECT * FROM $nom WHERE synchro = 0 $provisoire'
              'ORDER BY maj_le LIMIT ?',
              variables: [Variable.withInt(taillePaquet)],
              readsFrom: {table},
            )
            .get();
        if (lignes.isEmpty) break;
        final json = [for (final l in lignes) _versServeur(table, l)];
        // Une table en échec arrête l'envoi : les suivantes en dépendent.
        await _serveur.envoyer(nom, json);
        await _marquerEnvoyees(table, lignes);
        compteur.envoyees += lignes.length;
        if (lignes.length < taillePaquet) break;
      }
    }
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

  Future<void> _telecharger(_Compteur compteur) async {
    for (final nom in ordreTables) {
      final table = _table(nom);
      final repere = CurseurSynchro.decoder(_curseurs.lire(nom));
      // On repart un peu avant le repère : l'heure du serveur est celle du
      // début de la transaction, et une écriture plus longue peut être
      // validée après une plus récente. Les lignes déjà connues sont
      // simplement ignorées.
      var curseur = repere == null
          ? null
          : CurseurSynchro(
              serveurMajLe: repere.serveurMajLe.subtract(margeTelechargement),
              id: '',
            );
      while (true) {
        final lignes = await _serveur.telecharger(
          nom,
          apres: curseur,
          limite: taillePaquet,
        );
        if (lignes.isEmpty) break;
        await _db.transaction(() async {
          for (final l in lignes) {
            if (await _appliquer(table, l)) compteur.recues++;
          }
        });
        final derniere = lignes.last;
        curseur = CurseurSynchro(
          serveurMajLe: DateTime.parse(derniere['serveur_maj_le']! as String)
              .toUtc(),
          id: derniere['id']! as String,
        );
        // Le repère n'avance jamais en arrière (pages de la marge).
        if (repere == null || _apres(curseur, repere)) {
          await _curseurs.ecrire(nom, curseur.encoder());
        }
        if (lignes.length < taillePaquet) break;
      }
    }
  }

  static bool _apres(CurseurSynchro a, CurseurSynchro b) =>
      a.serveurMajLe.isAfter(b.serveurMajLe) ||
      (a.serveurMajLe.isAtSameMomentAs(b.serveurMajLe) &&
          a.id.compareTo(b.id) > 0);

  /// Écrit une ligne du serveur si elle est plus récente que la version
  /// locale, ou si la version locale est déjà envoyée (le serveur a pu
  /// corriger un maj_le venu d'une horloge en avance). Renvoie vrai si la
  /// ligne a changé quelque chose.
  Future<bool> _appliquer(
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
    if (locale != null) {
      final majLocale = locale.read<DateTime>('maj_le');
      final envoyee = locale.read<bool>('synchro');
      // Changement local plus récent, pas encore envoyé : il gagnera.
      if (!envoyee && majLocale.isAfter(majDistante)) return false;
      // Déjà la même version (ligne revue grâce à la marge) : rien à faire.
      if (envoyee && majLocale.isAtSameMomentAs(majDistante)) return false;
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
    return true;
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

class _Compteur {
  int envoyees = 0;
  int recues = 0;
}
