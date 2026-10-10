import 'package:drift/drift.dart';

import '../../core/identifiant.dart';
import '../db/champs_synchro.dart';
import '../db/kassa_database.dart';

/// Clients (étape 5 : choix et création rapide pour une vente à crédit ;
/// les écrans Clients arrivent à l'étape 6).
class ClientsRepository {
  ClientsRepository(this._db, this._champs);

  final KassaDatabase _db;
  final ChampsSynchro _champs;

  /// Clients non supprimés, plus grosse dette d'abord, puis par nom.
  Stream<List<Client>> surveillerClients() =>
      (_db.select(_db.clients)
            ..where((c) => c.supprimeLe.isNull())
            ..orderBy([
              (c) => OrderingTerm.desc(c.soldeDette),
              (c) => OrderingTerm.asc(c.nom.collate(Collate.noCase)),
            ]))
          .watch();

  /// Crée un client (nom obligatoire, téléphone facultatif).
  Future<String> creerClient({required String nom, String? telephone}) async {
    final propre = nom.trim();
    if (propre.isEmpty) throw ArgumentError.value(nom, 'nom', 'vide');
    final tel = telephone?.trim();
    final id = Identifiant.nouveau();
    await _db
        .into(_db.clients)
        .insert(
          ClientsCompanion.insert(
            id: id,
            nom: propre,
            telephone: Value(tel == null || tel.isEmpty ? null : tel),
            majLe: _champs.maintenant(),
            appareilId: _champs.appareilId,
          ),
        );
    return id;
  }
}
