import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';
import '../../core/heure_douala.dart';
import '../../data/abonnement/service_abonnement.dart';
import '../../data/providers.dart';
import '../../domain/abonnement.dart';
import 'langue.dart';
import 'rapports.dart';
import 'session.dart';

/// Abonnement côté serveur ; null sans serveur configuré.
final serveurAbonnementProvider = Provider<ServeurAbonnement?>(
  (ref) => ConfigServeur.serveurConfigure
      ? SupabaseAbonnement(Supabase.instance.client)
      : null,
);

/// État de l'abonnement de la boutique ouverte ; null sans app ouverte.
///
/// Calculé sur le téléphone (l'app marche sans réseau) à partir du dernier
/// abonnement lu sur le serveur, ou, avant la première lecture, de la date
/// de création de la boutique (30 jours d'essai, comme le serveur). Relu
/// sur le serveur à l'ouverture et après chaque sauvegarde réussie.
///
/// Le serveur a le dernier mot : sans réponse de sa part (première
/// ouverture hors ligne, boutique restaurée, version sans serveur), l'app
/// ne se bloque jamais d'elle-même ; l'état reste alors inconnu (null)
/// plutôt que « terminé ».
final abonnementProvider =
    AsyncNotifierProvider<AbonnementController, EtatAbonnement?>(
      AbonnementController.new,
    );

class AbonnementController extends AsyncNotifier<EtatAbonnement?> {
  @override
  Future<EtatAbonnement?> build() async {
    final boutiqueId = ref.watch(
      sessionProvider.select(
        (s) => s is SessionOuverte ? s.compte.boutiqueId : null,
      ),
    );
    if (boutiqueId == null) return null;
    // Passe au jour suivant à minuit : l'essai peut se terminer.
    final aujourdhui = EtatAbonnement.jourDouala(
      ref.watch(jourCourantProvider),
    );
    ref.listen(dernierBilanProvider, (_, bilan) {
      if (bilan.value?.reussi ?? false) unawaited(rafraichir());
    });

    final prefs = ref.read(preferencesLocalesProvider);
    final garde = prefs.abonnement(boutiqueId);
    final fin = EtatAbonnement.lireDate(garde?.$2);
    final EtatAbonnement etat;
    if (garde != null && fin != null) {
      etat = EtatAbonnement.calculer(
        formule: garde.$1,
        fin: fin,
        aujourdhui: aujourdhui,
      );
    } else {
      final db = ref.read(kassaDatabaseProvider);
      final boutique = await (db.select(
        db.boutiques,
      )..where((b) => b.id.equals(boutiqueId))).getSingleOrNull();
      etat = EtatAbonnement.calculer(
        formule: 'gratuit',
        fin: EtatAbonnement.finEssaiDepuis(
          boutique?.creeLe ?? HeureDouala.maintenantUtc(),
        ),
        aujourdhui: aujourdhui,
      );
    }
    Future.microtask(rafraichir);
    // Pas de paiement possible sans serveur : jamais de blocage.
    if (etat is AbonnementTermine &&
        (garde == null || ref.read(serveurAbonnementProvider) == null)) {
      return null;
    }
    return etat;
  }

  /// Relit l'abonnement sur le serveur (sans réseau : rien ne change).
  Future<void> rafraichir() async {
    final serveur = ref.read(serveurAbonnementProvider);
    final s = ref.read(sessionProvider);
    if (serveur == null || s is! SessionOuverte) return;
    final boutiqueId = s.compte.boutiqueId;
    final AbonnementServeur? lu;
    try {
      lu = await serveur.lire(boutiqueId);
    } on Exception {
      return;
    }
    final fin = EtatAbonnement.lireDate(lu?.dateFin);
    if (lu == null || fin == null || !ref.mounted) return;
    await ref
        .read(preferencesLocalesProvider)
        .enregistrerAbonnement(
          boutiqueId,
          formule: lu.formule,
          dateFin: lu.dateFin,
        );
    if (!ref.mounted) return;
    state = AsyncData(
      EtatAbonnement.calculer(
        formule: lu.formule,
        fin: fin,
        aujourdhui: EtatAbonnement.jourDouala(ref.read(jourCourantProvider)),
      ),
    );
  }
}
