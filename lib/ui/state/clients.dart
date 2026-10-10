import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/db/kassa_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/boutique_repository.dart';
import '../../data/repositories/clients_repository.dart';

/// Liste des clients (écran 12), plus grosse dette d'abord.
final clientsResumesProvider = StreamProvider<List<ClientResume>>(
  (ref) => ref.watch(clientsRepositoryProvider).surveillerResumes(),
);

/// Un client (fiche, encaissement, modification).
final clientProvider = StreamProvider.family<Client?, String>(
  (ref, id) => ref.watch(clientsRepositoryProvider).surveillerClient(id),
);

/// Achats et versements d'un client.
final historiqueClientProvider =
    StreamProvider.family<List<OperationClient>, String>(
      (ref, id) =>
          ref.watch(clientsRepositoryProvider).surveillerHistorique(id),
    );

/// Nom qui signe les messages aux clients ; null tant que la boutique est
/// provisoire (avant l'inscription de l'étape 8). Relu à chaque message :
/// un changement de nom compte tout de suite.
Future<String?> signatureBoutique(WidgetRef ref) async {
  final b = await ref.read(boutiqueRepositoryProvider).boutiqueCourante();
  return BoutiqueRepository.estProvisoire(b) ? null : b.nom;
}

/// Ouvre un lien hors de l'app (WhatsApp). Renvoie false si rien ne s'ouvre.
/// Remplacé dans les tests pour lire le lien sans quitter l'app.
final ouvrirLienProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);
