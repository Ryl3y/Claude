import 'package:shared_preferences/shared_preferences.dart';

import '../../core/identifiant.dart';

/// Réglages gardés sur le téléphone (hors base métier).
///
/// - la langue choisie dans Réglages (`null` = langue du téléphone) ;
/// - l'identifiant de ce téléphone (`appareil_id` des écritures).
class PreferencesLocales {
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
}
