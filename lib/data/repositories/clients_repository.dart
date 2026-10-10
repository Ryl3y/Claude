import 'package:drift/drift.dart';

import '../../core/identifiant.dart';
import '../../domain/client_saisie.dart';
import '../../domain/panier.dart';
import '../db/champs_synchro.dart';
import '../db/kassa_database.dart';
import 'ventes_repository.dart';

/// Un client dans la liste, avec la date de son dernier achat.
class ClientResume {
  const ClientResume({required this.client, this.dernierAchat});

  final Client client;

  /// Date (UTC) de sa dernière vente, annulées comprises ; null s'il n'a
  /// jamais acheté.
  final DateTime? dernierAchat;
}

/// Une ligne de l'historique d'un client : un achat ou un versement.
sealed class OperationClient {
  const OperationClient();

  DateTime get date;
}

class AchatClient extends OperationClient {
  const AchatClient(this.vente);

  final Vente vente;

  @override
  DateTime get date => vente.dateVente;
}

class VersementClient extends OperationClient {
  const VersementClient(this.versement);

  final VersementDette versement;

  @override
  DateTime get date => versement.dateVersement;
}

/// Saisie refusée (nom vide, téléphone invalide).
class ClientInvalide implements Exception {
  const ClientInvalide(this.erreurs);

  final Set<ErreurClient> erreurs;
}

/// Versement plus grand que la dette : refusé.
class VersementTropGrand implements Exception {
  const VersementTropGrand(this.soldeDette);

  /// Ce que le client doit vraiment.
  final int soldeDette;
}

/// Suppression refusée : le client doit encore de l'argent.
class ClientEndette implements Exception {
  const ClientEndette(this.soldeDette);

  final int soldeDette;
}

/// Clients, dettes et versements.
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

  /// Même liste, avec la date du dernier achat de chacun (écran 12).
  Stream<List<ClientResume>> surveillerResumes() {
    final dernierAchat = _db.ventes.dateVente.max();
    final achats = _db.selectOnly(_db.ventes)
      ..addColumns([_db.ventes.clientId, dernierAchat])
      ..where(_db.ventes.clientId.isNotNull() & _db.ventes.supprimeLe.isNull())
      ..groupBy([_db.ventes.clientId]);
    // Deux requêtes simples, relancées dès que clients ou ventes changent.
    return _db
        .customSelect('SELECT 1', readsFrom: {_db.clients, _db.ventes})
        .watch()
        .asyncMap((_) async {
          final dates = {
            for (final r in await achats.get())
              r.read(_db.ventes.clientId)!: r.read(dernierAchat),
          };
          final clients = await surveillerClients().first;
          return [
            for (final c in clients)
              ClientResume(client: c, dernierAchat: dates[c.id]),
          ];
        });
  }

  /// Un client (null s'il n'existe pas ou a été supprimé).
  Stream<Client?> surveillerClient(String id) => (_db.select(
    _db.clients,
  )..where((c) => c.id.equals(id) & c.supprimeLe.isNull())).watchSingleOrNull();

  /// Achats et versements du client, les plus récents d'abord.
  Stream<List<OperationClient>> surveillerHistorique(String clientId) => _db
      .customSelect('SELECT 1', readsFrom: {_db.ventes, _db.versementsDette})
      .watch()
      .asyncMap((_) async {
        final ventes =
            await (_db.select(_db.ventes)..where(
                  (v) => v.clientId.equals(clientId) & v.supprimeLe.isNull(),
                ))
                .get();
        final versements =
            await (_db.select(_db.versementsDette)..where(
                  (v) => v.clientId.equals(clientId) & v.supprimeLe.isNull(),
                ))
                .get();
        return <OperationClient>[
          ...ventes.map(AchatClient.new),
          ...versements.map(VersementClient.new),
        ]..sort((a, b) => b.date.compareTo(a.date));
      });

  /// Crée un client (nom obligatoire, téléphone et note facultatifs).
  Future<String> creerClient({
    required String nom,
    String? telephone,
    String? note,
  }) async {
    final s = ClientSaisie(nom: nom, telephone: telephone, note: note);
    final erreurs = ReglesClient.verifier(s);
    if (erreurs.isNotEmpty) throw ClientInvalide(erreurs);
    final id = Identifiant.nouveau();
    await _db
        .into(_db.clients)
        .insert(
          ClientsCompanion.insert(
            id: id,
            nom: s.nomPropre,
            telephone: Value(s.telephonePropre),
            note: Value(s.notePropre),
            majLe: _champs.maintenant(),
            appareilId: _champs.appareilId,
          ),
        );
    return id;
  }

  /// Modifie le nom, le téléphone et la note (jamais le solde, recalculé).
  Future<void> modifierClient(String id, ClientSaisie s) async {
    final erreurs = ReglesClient.verifier(s);
    if (erreurs.isNotEmpty) throw ClientInvalide(erreurs);
    final lignes =
        await (_db.update(
          _db.clients,
        )..where((c) => c.id.equals(id) & c.supprimeLe.isNull())).write(
          ClientsCompanion(
            nom: Value(s.nomPropre),
            telephone: Value(s.telephonePropre),
            note: Value(s.notePropre),
            majLe: _champs.majLe,
            synchro: _champs.synchro,
            appareilId: _champs.appareil,
          ),
        );
    if (lignes == 0) throw StateError('Client introuvable : $id');
  }

  /// Suppression logique. Refusée tant que le client doit de l'argent :
  /// sa dette disparaîtrait des « Dettes à recevoir ».
  Future<void> supprimerClient(String id) => _db.transaction(() async {
    final client = await _client(id);
    final solde = await _db.calculerSoldeDette(id);
    if (solde > 0) throw ClientEndette(solde);
    final s = _champs.suppression();
    await (_db.update(_db.clients)..where((c) => c.id.equals(client.id))).write(
      ClientsCompanion(
        majLe: s.majLe,
        supprimeLe: s.supprimeLe,
        synchro: _champs.synchro,
        appareilId: _champs.appareil,
      ),
    );
  });

  /// Enregistre un versement sur la dette du client et recalcule son solde,
  /// en une seule transaction. Mode : espèces, MoMo ou Orange Money.
  /// Montant entre 1 et la dette ([VersementTropGrand] au-delà).
  /// Renvoie le versement et la dette qui reste.
  Future<({VersementDette versement, int reste})> enregistrerVersement({
    required String clientId,
    required int montant,
    required ModeChoisi mode,
  }) {
    if (mode == ModeChoisi.credit) {
      throw ArgumentError.value(mode, 'mode', 'pas de versement à crédit');
    }
    if (montant <= 0) throw ArgumentError.value(montant, 'montant');
    return _db.transaction(() async {
      await _client(clientId);
      final solde = await _db.calculerSoldeDette(clientId);
      if (montant > solde) throw VersementTropGrand(solde);
      final instant = _champs.maintenant();
      final id = Identifiant.nouveau();
      await _db
          .into(_db.versementsDette)
          .insert(
            VersementsDetteCompanion.insert(
              id: id,
              clientId: clientId,
              montant: montant,
              modePaiement: VentesRepository.codeMode(mode),
              dateVersement: instant,
              majLe: instant,
              appareilId: _champs.appareilId,
            ),
          );
      final reste = await _db.recalculerSoldeDette(clientId);
      final versement = await (_db.select(
        _db.versementsDette,
      )..where((v) => v.id.equals(id))).getSingle();
      return (versement: versement, reste: reste);
    });
  }

  Future<Client> _client(String id) async {
    final client = await (_db.select(
      _db.clients,
    )..where((c) => c.id.equals(id) & c.supprimeLe.isNull())).getSingleOrNull();
    if (client == null) throw StateError('Client introuvable : $id');
    return client;
  }
}
