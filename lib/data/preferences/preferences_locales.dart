import 'package:shared_preferences/shared_preferences.dart';

import '../../core/identifiant.dart';
import '../synchro/serveur_synchro.dart';

/// Réglages gardés sur le téléphone (hors base métier).
///
/// - la langue choisie dans Réglages (`null` = langue du téléphone) ;
/// - l'identifiant de ce téléphone (`appareil_id` des écritures).
class PreferencesLocales implements StockageCurseurs {
  PreferencesLocales(this._prefs);

  final SharedPreferences _prefs;

  static const _cleLangue = 'langue';
  static const _cleAppareil = 'appareil_id';

  static Future<PreferencesLocales> ouvrir() async =>
      PreferencesLocales(await SharedPreferences.getInstance());

  String? get langue => _prefs.getString(_cleLangue);

  Future<String>? _appareilId;

  /// Identifiant de ce téléphone, créé au premier lancement puis gardé.
  /// Deux appels simultanés reçoivent le même identifiant.
  Future<String> appareilId() => _appareilId ??= _lireOuCreerAppareilId();

  Future<String> _lireOuCreerAppareilId() async {
    final existant = _prefs.getString(_cleAppareil);
    if (existant != null) return existant;
    final nouveau = Identifiant.nouveau();
    await _prefs.setString(_cleAppareil, nouveau);
    return nouveau;
  }

  Future<void> enregistrerLangue(String? code) async {
    if (code == null) {
      await _prefs.remove(_cleLangue);
    } else {
      await _prefs.setString(_cleLangue, code);
    }
  }

  // Repères de téléchargement de la synchronisation, un par table.
  static const _prefixeCurseur = 'synchro.curseur.';

  @override
  String? lire(String table) => _prefs.getString('$_prefixeCurseur$table');

  @override
  Future<void> ecrire(String table, String curseur) =>
      _prefs.setString('$_prefixeCurseur$table', curseur);

  static const _cleRestauration = 'synchro.restauration_en_cours';

  @override
  bool get restaurationEnCours => _prefs.getBool(_cleRestauration) ?? false;

  @override
  Future<void> marquerRestauration({required bool enCours}) => enCours
      ? _prefs.setBool(_cleRestauration, true)
      : _prefs.remove(_cleRestauration);

  @override
  Future<void> toutEffacer() async {
    for (final cle in _prefs.getKeys().toList()) {
      if (cle.startsWith(_prefixeCurseur)) await _prefs.remove(cle);
    }
  }

  // Erreurs de code PIN d'affilée, gardées même si l'app est relancée.
  static const _cleEchecsPin = 'pin.echecs';
  static const _cleDernierEchecPin = 'pin.dernier_echec';

  int get echecsPin => _prefs.getInt(_cleEchecsPin) ?? 0;

  DateTime? get dernierEchecPin {
    final t = _prefs.getString(_cleDernierEchecPin);
    return t == null ? null : DateTime.tryParse(t)?.toUtc();
  }

  Future<void> noterEchecPin(DateTime instant) async {
    await _prefs.setInt(_cleEchecsPin, echecsPin + 1);
    await _prefs.setString(
      _cleDernierEchecPin,
      instant.toUtc().toIso8601String(),
    );
  }

  Future<void> effacerEchecsPin() async {
    await _prefs.remove(_cleEchecsPin);
    await _prefs.remove(_cleDernierEchecPin);
  }

  // Dernier abonnement lu sur le serveur, pour l'app sans réseau.
  static const _cleAbonnement = 'abonnement.';

  /// (formule, date de fin « 2026-11-09 ») gardés pour [boutiqueId].
  (String, String)? abonnement(String boutiqueId) {
    if (_prefs.getString('${_cleAbonnement}boutique') != boutiqueId) {
      return null;
    }
    final formule = _prefs.getString('${_cleAbonnement}formule');
    final fin = _prefs.getString('${_cleAbonnement}date_fin');
    return formule == null || fin == null ? null : (formule, fin);
  }

  Future<void> enregistrerAbonnement(
    String boutiqueId, {
    required String formule,
    required String dateFin,
  }) async {
    await _prefs.setString('${_cleAbonnement}boutique', boutiqueId);
    await _prefs.setString('${_cleAbonnement}formule', formule);
    await _prefs.setString('${_cleAbonnement}date_fin', dateFin);
  }

  /// Déconnexion : oublie tout ce qui concerne le compte (repères de
  /// synchronisation, code PIN, abonnement). La langue et l'identifiant
  /// du téléphone restent.
  Future<void> oublierCompte() async {
    await toutEffacer();
    await marquerRestauration(enCours: false);
    await effacerEchecsPin();
    for (final cle in _prefs.getKeys().toList()) {
      if (cle.startsWith(_cleAbonnement)) await _prefs.remove(cle);
    }
  }
}
