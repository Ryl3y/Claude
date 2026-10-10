import 'package:kassa/data/abonnement/service_abonnement.dart';

/// Abonnement et paiements Notch Pay simulés.
class FauxAbonnement implements ServeurAbonnement {
  FauxAbonnement({this.abonnement});

  /// Ce que le serveur renvoie (null : pas encore d'abonnement).
  AbonnementServeur? abonnement;

  /// Fait échouer la prochaine demande de paiement.
  ErreurPaiement? prochaineErreur;

  /// Statut renvoyé pour les paiements demandés.
  StatutPaiement statutPaiement = StatutPaiement.enAttente;

  /// Demandes reçues : (opérateur, numéro).
  final List<(Operateur, String)> demandes = [];

  @override
  Future<AbonnementServeur?> lire(String boutiqueId) async => abonnement;

  @override
  Future<String> demanderPaiement({
    required Operateur operateur,
    required String telephone,
  }) async {
    final e = prochaineErreur;
    if (e != null) {
      prochaineErreur = null;
      throw PaiementImpossible(e);
    }
    demandes.add((operateur, telephone));
    return 'kassa-00000000-0000-4000-8000-${demandes.length.toString().padLeft(12, '0')}';
  }

  @override
  Future<StatutPaiement> statut(String reference) async => statutPaiement;
}
