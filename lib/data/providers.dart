import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/kassa_database.dart';

/// Base locale de l'app, ouverte une seule fois et fermée avec l'app.
/// Dans les tests : `kassaDatabaseProvider.overrideWithValue(baseEnMemoire())`.
final kassaDatabaseProvider = Provider<KassaDatabase>((ref) {
  final db = KassaDatabase.ouvrir();
  ref.onDispose(db.close);
  return db;
});
