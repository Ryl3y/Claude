import 'dart:convert';

/// Découpage administratif du Cameroun (OCHA COD-AB) : 10 régions,
/// 58 départements, 360 arrondissements. Embarqué dans l'app
/// (assets/geo/decoupage.json) : il marche sans internet.
class Region {
  const Region(this.code, this.nomFr, this.nomEn);
  final String code;
  final String nomFr;
  final String nomEn;

  String nom(String langue) => langue == 'en' ? nomEn : nomFr;
}

class Departement {
  const Departement(this.code, this.region, this.nom);
  final String code;
  final String region;
  final String nom;
}

class Arrondissement {
  const Arrondissement(this.code, this.departement, this.nom);
  final String code;
  final String departement;
  final String nom;
}

class Decoupage {
  Decoupage(this.regions, this.departements, this.arrondissements);

  final List<Region> regions;
  final List<Departement> departements;
  final List<Arrondissement> arrondissements;

  static const fichier = 'assets/geo/decoupage.json';

  factory Decoupage.depuisJson(String texte) {
    final j = jsonDecode(texte) as Map<String, dynamic>;
    List<Map<String, dynamic>> l(String c) =>
        (j[c] as List).cast<Map<String, dynamic>>();
    return Decoupage(
      [
        for (final r in l('regions'))
          Region(r['c'] as String, r['fr'] as String, r['en'] as String),
      ],
      [
        for (final d in l('departements'))
          Departement(d['c'] as String, d['r'] as String, d['n'] as String),
      ],
      [
        for (final a in l('arrondissements'))
          Arrondissement(a['c'] as String, a['d'] as String, a['n'] as String),
      ],
    );
  }

  List<Departement> departementsDe(String region) => [
    for (final d in departements)
      if (d.region == region) d,
  ];

  List<Arrondissement> arrondissementsDe(String departement) => [
    for (final a in arrondissements)
      if (a.departement == departement) a,
  ];

  Arrondissement? arrondissement(String? code) =>
      arrondissements.where((a) => a.code == code).firstOrNull;

  Departement? departement(String? code) =>
      departements.where((d) => d.code == code).firstOrNull;

  Region? region(String? code) =>
      regions.where((r) => r.code == code).firstOrNull;
}

/// Une ville, un village ou un quartier des listes partagées. [id] est
/// null pour un nom nouveau, pas encore ajouté au serveur.
class Lieu {
  const Lieu(this.id, this.nom);
  final String? id;
  final String nom;

  @override
  bool operator ==(Object other) =>
      other is Lieu && other.id == id && other.nom == nom;

  @override
  int get hashCode => Object.hash(id, nom);
}

/// Le lieu choisi pour une boutique.
class LieuChoisi {
  const LieuChoisi({
    this.region,
    this.departement,
    this.arrondissement,
    this.localite,
    this.quartier,
  });

  final String? region;
  final String? departement;
  final String? arrondissement;
  final Lieu? localite;
  final Lieu? quartier;

  bool get complet =>
      arrondissement != null &&
      (localite?.nom.trim().isNotEmpty ?? false) &&
      (quartier?.nom.trim().isNotEmpty ?? false);
}

/// Clé de comparaison des noms de lieux, comme le serveur : minuscules,
/// sans accents, ponctuation remplacée par des espaces.
/// « Haoussa », « HAOUSSA » et « haoussa » ont la même clé.
String cleLieu(String nom) {
  const accents = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'ç': 'c',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ñ': 'n',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ý': 'y',
    'ÿ': 'y',
    'œ': 'oe',
    'æ': 'ae',
    'ß': 'ss',
  };
  final b = StringBuffer();
  for (final r in nom.toLowerCase().runes) {
    final c = String.fromCharCode(r);
    b.write(accents[c] ?? c);
  }
  return b.toString().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

/// Nom propre : espaces superflus retirés (« Village  Test » → « Village
/// Test »).
String nomLieu(String nom) => nom.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Noms de [lieux] qui contiennent [saisie] (sans accents ni majuscules),
/// ceux qui commencent par la saisie d'abord.
List<Lieu> filtrerLieux(List<Lieu> lieux, String saisie, {int max = 30}) {
  final c = cleLieu(saisie);
  if (c.isEmpty) return lieux.take(max).toList();
  final debut = <Lieu>[];
  final dedans = <Lieu>[];
  for (final l in lieux) {
    final k = cleLieu(l.nom);
    if (k.startsWith(c) || k.contains(' $c')) {
      debut.add(l);
    } else if (k.contains(c)) {
      dedans.add(l);
    }
  }
  return [...debut, ...dedans].take(max).toList();
}
