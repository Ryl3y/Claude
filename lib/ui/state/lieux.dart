import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';
import '../../data/lieux/service_lieux.dart';
import '../../domain/lieux.dart';

/// Découpage administratif embarqué dans l'app (lu une fois : le provider
/// garde le résultat ; le cache de rootBundle est inutile).
final decoupageProvider = FutureProvider<Decoupage>(
  (ref) async => Decoupage.depuisJson(
    await rootBundle.loadString(Decoupage.fichier, cache: false),
  ),
);

/// Listes partagées des villes, villages et quartiers ; null sans serveur.
final serviceLieuxProvider = Provider<ServiceLieux?>(
  (ref) => ConfigServeur.serveurConfigure
      ? SupabaseLieux(Supabase.instance.client)
      : null,
);
