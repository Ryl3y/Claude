import 'dart:isolate';

import 'package:drift/drift.dart';

import '../../core/identifiant.dart';
import '../../domain/boutique_saisie.dart';
import '../../domain/code_pin.dart';
import '../db/champs_synchro.dart';
import '../db/kassa_database.dart';
import '../db/tables.dart';
import 'boutique_repository.dart';

export '../../domain/boutique_saisie.dart' show BoutiqueSaisie;

/// Lance un calcul long et renvoie son résultat.
typedef CalculLourd = Future<T> Function<T>(T Function() calcul);

/// Le compte du propriétaire sur ce téléphone : création de la boutique,
/// reprise des données saisies avant l'inscription, code PIN.
class CompteRepository {
  CompteRepository(this._db, this._champs, {CalculLourd? calcul})
    : _calcul = calcul ?? _horsDuFilPrincipal;

  final KassaDatabase _db;
  final ChampsSynchro _champs;

  /// Où faire le calcul du code PIN (PBKDF2, plusieurs centaines de
  /// millisecondes sur un petit téléphone) : hors du fil de l'écran, pour
  /// qu'il ne se fige pas. Les tests le font sur place.
  final CalculLourd _calcul;

  static Future<T> _horsDuFilPrincipal<T>(T Function() calcul) =>
      Isolate.run(calcul);

  // Fonctions statiques : la fermeture n'emporte que le code PIN vers
  // l'autre fil, jamais la base de données.
  static String Function() _hachage(String pin) =>
      () => CodePin.hacher(pin);

  static bool Function() _verification(String pin, String empreinte) =>
      () => CodePin.verifier(pin, empreinte);

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
  }) async {
    if (!CodePin.estValide(pin)) throw ArgumentError.value(pin, 'pin');
    if (saisie.nom.trim().isEmpty) throw ArgumentError.value(saisie.nom);
    final empreinte = await _calcul(_hachage(pin));
    return _db.transaction(() async {
      final instant = _champs.maintenant();
      final provisoire = await _boutiqueProvisoire();
      final boutiqueId = provisoire?.id ?? Identifiant.nouveau();
      final valeurs = BoutiquesCompanion(
        nom: Value(saisie.nom.trim()),
        telephone: Value(telephone),
        ville: Value(saisie.ville.trim()),
        quartier: Value(saisie.quartier.trim()),
        arrondissement: Value(saisie.arrondissement),
        localiteId: Value(saisie.localiteId),
        quartierId: Value(saisie.quartierId),
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
    final empreinte = await _calcul(_hachage(pin));
    final lignes =
        await (_db.update(
          _db.utilisateurs,
        )..where((u) => u.id.equals(utilisateurId))).write(
          UtilisateursCompanion(
            codePin: Value(empreinte),
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
    if (compte == null) return false;
    final empreinte = compte.codePin;
    return _calcul(_verification(pin, empreinte));
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
