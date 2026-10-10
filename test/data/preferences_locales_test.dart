import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/data/preferences/preferences_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('appareil_id : créé une fois, même avec deux appels simultanés', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesLocales.ouvrir();
    final resultats = await Future.wait([prefs.appareilId(), prefs.appareilId()]);
    expect(resultats[0], resultats[1]);
    final relu = await (await PreferencesLocales.ouvrir()).appareilId();
    expect(relu, resultats[0]);
  });

  test('langue : enregistrée puis effacée', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesLocales.ouvrir();
    expect(prefs.langue, isNull);
    await prefs.enregistrerLangue('en');
    expect(prefs.langue, 'en');
    await prefs.enregistrerLangue(null);
    expect(prefs.langue, isNull);
  });
}
