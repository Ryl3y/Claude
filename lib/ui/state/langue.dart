import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/preferences/preferences_locales.dart';

/// Langues de l'app. Le français est la langue par défaut.
const languesKassa = [Locale('fr'), Locale('en')];

/// Fourni au démarrage (voir main.dart).
final preferencesLocalesProvider = Provider<PreferencesLocales>(
  (ref) => throw UnimplementedError('preferencesLocalesProvider non fourni'),
);

/// Langue choisie dans Réglages ; `null` = langue du téléphone.
final langueProvider = NotifierProvider<LangueController, Locale?>(
  LangueController.new,
);

class LangueController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.read(preferencesLocalesProvider).langue;
    return code == null ? null : Locale(code);
  }

  Future<void> choisir(Locale? langue) async {
    state = langue;
    await ref
        .read(preferencesLocalesProvider)
        .enregistrerLangue(langue?.languageCode);
  }
}

/// Choisit la langue à partir de celles du téléphone :
/// anglais si le téléphone est en anglais, sinon français.
Locale resoudreLangue(List<Locale>? languesTelephone) {
  for (final l in languesTelephone ?? const <Locale>[]) {
    for (final k in languesKassa) {
      if (k.languageCode == l.languageCode) return k;
    }
  }
  return languesKassa.first;
}
