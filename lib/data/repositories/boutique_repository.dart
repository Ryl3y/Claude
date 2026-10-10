import 'package:drift/drift.dart';

import '../../core/identifiant.dart';
import '../db/champs_synchro.dart';
import '../db/kassa_database.dart';
import '../db/tables.dart';
import '../../domain/boutique_saisie.dart';

/// Boutique et utilisateur du téléphone.
///
/// Jusqu'à l'étape 8 (inscription par SMS), l'app crée une boutique et un
/// utilisateur PROVISOIRES au premier lancement, pour que les ventes aient
/// un auteur (ventes.utilisateur_id). L'inscription les remplacera par le
/// compte Supabase. Rien n'est envoyé au serveur avant l'inscription.
class BoutiqueRepository {
  BoutiqueRepository(this._db, this._champs);

  final KassaDatabase _db;
  final ChampsSynchro _champs;

  /// Téléphone fictif des données provisoires (chiffres seulement).
  static const telephoneProvisoire = '000000000';

  /// Renvoie l'utilisateur du téléphone, en le créant s'il n'existe pas.
  Future<Utilisateur> utilisateurCourant() => _db.transaction(() async {
    final existant =
        await (_db.select(_db.utilisateurs)
              ..where((u) => u.supprimeLe.isNull())
              ..limit(1))
            .getSingleOrNull();
    if (existant != null) return existant;

    final instant = _champs.maintenant();
    var boutique =
        await (_db.select(_db.boutiques)
              ..where((b) => b.supprimeLe.isNull())
              ..limit(1))
            .getSingleOrNull();
    if (boutique == null) {
      final id = Identifiant.nouveau();
      await _db
          .into(_db.boutiques)
          .insert(
            BoutiquesCompanion.insert(
              id: id,
              nom: 'Kassa',
              telephone: telephoneProvisoire,
              ville: '',
              quartier: '',
              typeCommerce: '',
              seuilAlerteDefaut: 5,
              creeLe: instant,
              majLe: instant,
              appareilId: _champs.appareilId,
            ),
          );
      boutique = await (_db.select(
        _db.boutiques,
      )..where((b) => b.id.equals(id))).getSingle();
    }
    final id = Identifiant.nouveau();
    await _db
        .into(_db.utilisateurs)
        .insert(
          UtilisateursCompanion.insert(
            id: id,
            boutiqueId: boutique.id,
            nom: '',
            telephone: telephoneProvisoire,
            role: const Value(Role.proprietaire),
            codePin: '',
            majLe: instant,
            appareilId: _champs.appareilId,
          ),
        );
    return (_db.select(
      _db.utilisateurs,
    )..where((u) => u.id.equals(id))).getSingle();
  });

  /// La boutique du téléphone (créée avec l'utilisateur si besoin).
  Future<Boutique> boutiqueCourante() async {
    final utilisateur = await utilisateurCourant();
    return (_db.select(
      _db.boutiques,
    )..where((b) => b.id.equals(utilisateur.boutiqueId))).getSingle();
  }

  /// La boutique [id], en direct (Réglages).
  Stream<Boutique?> surveillerBoutique(String id) => (_db.select(
    _db.boutiques,
  )..where((b) => b.id.equals(id))).watchSingleOrNull();

  /// Modifie le nom, le type, la ville, le quartier et le seuil d'alerte
  /// proposé aux nouveaux produits (Réglages). Textes nettoyés des espaces.
  Future<void> modifierBoutique(
    String id, {
    required BoutiqueSaisie saisie,
    required int seuilAlerteDefaut,
  }) async {
    final nom = saisie.nom.trim();
    final ville = saisie.ville.trim();
    final quartier = saisie.quartier.trim();
    if (nom.isEmpty || ville.isEmpty || quartier.isEmpty) {
      throw ArgumentError('Nom, ville et quartier obligatoires');
    }
    if (seuilAlerteDefaut < 0 || seuilAlerteDefaut > seuilAlerteDefautMax) {
      throw ArgumentError.value(seuilAlerteDefaut, 'seuilAlerteDefaut');
    }
    final lignes =
        await (_db.update(
          _db.boutiques,
        )..where((b) => b.id.equals(id) & b.supprimeLe.isNull())).write(
          BoutiquesCompanion(
            nom: Value(nom),
            typeCommerce: Value(saisie.typeCommerce),
            ville: Value(ville),
            quartier: Value(quartier),
            seuilAlerteDefaut: Value(seuilAlerteDefaut),
            majLe: _champs.majLe,
            synchro: _champs.synchro,
            appareilId: _champs.appareil,
          ),
        );
    if (lignes == 0) throw StateError('Boutique introuvable : $id');
  }

  /// Vrai pour la boutique provisoire (avant l'inscription) : son nom
  /// « Kassa » ne doit pas signer les messages envoyés aux clients.
  static bool estProvisoire(Boutique b) => b.telephone == telephoneProvisoire;
}
