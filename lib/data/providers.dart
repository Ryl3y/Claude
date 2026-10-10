import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/champs_synchro.dart';
import 'db/kassa_database.dart';
import 'repositories/boutique_repository.dart';
import 'repositories/clients_repository.dart';
import 'repositories/produits_repository.dart';
import 'repositories/rapports_repository.dart';
import 'repositories/ventes_repository.dart';

/// Base locale de l'app, ouverte une seule fois et fermée avec l'app.
/// Dans les tests : `kassaDatabaseProvider.overrideWithValue(baseEnMemoire())`.
final kassaDatabaseProvider = Provider<KassaDatabase>((ref) {
  final db = KassaDatabase.ouvrir();
  ref.onDispose(db.close);
  return db;
});

/// Identifiant de ce téléphone, lu au démarrage (voir main.dart).
final appareilIdProvider = Provider<String>(
  (ref) => throw UnimplementedError('appareilIdProvider non fourni'),
);

final champsSynchroProvider = Provider<ChampsSynchro>(
  (ref) => ChampsSynchro(appareilId: ref.watch(appareilIdProvider)),
);

final produitsRepositoryProvider = Provider<ProduitsRepository>(
  (ref) => ProduitsRepository(
    ref.watch(kassaDatabaseProvider),
    ref.watch(champsSynchroProvider),
  ),
);

final boutiqueRepositoryProvider = Provider<BoutiqueRepository>(
  (ref) => BoutiqueRepository(
    ref.watch(kassaDatabaseProvider),
    ref.watch(champsSynchroProvider),
  ),
);

final clientsRepositoryProvider = Provider<ClientsRepository>(
  (ref) => ClientsRepository(
    ref.watch(kassaDatabaseProvider),
    ref.watch(champsSynchroProvider),
  ),
);

final ventesRepositoryProvider = Provider<VentesRepository>(
  (ref) => VentesRepository(
    ref.watch(kassaDatabaseProvider),
    ref.watch(champsSynchroProvider),
  ),
);

final rapportsRepositoryProvider = Provider<RapportsRepository>(
  (ref) => RapportsRepository(ref.watch(kassaDatabaseProvider)),
);
