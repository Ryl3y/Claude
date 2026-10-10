import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/repositories/rapports_repository.dart';
import '../../domain/periode.dart';

/// Chiffres d'une période (accueil : le jour ; rapports : au choix).
final rapportProvider = StreamProvider.family<Rapport, Periode>(
  (ref, periode) =>
      ref.watch(rapportsRepositoryProvider).surveillerRapport(periode),
);

/// État de la sauvegarde affiché sur l'accueil.
enum EtatSauvegarde {
  /// Tout est envoyé au serveur.
  sauvegarde,

  /// Des changements attendent internet.
  enAttente,

  /// Pas encore de compte : tout reste sur le téléphone.
  surCeTelephone,
}

/// Avant l'inscription (étape 8), rien ne part en ligne : « Sur ce
/// téléphone ». L'étape 8 le reliera à la synchronisation.
final etatSauvegardeProvider = Provider<EtatSauvegarde>(
  (ref) => EtatSauvegarde.surCeTelephone,
);
