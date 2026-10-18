import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../ui/theme/kassa_tokens.dart';
import '../donnees/serveur_admin.dart';
import 'graphiques.dart';

/// Contour du Cameroun (longitude, latitude), d'après Natural Earth 1:110m
/// (domaine public), simplifié.
const contourCameroun = <(double, double)>[
  (13.075822, 2.267097),
  (12.951334, 2.321616),
  (12.35938, 2.192812),
  (11.751665, 2.326758),
  (11.276449, 2.261051),
  (9.649158, 2.283866),
  (9.795196, 3.073404),
  (9.404367, 3.734527),
  (8.948116, 3.904129),
  (8.744924, 4.352215),
  (8.488816, 4.495617),
  (8.500288, 4.771983),
  (8.757533, 5.479666),
  (9.233163, 6.444491),
  (9.522706, 6.453482),
  (10.118277, 7.03877),
  (10.497375, 7.055358),
  (11.058788, 6.644427),
  (11.745774, 6.981383),
  (11.839309, 7.397042),
  (12.063946, 7.799808),
  (12.218872, 8.305824),
  (12.753672, 8.717763),
  (12.955468, 9.417772),
  (13.1676, 9.640626),
  (13.308676, 10.160362),
  (13.57295, 10.798566),
  (14.415379, 11.572369),
  (14.468192, 11.904752),
  (14.577178, 12.085361),
  (14.181336, 12.483657),
  (14.213531, 12.802035),
  (14.495787, 12.859396),
  (14.893386, 12.219048),
  (14.960152, 11.555574),
  (14.923565, 10.891325),
  (15.467873, 9.982337),
  (14.909354, 9.992129),
  (14.627201, 9.920919),
  (14.171466, 10.021378),
  (13.954218, 9.549495),
  (14.544467, 8.965861),
  (14.979996, 8.796104),
  (15.120866, 8.38215),
  (15.436092, 7.692812),
  (15.27946, 7.421925),
  (14.776545, 6.408498),
  (14.53656, 6.226959),
  (14.459407, 5.451761),
  (14.558936, 5.030598),
  (14.478372, 4.732605),
  (14.950953, 4.210389),
  (15.03622, 3.851367),
  (15.405396, 3.335301),
  (15.862732, 3.013537),
  (15.907381, 2.557389),
  (16.012852, 2.26764),
  (15.940919, 1.727673),
  (15.146342, 1.964015),
  (14.337813, 2.227875),
];

/// Villes connues (longitude, latitude). Les autres sont listées à part.
const villesCameroun = <String, (double, double)>{
  'douala': (9.70, 4.05),
  'yaounde': (11.52, 3.87),
  'bafoussam': (10.42, 5.48),
  'bamenda': (10.16, 5.96),
  'garoua': (13.40, 9.30),
  'maroua': (14.32, 10.59),
  'ngaoundere': (13.58, 7.32),
  'bertoua': (13.68, 4.58),
  'ebolowa': (11.15, 2.90),
  'kribi': (9.91, 2.94),
  'limbe': (9.21, 4.02),
  'buea': (9.24, 4.16),
  'tiko': (9.36, 4.08),
  'kumba': (9.45, 4.64),
  'nkongsamba': (9.94, 4.95),
  'loum': (9.73, 4.72),
  'dschang': (10.05, 5.45),
  'edea': (10.13, 3.80),
  'foumban': (10.90, 5.73),
  'mbouda': (10.25, 5.63),
  'bafang': (10.18, 5.16),
  'bangangte': (10.52, 5.14),
  'kumbo': (10.68, 6.20),
  'mbalmayo': (11.50, 3.52),
  'obala': (11.53, 4.17),
  'sangmelima': (11.98, 2.93),
  'abong mbang': (13.18, 3.98),
  'batouri': (14.36, 4.43),
  'meiganga': (14.30, 6.52),
  'guider': (13.95, 9.93),
  'mokolo': (13.80, 10.74),
  'yagoua': (15.23, 10.34),
  // Sur la frontière : un peu à l'intérieur du contour simplifié.
  'kousseri': (14.85, 11.95),
};

/// « Yaoundé », « yaounde », « Abong-Mbang » → clé de [villesCameroun].
String cleVille(String ville) {
  const accents = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };
  final bas = ville.trim().toLowerCase();
  final b = StringBuffer();
  for (final r in bas.runes) {
    final ch = String.fromCharCode(r);
    b.write(accents[ch] ?? (ch == '-' ? ' ' : ch));
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// Carte des zones couvertes : une bulle par ville, d'autant plus grande
/// qu'elle a de boutiques. Le détail s'affiche au survol ou au toucher.
class CarteCameroun extends StatefulWidget {
  const CarteCameroun({super.key, required this.zones, this.hauteur = 420});

  final List<ZoneAdmin> zones;
  final double hauteur;

  @override
  State<CarteCameroun> createState() => _CarteCamerounState();
}

class _Bulle {
  const _Bulle(this.zone, this.centre, this.rayon);
  final ZoneAdmin zone;
  final Offset centre;
  final double rayon;
}

class _CarteCamerounState extends State<CarteCameroun> {
  _Bulle? _survol;

  static const _lonMin = 8.3, _lonMax = 16.3, _latMin = 1.5, _latMax = 13.2;

  Offset _projeter((double, double) p, Size s) {
    final echelle = math.min(
      s.width / (_lonMax - _lonMin),
      s.height / (_latMax - _latMin),
    );
    final dx = (s.width - (_lonMax - _lonMin) * echelle) / 2;
    return Offset(dx + (p.$1 - _lonMin) * echelle, (_latMax - p.$2) * echelle);
  }

  List<_Bulle> _bulles(Size s) {
    final placees = [
      for (final z in widget.zones)
        if (villesCameroun[cleVille(z.ville)] case final pos?) (z, pos),
    ];
    final max = placees.fold<int>(1, (m, e) => math.max(m, e.$1.boutiques));
    return [
      for (final (z, pos) in placees)
        _Bulle(z, _projeter(pos, s), 6 + 18 * math.sqrt(z.boutiques / max)),
    ]..sort((a, b) => b.rayon.compareTo(a.rayon));
  }

  _Bulle? _sous(Offset o, List<_Bulle> bulles) {
    for (final b in bulles.reversed) {
      if ((b.centre - o).distance <= math.max(b.rayon, 12)) return b;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final serie = couleurSerie(context);
    final villes = widget.zones
        .where((z) => villesCameroun.containsKey(cleVille(z.ville)))
        .length;
    return Semantics(
      label: l.adminMapSummary(villes),
      child: LayoutBuilder(
        builder: (context, c) {
          final taille = Size(c.maxWidth, widget.hauteur);
          final bulles = _bulles(taille);
          final s = _survol;
          return MouseRegion(
            onHover: (e) =>
                setState(() => _survol = _sous(e.localPosition, bulles)),
            onExit: (_) => setState(() => _survol = null),
            child: GestureDetector(
              onTapDown: (e) =>
                  setState(() => _survol = _sous(e.localPosition, bulles)),
              child: SizedBox.fromSize(
                size: taille,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: taille,
                      painter: _PeintreCarte(
                        contour: [
                          for (final p in contourCameroun) _projeter(p, taille),
                        ],
                        bulles: bulles,
                        survol: s,
                        pays: t.kassaSoft,
                        bord: t.line,
                        serie: serie,
                        surface: t.surfaceRaised,
                        texte: t.caption.copyWith(color: t.ink),
                      ),
                    ),
                    if (s != null)
                      Positioned(
                        left: (s.centre.dx + s.rayon + 4)
                            .clamp(0, math.max(0, taille.width - 200))
                            .toDouble(),
                        top: (s.centre.dy - 14)
                            .clamp(0, taille.height - 32)
                            .toDouble(),
                        child: IgnorePointer(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: KassaSpace.s2,
                              vertical: KassaSpace.s1,
                            ),
                            decoration: BoxDecoration(
                              color: t.ink,
                              borderRadius: BorderRadius.circular(
                                KassaRadius.sm,
                              ),
                            ),
                            child: Text(
                              l.adminZoneLine(
                                s.zone.ville,
                                l.adminShopsCount(s.zone.boutiques),
                                s.zone.pro,
                              ),
                              style: t.caption.copyWith(color: t.surfaceRaised),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PeintreCarte extends CustomPainter {
  _PeintreCarte({
    required this.contour,
    required this.bulles,
    required this.survol,
    required this.pays,
    required this.bord,
    required this.serie,
    required this.surface,
    required this.texte,
  });

  final List<Offset> contour;
  final List<_Bulle> bulles;
  final _Bulle? survol;
  final Color pays;
  final Color bord;
  final Color serie;
  final Color surface;
  final TextStyle texte;

  /// Villes nommées sur la carte (les plus grandes) ; les autres au survol.
  static const _nommees = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final forme = Path()..addPolygon(contour, true);
    canvas.drawPath(forme, Paint()..color = pays);
    canvas.drawPath(
      forme,
      Paint()
        ..color = bord
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Les plus petites par-dessus, chacune entourée d'un anneau de surface.
    for (final b in bulles) {
      canvas.drawCircle(b.centre, b.rayon + 2, Paint()..color = surface);
      canvas.drawCircle(
        b.centre,
        b.rayon,
        Paint()
          ..color = serie.withValues(
            alpha: survol == null || survol!.zone.ville == b.zone.ville
                ? 0.9
                : 0.55,
          ),
      );
    }
    for (final b in bulles.take(_nommees)) {
      final tp = TextPainter(
        text: TextSpan(text: b.zone.ville, style: texte),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(b.centre.dx + b.rayon + 4, b.centre.dy - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_PeintreCarte old) => true;
}
