import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/heure_douala.dart';

import '../../data/providers.dart';
import '../../data/repositories/rapports_repository.dart';
import '../../domain/periode.dart';
import 'session.dart';

/// Chiffres d'une période (accueil : le jour ; rapports : au choix).
/// autoDispose : une période qu'on ne regarde plus arrête d'être recalculée.
final rapportProvider = StreamProvider.autoDispose.family<Rapport, Periode>(
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

/// « Sur ce téléphone » sans serveur ; sinon « Sauvegardé » quand tout est
/// envoyé et que le dernier passage a réussi, « Sauvegarde en attente »
/// tant qu'il reste des changements ou que le réseau manque.
final etatSauvegardeProvider = Provider<EtatSauvegarde>((ref) {
  if (ref.watch(synchroServiceProvider) == null) {
    return EtatSauvegarde.surCeTelephone;
  }
  final enAttente = ref.watch(enAttenteProvider).value ?? 0;
  final bilan = ref.watch(dernierBilanProvider).value;
  return enAttente == 0 && (bilan == null || bilan.reussi)
      ? EtatSauvegarde.sauvegarde
      : EtatSauvegarde.enAttente;
});

/// Début du jour en cours à Douala (UTC). Change tout seul à minuit :
/// l'accueil et les rapports restés ouverts passent au nouveau jour.
final jourCourantProvider = NotifierProvider<JourCourant, DateTime>(
  JourCourant.new,
);

class JourCourant extends Notifier<DateTime> {
  Timer? _minuit;

  @override
  DateTime build() {
    ref.onDispose(() => _minuit?.cancel());
    final jour = HeureDouala.debutDuJourUtc(HeureDouala.maintenantUtc());
    _programmer(jour);
    return jour;
  }

  void _programmer(DateTime jour) {
    _minuit?.cancel();
    final attente = jour
        .add(const Duration(days: 1))
        .difference(HeureDouala.maintenantUtc());
    // Une seconde de marge pour être sûr d'être passé au jour suivant.
    _minuit = Timer(attente + const Duration(seconds: 1), () {
      final nouveau = HeureDouala.debutDuJourUtc(HeureDouala.maintenantUtc());
      state = nouveau;
      _programmer(nouveau);
    });
  }
}
