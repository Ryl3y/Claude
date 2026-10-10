import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';
import '../../core/heure_douala.dart';
import '../../data/auth/service_auth.dart';
import '../../data/db/kassa_database.dart';
import '../../data/firebase/notifications.dart';
import '../../data/firebase/services_firebase.dart';
import '../../data/inscription.dart';
import '../../data/providers.dart';
import '../../data/synchro/planificateur_synchro.dart';
import '../../data/synchro/serveur_synchro.dart';
import '../../data/synchro/supabase_serveur.dart';
import '../../data/synchro/synchro_service.dart';
import '../../domain/essais_pin.dart';
import 'langue.dart';

/// Où en est l'utilisateur : pas encore de compte, app verrouillée par le
/// code PIN, ou app ouverte.
sealed class EtatSession {
  const EtatSession();
}

class SessionChargement extends EtatSession {
  const SessionChargement();
}

class SessionSansCompte extends EtatSession {
  const SessionSansCompte();
}

class SessionVerrouillee extends EtatSession {
  const SessionVerrouillee(this.compte);
  final Utilisateur compte;
}

class SessionOuverte extends EtatSession {
  const SessionOuverte(this.compte);
  final Utilisateur compte;
}

/// Connexion par SMS ; null sans serveur configuré (tests, démonstration).
final serviceAuthProvider = Provider<ServiceAuth?>(
  (ref) => ConfigServeur.serveurConfigure
      ? SupabaseAuth(Supabase.instance.client.auth)
      : null,
);

/// Serveur de sauvegarde ; null sans serveur configuré.
final serveurSynchroProvider = Provider<ServeurSynchro?>(
  (ref) => ConfigServeur.serveurConfigure
      ? SupabaseServeur(Supabase.instance.client)
      : null,
);

/// Réseau disponible (wifi ou données mobiles), en direct.
final reseauProvider = Provider<Stream<bool>>(
  (ref) => Connectivity().onConnectivityChanged.map(
    (r) => r.any((c) => c != ConnectivityResult.none),
  ),
);

/// Code PIN demandé à l'ouverture (faux dans les tests de parcours).
final pinAuDemarrageProvider = Provider<bool>((ref) => true);

/// Après combien de temps en arrière-plan l'app redemande le code PIN.
const verrouillageApres = Duration(minutes: 5);

final sessionProvider = NotifierProvider<SessionController, EtatSession>(
  SessionController.new,
);

class SessionController extends Notifier<EtatSession> {
  @override
  EtatSession build() {
    Future.microtask(charger);
    return const SessionChargement();
  }

  /// Relit le compte du téléphone (au démarrage, après une restauration).
  Future<void> charger() async {
    final compte = await ref.read(compteRepositoryProvider).compteLocal();
    if (compte == null) {
      state = const SessionSansCompte();
    } else if (ref.read(pinAuDemarrageProvider)) {
      state = SessionVerrouillee(compte);
    } else {
      state = SessionOuverte(compte);
    }
  }

  void ouvrir(Utilisateur compte) => state = SessionOuverte(compte);

  /// Redemande le code PIN (retour après un long moment en arrière-plan).
  void verrouiller() {
    final s = state;
    if (s is SessionOuverte && ref.read(pinAuDemarrageProvider)) {
      state = SessionVerrouillee(s.compte);
    }
  }

  /// Attente imposée avant le prochain essai (zéro si on peut essayer).
  Duration attenteAvantEssai() {
    final prefs = ref.read(preferencesLocalesProvider);
    final dernier = prefs.dernierEchecPin;
    final attente = EssaisPin.attenteApres(prefs.echecsPin);
    if (dernier == null || attente == Duration.zero) return Duration.zero;
    final reste = dernier.add(attente).difference(HeureDouala.maintenantUtc());
    return reste.isNegative ? Duration.zero : reste;
  }

  /// Vérifie le code PIN. Renvoie null s'il est bon (app ouverte), sinon
  /// le nombre d'essais libres restants.
  Future<int?> deverrouiller(String pin) async {
    final s = state;
    if (s is! SessionVerrouillee) return null;
    if (attenteAvantEssai() > Duration.zero) return 0;
    final prefs = ref.read(preferencesLocalesProvider);
    if (await ref.read(compteRepositoryProvider).verifierPin(pin)) {
      await prefs.effacerEchecsPin();
      state = SessionOuverte(s.compte);
      return null;
    }
    await prefs.noterEchecPin(HeureDouala.maintenantUtc());
    return EssaisPin.restants(prefs.echecsPin);
  }

  /// Nouveau code PIN après « Code oublié » (numéro revérifié par SMS).
  Future<void> changerPin(String pin) async {
    final s = state;
    final compte = switch (s) {
      SessionVerrouillee(:final compte) ||
      SessionOuverte(:final compte) => compte,
      _ => throw StateError('Pas de compte'),
    };
    await ref.read(compteRepositoryProvider).changerPin(compte.id, pin);
    await ref.read(preferencesLocalesProvider).effacerEchecsPin();
    final relu = await ref.read(compteRepositoryProvider).compteLocal();
    state = SessionOuverte(relu ?? compte);
  }
}

/// Synchronisation de la boutique ; null sans serveur ou sans app ouverte.
final synchroServiceProvider = Provider<SynchroService?>((ref) {
  final serveur = ref.watch(serveurSynchroProvider);
  final session = ref.watch(sessionProvider);
  if (serveur == null || session is! SessionOuverte) return null;
  return SynchroService(
    ref.watch(kassaDatabaseProvider),
    serveur,
    ref.watch(preferencesLocalesProvider),
    boutiqueId: session.compte.boutiqueId,
  );
});

/// Lance la synchronisation au bon moment tant que l'app est ouverte.
final planificateurSynchroProvider = Provider<PlanificateurSynchro?>((ref) {
  final synchro = ref.watch(synchroServiceProvider);
  if (synchro == null) return null;
  final p = PlanificateurSynchro(
    synchro,
    reseauDisponible: ref.watch(reseauProvider),
  )..demarrer();
  ref.onDispose(p.arreter);
  return p;
});

/// Résultat du dernier passage de synchronisation.
final dernierBilanProvider = StreamProvider<BilanSynchro?>((ref) {
  final p = ref.watch(planificateurSynchroProvider);
  if (p == null) return Stream.value(null);
  return p.bilans;
});

/// Lignes pas encore sauvegardées en ligne.
final enAttenteProvider = StreamProvider<int>((ref) {
  final s = ref.watch(synchroServiceProvider);
  return s?.surveillerEnAttente() ?? Stream.value(0);
});

/// Les étapes de l'inscription ; null sans serveur configuré.
final inscriptionProvider = Provider<Inscription?>((ref) {
  final auth = ref.watch(serviceAuthProvider);
  final serveur = ref.watch(serveurSynchroProvider);
  if (auth == null || serveur == null) return null;
  return Inscription(
    auth: auth,
    serveur: serveur,
    comptes: ref.watch(compteRepositoryProvider),
    synchroPour: (boutiqueId) => SynchroService(
      ref.read(kassaDatabaseProvider),
      serveur,
      ref.read(preferencesLocalesProvider),
      boutiqueId: boutiqueId,
    ),
  );
});

/// Inscription de ce téléphone aux notifications, tant que l'app est
/// ouverte ; null sans Firebase, sans serveur ou sans compte connecté.
final notificationsProvider = Provider<Notifications?>((ref) {
  final session = ref.watch(sessionProvider);
  final auth = ref.watch(serviceAuthProvider);
  final utilisateurId = auth?.utilisateurId;
  if (!ServicesFirebase.actif ||
      !ConfigServeur.serveurConfigure ||
      session is! SessionOuverte ||
      utilisateurId == null) {
    return null;
  }
  final messagerie = FirebaseMessaging.instance;
  final n = Notifications(
    SupabaseJetons(Supabase.instance.client),
    lireJeton: messagerie.getToken,
    renouvellements: messagerie.onTokenRefresh,
    demanderPermission: () => messagerie.requestPermission(),
  );
  final code =
      ref.read(langueProvider)?.languageCode ??
      PlatformDispatcher.instance.locale.languageCode;
  unawaited(
    n.demarrer(
      utilisateurId: utilisateurId,
      appareilId: ref.read(appareilIdProvider),
      boutiqueId: session.compte.boutiqueId,
      langue: code == 'en' ? 'en' : 'fr',
    ),
  );
  ref.onDispose(n.arreter);
  return n;
});
