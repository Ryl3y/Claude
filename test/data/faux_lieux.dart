import 'package:kassa/data/lieux/service_lieux.dart';
import 'package:kassa/domain/lieux.dart';

/// Listes partagées simulées : quelques villages et quartiers, ajouts
/// visibles tout de suite, doublons évités comme sur le serveur.
class FauxLieux implements ServiceLieux {
  FauxLieux() {
    for (final (arr, nom) in [
      ('CM008005001', 'Dschang'),
      ('CM008005001', 'Foréké-Dschang'),
      ('CM008005001', 'Fongo-Ndeng'),
      ('CM008008005', 'Koutaba'),
      ('CM008006001', 'Bafoussam'),
      ('CM005004001', 'Douala'),
    ]) {
      _localites.putIfAbsent(arr, () => []).add(Lieu(_id(), nom));
    }
    final dschang = _localites['CM008005001']!.first.id!;
    _quartiers[dschang] = [Lieu(_id(), 'Haoussa'), Lieu(_id(), 'Tsinkop')];
    final douala = _localites['CM005004001']!.first.id!;
    _quartiers[douala] = [Lieu(_id(), 'Akwa'), Lieu(_id(), 'Bonapriso')];
  }

  var _n = 0;
  String _id() =>
      '00000000-0000-4000-a000-${(++_n).toString().padLeft(12, '0')}';

  final _localites = <String, List<Lieu>>{};
  final _quartiers = <String, List<Lieu>>{};

  /// Ajouts reçus : (parent, nom).
  final List<(String, String)> ajouts = [];

  /// Simule une coupure réseau.
  bool horsLigne = false;

  /// Fait refuser le prochain ajout.
  RefusLieu? prochainRefus;

  void _verifier() {
    if (horsLigne) throw const LieuRefuse(RefusLieu.reseau);
  }

  Lieu? lieuNomme(String nom) => [
    ..._localites.values.expand((l) => l),
    ..._quartiers.values.expand((l) => l),
  ].where((l) => l.nom == nom).firstOrNull;

  @override
  Future<List<Lieu>> localites(String arrondissement) async {
    _verifier();
    return [...?_localites[arrondissement]]
      ..sort((a, b) => cleLieu(a.nom).compareTo(cleLieu(b.nom)));
  }

  @override
  Future<List<Lieu>> quartiers(String localiteId) async {
    _verifier();
    return [...?_quartiers[localiteId]]
      ..sort((a, b) => cleLieu(a.nom).compareTo(cleLieu(b.nom)));
  }

  Future<Lieu> _ajouter(
    Map<String, List<Lieu>> table,
    String parent,
    String nom,
  ) async {
    _verifier();
    final refus = prochainRefus;
    if (refus != null) {
      prochainRefus = null;
      throw LieuRefuse(refus);
    }
    final liste = table.putIfAbsent(parent, () => []);
    final existant = liste
        .where((l) => cleLieu(l.nom) == cleLieu(nom))
        .firstOrNull;
    if (existant != null) return existant;
    final nouveau = Lieu(_id(), nomLieu(nom));
    liste.add(nouveau);
    ajouts.add((parent, nouveau.nom));
    return nouveau;
  }

  @override
  Future<Lieu> ajouterLocalite(String arrondissement, String nom) =>
      _ajouter(_localites, arrondissement, nom);

  @override
  Future<Lieu> ajouterQuartier(String localiteId, String nom) =>
      _ajouter(_quartiers, localiteId, nom);
}
