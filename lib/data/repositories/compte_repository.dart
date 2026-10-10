import 'package:drift/drift.dart';

import '../../core/identifiant.dart';
import '../../domain/code_pin.dart';
import '../db/champs_synchro.dart';
import '../db/kassa_database.dart';
import '../db/tables.dart';
import 'boutique_repository.dart';

/// Ce qu'on saisit pour créer sa boutique (écran 3).
class BoutiqueSaisie {
  const BoutiqueSaisie({
    required this.nom,
    required this.typeCommerce,
    required this.ville,
    required this.quartier,
  });

  final String nom;
  final String typeCommerce;
  final String ville;
  final String quartier;
}

/// Le compte du propriétaire sur ce téléphone : création de la boutique,
/// reprise des données saisies avant l'inscription, code PIN.
class CompteRepository {
  CompteRepository(this._db, this._champs);

  final KassaDatabase _db;
  final ChampsSynchro _champs;

  /// Le compte de ce téléphone (utilisateur avec un code PIN), même sans
  /// réseau ni session : l'app doit s'ouvrir hors ligne.
  Future<Utilisateur?> compteLocal() =>
      (_db.select(_db.utilisateurs)
            ..where(
              (u) =>
                  u.supprimeLe.isNull() &
                  u.codePin.equals('').not() &
                  u.telephone
                      .equals(BoutiqueRepository.telephoneProvisoire)
                      .not(),
            )
            ..limit(1))
          .getSingleOrNull();

  /// Crée la boutique et le compte [utilisateurId] (numéro [telephone]
  /// confirmé par SMS). Les données saisies avant l'inscription (boutique
  /// et vendeur provisoires de l'étape 5) sont reprises : la boutique
  /// provisoire devient la vraie, ses ventes passent au nouveau compte.
  Future<String> creerBoutique({
    required String utilisateurId,
    required String telephone,
    required BoutiqueSaisie saisie,
    required String pin,
  }) {
    if (!CodePin.estValide(pin)) throw ArgumentError.value(pin, 'pin');
    if (saisie.nom.trim().isEmpty) throw ArgumentError.value(saisie.nom);
    final empreinte = CodePin.hacher(pin);
    return _db.transaction(() async {
      final instant = _champs.maintenant();
      final provisoire = await _boutiqueProvisoire();
      final boutiqueId = provisoire?.id ?? Identifiant.nouveau();
      final valeurs = BoutiquesCompanion(
        nom: Value(saisie.nom.trim()),
        telephone: Value(telephone),
        ville: Value(saisie.ville.trim()),
        quartier: Value(saisie.quartier.trim()),
        typeCommerce: Value(saisie.typeCommerce),
        majLe: Value(instant),
        synchro: const Value(false),
        appareilId: Value(_champs.appareilId),
      );
      if (provisoire != null) {
        await (_db.update(
          _db.boutiques,
        )..where((b) => b.id.equals(boutiqueId))).write(valeurs);
      } else {
        await _db
            .into(_db.boutiques)
            .insert(
              valeurs.copyWith(
                id: Value(boutiqueId),
                seuilAlerteDefaut: const Value(5),
                creeLe: Value(instant),
              ),
            );
      }
      await _db
          .into(_db.utilisateurs)
          .insert(
            UtilisateursCompanion.insert(
              id: utilisateurId,
              boutiqueId: boutiqueId,
              nom: '',
              telephone: telephone,
              role: const Value(Role.proprietaire),
              codePin: empreinte,
              majLe: instant,
              appareilId: _champs.appareilId,
            ),
          );
      await _reprendreVentes(utilisateurId);
      return boutiqueId;
    });
  }

  /// Après la restauration d'un compte existant : les ventes faites avant
  /// l'inscription passent à ce compte et la boutique provisoire disparaît
  /// (elle n'a jamais été envoyée). Ses autres données (produits, clients…)
  /// n'ont pas de boutique sur le téléphone : elles partent avec la boutique
  /// restaurée au prochain envoi.
  Future<void> adopterDonneesProvisoires(String utilisateurId) =>
      _db.transaction(() async {
        await _reprendreVentes(utilisateurId);
        final provisoire = await _boutiqueProvisoire();
        if (provisoire != null) {
          await (_db.delete(
            _db.boutiques,
          )..where((b) => b.id.equals(provisoire.id))).go();
        }
      });

  /// Remplace le code PIN (après « Code oublié »).
  Future<void> changerPin(String utilisateurId, String pin) async {
    if (!CodePin.estValide(pin)) throw ArgumentError.value(pin, 'pin');
    final lignes =
        await (_db.update(
          _db.utilisateurs,
        )..where((u) => u.id.equals(utilisateurId))).write(
          UtilisateursCompanion(
            codePin: Value(CodePin.hacher(pin)),
            majLe: _champs.majLe,
            synchro: _champs.synchro,
            appareilId: _champs.appareil,
          ),
        );
    if (lignes == 0) throw StateError('Compte introuvable : $utilisateurId');
  }

  /// Vrai si [pin] est le code du compte de ce téléphone.
  Future<bool> verifierPin(String pin) async {
    final compte = await compteLocal();
    return compte != null && CodePin.verifier(pin, compte.codePin);
  }

  Future<Boutique?> _boutiqueProvisoire() =>
      (_db.select(_db.boutiques)..where(
            (b) => b.telephone.equals(BoutiqueRepository.telephoneProvisoire),
          ))
          .getSingleOrNull();

  /// Les ventes du vendeur provisoire passent au compte, puis le vendeur
  /// provisoire (jamais envoyé au serveur) est retiré.
  Future<void> _reprendreVentes(String utilisateurId) async {
    final provisoires =
        await (_db.select(_db.utilisateurs)..where(
              (u) => u.telephone.equals(BoutiqueRepository.telephoneProvisoire),
            ))
            .get();
    for (final p in provisoires) {
      await (_db.update(_db.ventes)..where((v) => v.utilisateurId.equals(p.id)))
          .write(VentesCompanion(utilisateurId: Value(utilisateurId)));
      await (_db.delete(
        _db.utilisateurs,
      )..where((u) => u.id.equals(p.id))).go();
    }
  }
}
