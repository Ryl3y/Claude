import 'package:shared_preferences/shared_preferences.dart';

/// Réglages gardés sur le téléphone (hors base métier).
///
/// Pour l'instant : la langue choisie dans Réglages.
/// `null` = suivre la langue du téléphone.
class PreferencesLocales {
  PreferencesLocales(this._prefs);

  final SharedPreferences _prefs;

  static const _cleLangue = 'langue';

  static Future<PreferencesLocales> ouvrir() async =>
      PreferencesLocales(await SharedPreferences.getInstance());

  String? get langue => _prefs.getString(_cleLangue);

  Future<void> enregistrerLangue(String? code) async {
    if (code == null) {
      await _prefs.remove(_cleLangue);
    } else {
      await _prefs.setString(_cleLangue, code);
    }
  }
}
