import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kassa/admin/admin_app.dart';
import 'package:kassa/admin/donnees/auth_admin.dart';
import 'package:kassa/admin/donnees/serveur_admin.dart';
import 'package:kassa/admin/etat/etat_admin.dart';
import 'package:kassa/data/preferences/preferences_locales.dart';
import 'package:kassa/ui/state/langue.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Connexion admin simulée : un seul compte admin, un compte non admin.
class FauxAuthAdmin implements AuthAdmin {
  FauxAuthAdmin({this.dejaConnecte = false});

  static const emailAdmin = 'rich@kassa.cm';
  static const motDePasse = 'secret-de-test';
  static const emailCommercant = 'awa@exemple.cm';

  bool dejaConnecte;
  String? _email;
  ErreurConnexionAdmin? prochaineErreur;

  @override
  String? get email => _email ?? (dejaConnecte ? emailAdmin : null);

  @override
  Future<bool> sessionValide() async => dejaConnecte;

  @override
  Future<void> connecter(String email, String motDePasse) async {
    final e = prochaineErreur;
    if (e != null) {
      prochaineErreur = null;
      throw ConnexionAdminImpossible(e);
    }
    if (motDePasse != FauxAuthAdmin.motDePasse) {
      throw const ConnexionAdminImpossible(ErreurConnexionAdmin.identifiants);
    }
    if (email.trim() != emailAdmin) {
      throw const ConnexionAdminImpossible(ErreurConnexionAdmin.pasAdmin);
    }
    _email = emailAdmin;
  }

  @override
  Future<void> deconnecter() async {
    _email = null;
    dejaConnecte = false;
  }

  final _fin = StreamController<void>.broadcast();

  /// Simule un jeton révoqué ou expiré.
  void terminerSession() {
    _email = null;
    dejaConnecte = false;
    _fin.add(null);
  }

  @override
  Stream<void> get sessionTerminee => _fin.stream;
}

/// Serveur admin en mémoire, avec quelques boutiques et paiements.
class FauxServeurAdmin implements ServeurAdmin {
  FauxServeurAdmin({DateTime? aujourdhui})
    : aujourdhui = aujourdhui ?? DateTime.utc(2026, 10, 10);

  final DateTime aujourdhui;
  bool enPanne = false;

  /// Fait refuser le prochain geste par le serveur.
  RefusAjustement? prochainRefus;

  /// Ajoute [n] boutiques de plus (listes longues, « Afficher plus »).
  void ajouterBoutiques(int n) {
    for (var i = 0; i < n; i++) {
      boutiquesListe.add(
        _b(
          'x$i',
          'Boutique $i',
          '23769100${i.toString().padLeft(4, '0')}',
          'Kribi',
          'Centre',
          'autre',
          'gratuit',
          3,
          0,
        ),
      );
    }
  }

  late final List<BoutiqueAdmin> boutiquesListe = [
    _b(
      'b1',
      'Chez Awa',
      '237690000001',
      'Douala',
      'Akwa',
      'alimentation',
      'pro',
      25,
      42,
    ),
    _b(
      'b2',
      'Quincaillerie Ngono',
      '237690000002',
      'Yaoundé',
      'Mokolo',
      'quincaillerie',
      'gratuit',
      3,
      7,
    ),
    _b(
      'b3',
      'Beauté Divine',
      '237690000003',
      'Douala',
      'Bonapriso',
      'cosmetiques',
      'gratuit',
      -4,
      2,
    ),
    _b(
      'b4',
      'Téléphones Express',
      '237690000004',
      'Bafoussam',
      'Marché A',
      'telephones',
      'pro',
      12,
      18,
    ),
    _b(
      'b5',
      'Boutique du Coin',
      '237690000005',
      'Garoua',
      'Roumdé Adjia',
      'quartier',
      'gratuit',
      5,
      1,
    ),
    _b(
      'b6',
      'Chez Fadil',
      '237690000006',
      'Mora',
      'Centre',
      'alimentation',
      'gratuit',
      6,
      0,
    ),
  ];

  BoutiqueAdmin _b(
    String id,
    String nom,
    String tel,
    String ville,
    String quartier,
    String type,
    String formule,
    int finDans,
    int ventes,
  ) => BoutiqueAdmin(
    id: id,
    nom: nom,
    telephone: tel,
    ville: ville,
    quartier: quartier,
    typeCommerce: type,
    creeLe: aujourdhui.subtract(const Duration(days: 20)),
    formule: formule,
    dateFin: aujourdhui.add(Duration(days: finDans)),
    derniereActivite: aujourdhui.add(const Duration(hours: 8)),
    ventes: ventes,
  );

  late final List<PaiementAdmin> paiementsListe = [
    _p('kassa-1', 'b1', 'Chez Awa', 'cm.mtn', 'reussi', 1),
    _p('kassa-2', 'b4', 'Téléphones Express', 'cm.orange', 'reussi', 3),
    _p('kassa-3', 'b2', 'Quincaillerie Ngono', 'cm.mtn', 'en_attente', 0),
    _p('kassa-4', 'b3', 'Beauté Divine', 'cm.orange', 'echoue', 2),
  ];

  PaiementAdmin _p(
    String ref,
    String id,
    String nom,
    String op,
    String statut,
    int ilYA,
  ) => PaiementAdmin(
    reference: ref,
    boutiqueId: id,
    boutiqueNom: nom,
    montant: 5000,
    operateur: op,
    statut: statut,
    creeLe: aujourdhui
        .add(const Duration(hours: 9))
        .subtract(Duration(days: ilYA)),
  );

  /// Gestes reçus : (boutique, jours, formule, motif).
  final List<(String, int, String, String)> gestes = [];

  void _panne() {
    if (enPanne) throw StateError('serveur injoignable');
  }

  @override
  Future<ChiffresAdmin> chiffres() async {
    _panne();
    return ChiffresAdmin(
      boutiques: boutiquesListe.length,
      nouvelles7Jours: 2,
      essais: 3,
      pro: 2,
      termines: 1,
      revenusMois: 10000,
      paiementsMois: 2,
      inscriptions: [
        for (var i = 29; i >= 0; i--)
          (
            aujourdhui.subtract(Duration(days: i)),
            const [0, 1, 0, 2, 1, 0, 3][i % 7],
          ),
      ],
      revenus: [
        for (var i = 5; i >= 0; i--)
          (
            DateTime.utc(aujourdhui.year, aujourdhui.month - i),
            const [0, 5000, 15000, 25000, 30000, 10000][5 - i],
          ),
      ],
    );
  }

  @override
  Future<PageAdmin<BoutiqueAdmin>> boutiques({
    String recherche = '',
    int limite = 50,
    int decalage = 0,
  }) async {
    _panne();
    final q = recherche.toLowerCase();
    final trouvees = [
      for (final b in boutiquesListe)
        if ('${b.nom} ${b.telephone} ${b.ville} ${b.quartier}'
            .toLowerCase()
            .contains(q))
          b,
    ];
    // Comme le serveur : 200 lignes au plus par appel.
    return PageAdmin(
      trouvees.skip(decalage).take(limite.clamp(1, 200)).toList(),
      trouvees.length,
    );
  }

  @override
  Future<PageAdmin<PaiementAdmin>> paiements({
    String? statut,
    int limite = 50,
    int decalage = 0,
  }) async {
    _panne();
    final l = [
      for (final p in paiementsListe)
        if (statut == null || p.statut == statut) p,
    ];
    return PageAdmin(l.skip(decalage).take(limite).toList(), l.length);
  }

  @override
  Future<List<ZoneAdmin>> zones() async {
    _panne();
    final parVille = <String, (int, int)>{};
    for (final b in boutiquesListe) {
      final (n, p) = parVille[b.ville] ?? (0, 0);
      parVille[b.ville] = (n + 1, p + (b.formule == 'pro' ? 1 : 0));
    }
    return [
      for (final e in parVille.entries)
        ZoneAdmin(ville: e.key, boutiques: e.value.$1, pro: e.value.$2),
    ]..sort((a, b) => b.boutiques.compareTo(a.boutiques));
  }

  @override
  Future<DateTime> ajusterAbonnement({
    required String boutiqueId,
    required int jours,
    required String formule,
    required String motif,
  }) async {
    _panne();
    final refus = prochainRefus;
    if (refus != null) {
      prochainRefus = null;
      throw AjustementRefuse(refus);
    }
    gestes.add((boutiqueId, jours, formule, motif));
    final i = boutiquesListe.indexWhere((b) => b.id == boutiqueId);
    final b = boutiquesListe[i];
    final depart = b.dateFin == null || b.dateFin!.isBefore(aujourdhui)
        ? aujourdhui
        : b.dateFin!;
    final fin = depart.add(Duration(days: jours));
    boutiquesListe[i] = BoutiqueAdmin(
      id: b.id,
      nom: b.nom,
      telephone: b.telephone,
      ville: b.ville,
      quartier: b.quartier,
      typeCommerce: b.typeCommerce,
      creeLe: b.creeLe,
      formule: formule == 'gratuit' && b.formule == 'pro' ? 'pro' : formule,
      dateFin: fin,
      derniereActivite: b.derniereActivite,
      ventes: b.ventes,
    );
    return fin;
  }

  /// Villages et quartiers ajoutés par les commerçants.
  late final List<LieuAjouteAdmin> lieuxListe = [
    _l('quartier', 'q1', 'Haousa', 'Koutaba', 'Koutaba', 'Noun', 0, 1),
    _l('localite', 'l1', 'Baleveng', null, 'Dschang', 'Menoua', 1, 2),
    _l('quartier', 'q2', 'Haoussa', 'Koutaba', 'Koutaba', 'Noun', 2, 3),
    _l('quartier', 'q3', 'Foto Marché', 'Dschang', 'Dschang', 'Menoua', 3, 0),
  ];

  LieuAjouteAdmin _l(
    String type,
    String id,
    String nom,
    String? localite,
    String arrondissement,
    String departement,
    int ilYA,
    int boutiques,
  ) => LieuAjouteAdmin(
    type: type,
    id: id,
    nom: nom,
    localite: localite,
    arrondissement: arrondissement,
    departement: departement,
    creeLe: aujourdhui.subtract(Duration(days: ilYA)),
    boutiques: boutiques,
  );

  /// Corrections reçues : (id, nouveau nom) ; suppressions : id.
  final List<(String, String)> renommages = [];
  final List<String> suppressions = [];

  @override
  Future<PageAdmin<LieuAjouteAdmin>> lieuxAjoutes({
    int limite = 50,
    int decalage = 0,
  }) async {
    _panne();
    return PageAdmin(
      lieuxListe.skip(decalage).take(limite).toList(),
      lieuxListe.length,
    );
  }

  @override
  Future<void> renommerLieu(LieuAjouteAdmin lieu, String nom) async {
    _panne();
    // Comme le serveur : même nom (sans accents ni majuscules) au même
    // endroit refusé.
    String cle(String n) => n.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
    if (lieuxListe.any(
      (x) =>
          x.id != lieu.id &&
          x.type == lieu.type &&
          x.localite == lieu.localite &&
          x.arrondissement == lieu.arrondissement &&
          cle(x.nom) == cle(nom),
    )) {
      throw const LieuAdminRefuse(RefusLieuAdmin.existeDeja);
    }
    renommages.add((lieu.id, nom));
    final i = lieuxListe.indexWhere((x) => x.id == lieu.id);
    lieuxListe[i] = _l(
      lieu.type,
      lieu.id,
      nom,
      lieu.localite,
      lieu.arrondissement,
      lieu.departement,
      aujourdhui.difference(lieu.creeLe).inDays,
      lieu.boutiques,
    );
  }

  @override
  Future<void> supprimerLieu(LieuAjouteAdmin lieu) async {
    _panne();
    suppressions.add(lieu.id);
    lieuxListe.removeWhere((x) => x.id == lieu.id);
  }

  @override
  Future<List<AjustementAdmin>> ajustements(String boutiqueId) async {
    _panne();
    return [
      for (final g in gestes.reversed)
        if (g.$1 == boutiqueId)
          AjustementAdmin(
            creeLe: aujourdhui.add(const Duration(hours: 10)),
            adminEmail: FauxAuthAdmin.emailAdmin,
            jours: g.$2,
            formule: g.$3,
            nouvelleFin: aujourdhui,
            motif: g.$4,
          ),
    ];
  }
}

/// L'admin complet avec des faux, prêt à être affiché.
Future<Widget> adminDeTest({
  required FauxAuthAdmin auth,
  required FauxServeurAdmin serveur,
  String langue = 'fr',
}) async {
  SharedPreferences.setMockInitialValues({'langue': langue});
  final prefs = await PreferencesLocales.ouvrir();
  return ProviderScope(
    overrides: [
      preferencesLocalesProvider.overrideWithValue(prefs),
      authAdminProvider.overrideWithValue(auth),
      serveurAdminProvider.overrideWithValue(serveur),
    ],
    child: const AdminApp(),
  );
}

/// Taille d'un écran d'ordinateur.
void ecranBureau(dynamic tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1280, 860);
}
