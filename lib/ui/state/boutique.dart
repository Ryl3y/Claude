import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/kassa_database.dart';
import '../../data/providers.dart';
import 'session.dart';

/// La boutique ouverte, en direct ; null sans app ouverte.
final boutiqueOuverteProvider = StreamProvider.autoDispose<Boutique?>((ref) {
  final id = ref.watch(
    sessionProvider.select(
      (s) => s is SessionOuverte ? s.compte.boutiqueId : null,
    ),
  );
  if (id == null) return Stream.value(null);
  return ref.watch(boutiqueRepositoryProvider).surveillerBoutique(id);
});
