import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase sert à deux choses seulement : les notifications (Cloud
/// Messaging) et les rapports de plantage (Crashlytics). Aucune donnée
/// métier n'y va.
abstract final class ServicesFirebase {
  /// Vrai si Firebase a démarré (google-services.json présent à la
  /// construction). Sinon l'app marche sans notifications ni rapports.
  static bool actif = false;

  static Future<void> demarrer() async {
    try {
      await Firebase.initializeApp();
    } on Object {
      return; // pas de configuration Firebase dans cette version
    }
    actif = true;
    final crash = FirebaseCrashlytics.instance;
    // Pas de rapports pendant le développement.
    await crash.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = crash.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (erreur, pile) {
      unawaited(crash.recordError(erreur, pile, fatal: true));
      return true;
    };
  }
}
