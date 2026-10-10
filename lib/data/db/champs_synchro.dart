import 'package:drift/drift.dart';

import '../../core/heure_douala.dart';

/// Valeurs des champs de synchronisation pour toute écriture locale :
/// `maj_le` = maintenant (UTC), `synchro` = false, `appareil_id` = ce téléphone.
///
/// Les dépôts (étapes 4 à 6) passent par ici pour chaque création ou
/// modification, y compris la suppression logique.
class ChampsSynchro {
  ChampsSynchro({required this.appareilId, DateTime Function()? horloge})
      : _horloge = horloge ?? HeureDouala.maintenantUtc;

  final String appareilId;
  final DateTime Function() _horloge;

  DateTime maintenant() => _horloge().toUtc();

  Value<DateTime> get majLe => Value(maintenant());
  Value<bool> get synchro => const Value(false);
  Value<String> get appareil => Value(appareilId);

  /// Pour une suppression logique : `supprime_le` = maintenant.
  Value<DateTime?> get supprimeMaintenant => Value(maintenant());
}
