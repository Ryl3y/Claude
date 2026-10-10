import 'package:supabase_flutter/supabase_flutter.dart';

/// Chiffres du tableau de bord admin.
class ChiffresAdmin {
  const ChiffresAdmin({
    required this.boutiques,
    required this.nouvelles7Jours,
    required this.essais,
    required this.pro,
    required this.termines,
    required this.revenusMois,
    required this.paiementsMois,
    required this.inscriptions,
    required this.revenus,
  });

  final int boutiques;
  final int nouvelles7Jours;
  final int essais;
  final int pro;
  final int termines;

  /// FCFA encaissés ce mois-ci (paiements réussis).
  final int revenusMois;
  final int paiementsMois;

  /// Inscriptions par jour, 30 derniers jours (le plus ancien d'abord).
  final List<(DateTime, int)> inscriptions;

  /// Revenus par mois, 6 derniers mois (le plus ancien d'abord).
  final List<(DateTime, int)> revenus;

  factory ChiffresAdmin.depuisJson(Map<String, dynamic> j) {
    List<(DateTime, int)> serie(String cle, String date, String valeur) => [
      for (final e in (j[cle] as List? ?? const []).cast<Map>())
        (DateTime.parse(e[date] as String), (e[valeur] as num).toInt()),
    ];
    int n(String cle) => (j[cle] as num? ?? 0).toInt();
    return ChiffresAdmin(
      boutiques: n('boutiques'),
      nouvelles7Jours: n('nouvelles_7_jours'),
      essais: n('essais'),
      pro: n('pro'),
      termines: n('termines'),
      revenusMois: n('revenus_mois'),
      paiementsMois: n('paiements_mois'),
      inscriptions: serie('inscriptions', 'jour', 'nombre'),
      revenus: serie('revenus', 'mois', 'montant'),
    );
  }
}

/// Une boutique vue par l'admin.
class BoutiqueAdmin {
  const BoutiqueAdmin({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.ville,
    required this.quartier,
    required this.typeCommerce,
    required this.creeLe,
    required this.formule,
    required this.dateFin,
    required this.derniereActivite,
    required this.ventes,
  });

  final String id;
  final String nom;
  final String telephone;
  final String ville;
  final String quartier;
  final String typeCommerce;
  final DateTime creeLe;

  /// « gratuit » ou « pro » ; null sans abonnement.
  final String? formule;

  /// Dernier jour de l'essai ou de Pro (date de Douala).
  final DateTime? dateFin;
  final DateTime? derniereActivite;
  final int ventes;

  factory BoutiqueAdmin.depuisJson(Map<String, dynamic> j) => BoutiqueAdmin(
    id: j['id'] as String,
    nom: j['nom'] as String,
    telephone: j['telephone'] as String,
    ville: j['ville'] as String,
    quartier: j['quartier'] as String,
    typeCommerce: j['type_commerce'] as String,
    creeLe: DateTime.parse(j['cree_le'] as String).toUtc(),
    formule: j['formule'] as String?,
    dateFin: _date(j['date_fin']),
    derniereActivite: j['derniere_activite'] == null
        ? null
        : DateTime.parse(j['derniere_activite'] as String).toUtc(),
    ventes: (j['ventes'] as num? ?? 0).toInt(),
  );
}

/// Un paiement Notch Pay vu par l'admin.
class PaiementAdmin {
  const PaiementAdmin({
    required this.reference,
    required this.boutiqueId,
    required this.boutiqueNom,
    required this.montant,
    required this.operateur,
    required this.statut,
    required this.creeLe,
  });

  final String reference;
  final String boutiqueId;
  final String boutiqueNom;
  final int montant;

  /// « cm.mtn » ou « cm.orange ».
  final String operateur;

  /// « en_attente », « reussi » ou « echoue ».
  final String statut;
  final DateTime creeLe;

  factory PaiementAdmin.depuisJson(Map<String, dynamic> j) => PaiementAdmin(
    reference: j['reference'] as String,
    boutiqueId: j['boutique_id'] as String,
    boutiqueNom: j['boutique_nom'] as String,
    montant: (j['montant'] as num).toInt(),
    operateur: j['operateur'] as String,
    statut: j['statut'] as String,
    creeLe: DateTime.parse(j['cree_le'] as String).toUtc(),
  );
}

/// Nombre de boutiques d'une ville (carte).
class ZoneAdmin {
  const ZoneAdmin({
    required this.ville,
    required this.boutiques,
    required this.pro,
  });

  final String ville;
  final int boutiques;
  final int pro;

  factory ZoneAdmin.depuisJson(Map<String, dynamic> j) => ZoneAdmin(
    ville: j['ville'] as String? ?? '',
    boutiques: (j['boutiques'] as num).toInt(),
    pro: (j['pro'] as num).toInt(),
  );
}

/// Un geste commercial déjà fait (historique d'une boutique).
class AjustementAdmin {
  const AjustementAdmin({
    required this.creeLe,
    required this.adminEmail,
    required this.jours,
    required this.formule,
    required this.nouvelleFin,
    required this.motif,
  });

  final DateTime creeLe;
  final String? adminEmail;
  final int jours;
  final String formule;
  final DateTime nouvelleFin;
  final String motif;

  factory AjustementAdmin.depuisJson(Map<String, dynamic> j) => AjustementAdmin(
    creeLe: DateTime.parse(j['cree_le'] as String).toUtc(),
    adminEmail: j['admin_email'] as String?,
    jours: (j['jours'] as num).toInt(),
    formule: j['formule'] as String,
    nouvelleFin: _date(j['nouvelle_fin'])!,
    motif: j['motif'] as String,
  );
}

/// Le serveur a refusé un geste commercial.
enum RefusAjustement { jours, motif, autre }

class AjustementRefuse implements Exception {
  const AjustementRefuse(this.raison);
  final RefusAjustement raison;

  @override
  String toString() => 'AjustementRefuse($raison)';
}

/// Regroupe les zones d'une même ville écrite de plusieurs façons
/// (« Yaoundé », « Yaounde ») ; garde l'écriture la plus fréquente.
List<ZoneAdmin> fusionnerZones(
  List<ZoneAdmin> zones,
  String Function(String ville) cle,
) {
  final parCle = <String, List<ZoneAdmin>>{};
  for (final z in zones) {
    parCle.putIfAbsent(cle(z.ville), () => []).add(z);
  }
  return [
    for (final groupe in parCle.values)
      ZoneAdmin(
        ville:
            (groupe.toList()
                  ..sort((a, b) => b.boutiques.compareTo(a.boutiques)))
                .first
                .ville,
        boutiques: groupe.fold(0, (s, z) => s + z.boutiques),
        pro: groupe.fold(0, (s, z) => s + z.pro),
      ),
  ]..sort((a, b) => b.boutiques.compareTo(a.boutiques));
}

/// Une page de résultats et le total disponible.
class PageAdmin<T> {
  const PageAdmin(this.elements, this.total);

  final List<T> elements;
  final int total;
}

DateTime? _date(Object? texte) {
  if (texte is! String) return null;
  final d = DateTime.parse(texte);
  return DateTime.utc(d.year, d.month, d.day);
}

/// Accès du tableau de bord au serveur (Supabase en vrai, un faux en test).
/// Toutes les lectures passent par les fonctions admin_* du serveur, qui
/// refusent tout compte qui n'est pas admin.
abstract interface class ServeurAdmin {
  Future<ChiffresAdmin> chiffres();

  Future<PageAdmin<BoutiqueAdmin>> boutiques({
    String recherche = '',
    int limite = 50,
    int decalage = 0,
  });

  /// [statut] : null pour tous.
  Future<PageAdmin<PaiementAdmin>> paiements({
    String? statut,
    int limite = 50,
    int decalage = 0,
  });

  Future<List<ZoneAdmin>> zones();

  /// Offre [jours] d'essai (« gratuit ») ou de Pro ; renvoie la nouvelle fin.
  /// Lève [AjustementRefuse] si le serveur refuse la saisie.
  Future<DateTime> ajusterAbonnement({
    required String boutiqueId,
    required int jours,
    required String formule,
    required String motif,
  });

  Future<List<AjustementAdmin>> ajustements(String boutiqueId);
}

class SupabaseServeurAdmin implements ServeurAdmin {
  SupabaseServeurAdmin(this._client);

  final SupabaseClient _client;

  List<Map<String, dynamic>> _lignes(Object? r) => [
    for (final l in (r as List? ?? const [])) Map<String, dynamic>.from(l),
  ];

  int _total(List<Map<String, dynamic>> l) =>
      l.isEmpty ? 0 : (l.first['total'] as num).toInt();

  @override
  Future<ChiffresAdmin> chiffres() async => ChiffresAdmin.depuisJson(
    Map<String, dynamic>.from(await _client.rpc('admin_chiffres') as Map),
  );

  @override
  Future<PageAdmin<BoutiqueAdmin>> boutiques({
    String recherche = '',
    int limite = 50,
    int decalage = 0,
  }) async {
    final l = _lignes(
      await _client.rpc(
        'admin_boutiques',
        params: {
          'p_recherche': recherche,
          'p_limite': limite,
          'p_decalage': decalage,
        },
      ),
    );
    return PageAdmin([
      for (final x in l) BoutiqueAdmin.depuisJson(x),
    ], _total(l));
  }

  @override
  Future<PageAdmin<PaiementAdmin>> paiements({
    String? statut,
    int limite = 50,
    int decalage = 0,
  }) async {
    final l = _lignes(
      await _client.rpc(
        'admin_paiements',
        params: {
          'p_statut': statut,
          'p_limite': limite,
          'p_decalage': decalage,
        },
      ),
    );
    return PageAdmin([
      for (final x in l) PaiementAdmin.depuisJson(x),
    ], _total(l));
  }

  @override
  Future<List<ZoneAdmin>> zones() async => [
    for (final x in _lignes(await _client.rpc('admin_zones')))
      ZoneAdmin.depuisJson(x),
  ];

  @override
  Future<DateTime> ajusterAbonnement({
    required String boutiqueId,
    required int jours,
    required String formule,
    required String motif,
  }) async {
    try {
      return _date(
        await _client.rpc(
          'admin_ajuster_abonnement',
          params: {
            'p_boutique_id': boutiqueId,
            'p_jours': jours,
            'p_formule': formule,
            'p_motif': motif,
          },
        ),
      )!;
    } on PostgrestException catch (e) {
      throw AjustementRefuse(switch (e.message) {
        'jours_invalides' => RefusAjustement.jours,
        'motif_invalide' => RefusAjustement.motif,
        _ => RefusAjustement.autre,
      });
    }
  }

  @override
  Future<List<AjustementAdmin>> ajustements(String boutiqueId) async => [
    for (final x in _lignes(
      await _client.rpc(
        'admin_ajustements',
        params: {'p_boutique_id': boutiqueId},
      ),
    ))
      AjustementAdmin.depuisJson(x),
  ];
}
