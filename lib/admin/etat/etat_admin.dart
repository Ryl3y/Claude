import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../donnees/auth_admin.dart';
import '../donnees/serveur_admin.dart';
import '../ui/carte_cameroun.dart' show cleVille;

/// Connexion de l'équipe ; fournie au démarrage (voir main_admin.dart).
final authAdminProvider = Provider<AuthAdmin>(
  (ref) => throw UnimplementedError('authAdminProvider non fourni'),
);

/// Accès aux fonctions admin du serveur ; fourni au démarrage.
final serveurAdminProvider = Provider<ServeurAdmin>(
  (ref) => throw UnimplementedError('serveurAdminProvider non fourni'),
);

sealed class EtatSessionAdmin {
  const EtatSessionAdmin();
}

class AdminChargement extends EtatSessionAdmin {
  const AdminChargement();
}

class AdminDeconnecte extends EtatSessionAdmin {
  const AdminDeconnecte();
}

class AdminConnecte extends EtatSessionAdmin {
  const AdminConnecte(this.email);
  final String email;
}

final sessionAdminProvider =
    NotifierProvider<SessionAdminController, EtatSessionAdmin>(
      SessionAdminController.new,
    );

class SessionAdminController extends Notifier<EtatSessionAdmin> {
  @override
  EtatSessionAdmin build() {
    final fin = ref
        .read(authAdminProvider)
        .sessionTerminee
        .listen((_) => state = const AdminDeconnecte());
    ref.onDispose(fin.cancel);
    Future.microtask(_reprendre);
    return const AdminChargement();
  }

  /// Après une erreur de chargement : la session est-elle encore admin ?
  /// Sinon (jeton expiré, compte retiré des admins), retour à la connexion.
  Future<void> verifier() async {
    if (state is! AdminConnecte) return;
    if (!await ref.read(authAdminProvider).sessionValide()) {
      state = const AdminDeconnecte();
    }
  }

  /// Reprend la session d'une visite précédente si elle est encore admin.
  Future<void> _reprendre() async {
    final auth = ref.read(authAdminProvider);
    final valide = await auth.sessionValide();
    state = valide ? AdminConnecte(auth.email ?? '') : const AdminDeconnecte();
  }

  /// Lève [ConnexionAdminImpossible] si la connexion est refusée.
  Future<void> connecter(String email, String motDePasse) async {
    final auth = ref.read(authAdminProvider);
    await auth.connecter(email, motDePasse);
    state = AdminConnecte(auth.email ?? email.trim());
  }

  Future<void> deconnecter() async {
    await ref.read(authAdminProvider).deconnecter();
    state = const AdminDeconnecte();
  }
}

/// Chiffres du tableau de bord (rechargés à chaque ouverture).
final chiffresAdminProvider = FutureProvider.autoDispose<ChiffresAdmin>(
  (ref) => ref.watch(serveurAdminProvider).chiffres(),
);

/// Boutiques par ville ; une ville écrite de plusieurs façons n'est
/// comptée qu'une fois (« Yaoundé », « yaounde »).
final zonesAdminProvider = FutureProvider.autoDispose<List<ZoneAdmin>>(
  (ref) async =>
      fusionnerZones(await ref.watch(serveurAdminProvider).zones(), cleVille),
);

/// Une page de boutiques correspondant à une recherche ; « Afficher
/// plus » charge la page suivante ([decalage] + [tailleDePage]).
final boutiquesAdminProvider = FutureProvider.autoDispose
    .family<PageAdmin<BoutiqueAdmin>, ({String recherche, int decalage})>(
      (ref, q) => ref
          .watch(serveurAdminProvider)
          .boutiques(
            recherche: q.recherche,
            limite: tailleDePage,
            decalage: q.decalage,
          ),
    );

/// Une page de paiements, filtrés par statut (null : tous).
final paiementsAdminProvider = FutureProvider.autoDispose
    .family<PageAdmin<PaiementAdmin>, ({String? statut, int decalage})>(
      (ref, q) => ref
          .watch(serveurAdminProvider)
          .paiements(
            statut: q.statut,
            limite: tailleDePage,
            decalage: q.decalage,
          ),
    );

/// Une page des villages et quartiers ajoutés par les commerçants.
final lieuxAdminProvider = FutureProvider.autoDispose
    .family<PageAdmin<LieuAjouteAdmin>, int>(
      (ref, decalage) => ref
          .watch(serveurAdminProvider)
          .lieuxAjoutes(limite: tailleDePage, decalage: decalage),
    );

/// Plusieurs pages chargées à la suite, vues comme une seule liste.
class Pages<T> {
  Pages(List<AsyncValue<PageAdmin<T>>> pages)
    : elements = [
        for (final p in pages)
          if (p.value case final v?) ...v.elements,
      ],
      total = pages.first.value?.total,
      enChargement = pages.any((p) => p.value == null && !p.hasError),
      enErreur = pages.any((p) => p.hasError && p.value == null);

  final List<T> elements;

  /// null tant que la première page n'est pas arrivée.
  final int? total;
  final bool enChargement;
  final bool enErreur;

  bool get plusAAfficher =>
      total != null && elements.length < total! && !enChargement;
}

final ajustementsAdminProvider = FutureProvider.autoDispose
    .family<List<AjustementAdmin>, String>(
      (ref, boutiqueId) =>
          ref.watch(serveurAdminProvider).ajustements(boutiqueId),
    );

/// Nombre de lignes demandées à la fois.
const tailleDePage = 50;
