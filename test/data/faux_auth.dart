import 'package:kassa/data/auth/service_auth.dart';

/// Connexion par SMS simulée : le code [codeAttendu] est accepté pour
/// n'importe quel numéro ; chaque numéro a toujours le même compte.
class FauxAuth implements ServiceAuth {
  FauxAuth({this.codeAttendu = '123456'});

  final String codeAttendu;

  /// Numéro → identifiant du compte.
  final Map<String, String> comptes = {};

  /// Numéros auxquels un code a été « envoyé ».
  final List<String> codesEnvoyes = [];

  /// Fait échouer le prochain envoi ou la prochaine vérification.
  ErreurConnexion? prochaineErreur;

  /// Fait échouer la prochaine déconnexion (pas de réseau).
  bool prochaineErreurDeconnexion = false;

  String? _connecte;

  @override
  String? get utilisateurId => _connecte == null ? null : comptes[_connecte];

  @override
  String? get telephone => _connecte;

  String idPour(String telephone) => comptes.putIfAbsent(
    telephone,
    () =>
        '00000000-0000-4000-9000-${telephone.padLeft(12, '0').substring(0, 12)}',
  );

  @override
  Future<void> envoyerCode(String telephone) async {
    _echouerSiDemande();
    codesEnvoyes.add(telephone);
  }

  @override
  Future<String> verifierCode(String telephone, String code) async {
    _echouerSiDemande();
    if (code != codeAttendu) {
      throw const ConnexionImpossible(ErreurConnexion.codeRefuse);
    }
    _connecte = telephone;
    return idPour(telephone);
  }

  @override
  Future<void> deconnecter() async {
    _connecte = null;
    if (prochaineErreurDeconnexion) {
      prochaineErreurDeconnexion = false;
      throw const ConnexionImpossible(ErreurConnexion.reseau);
    }
  }

  void _echouerSiDemande() {
    final e = prochaineErreur;
    if (e != null) {
      prochaineErreur = null;
      throw ConnexionImpossible(e);
    }
  }
}
