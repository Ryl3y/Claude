import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui/theme/kassa_tokens.dart';

/// Couleur des séries des graphiques admin (une seule série par graphique).
/// Vérifiée avec le validateur de palette : bande de luminosité et
/// contraste ≥ 3:1 sur la surface des cartes, en clair et en sombre.
Color couleurSerie(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF36A872)
    : const Color(0xFF1D7349);

/// Haut de l'axe : un nombre « rond » au-dessus de [max] (2, 4 ou 10 ×
/// 10^n), dont la moitié (repère du milieu) reste un nombre entier rond.
double maxRond(num max) {
  if (max <= 2) return 2;
  final p = math.pow(10, (math.log(max) / math.ln10).floor()).toDouble();
  for (final m in [2, 4, 10]) {
    if (m * p >= max) return m * p;
  }
  return 20 * p;
}

enum _Forme { courbe, barres }

/// Graphique d'une série (courbe ou barres) avec un axe, des repères
/// discrets et le détail au survol (ou au toucher).
class GraphiqueSerie extends StatefulWidget {
  const GraphiqueSerie.courbe({
    super.key,
    required this.valeurs,
    required this.etiquettes,
    required this.detail,
    required this.graduation,
    required this.resume,
  }) : _forme = _Forme.courbe;

  const GraphiqueSerie.barres({
    super.key,
    required this.valeurs,
    required this.etiquettes,
    required this.detail,
    required this.graduation,
    required this.resume,
  }) : _forme = _Forme.barres;

  final _Forme _forme;
  final List<int> valeurs;

  /// Étiquettes de l'axe horizontal (vide = pas d'étiquette à cet index).
  final List<String> etiquettes;

  /// Texte du détail au survol du point [i].
  final String Function(int i) detail;

  /// Texte d'une graduation de l'axe vertical.
  final String Function(double v) graduation;

  /// Résumé lu par le lecteur d'écran.
  final String resume;

  static const hauteur = 200.0;

  @override
  State<GraphiqueSerie> createState() => _GraphiqueSerieState();
}

class _GraphiqueSerieState extends State<GraphiqueSerie> {
  int? _survol;

  static const _margeGauche = 56.0;
  static const _margeBas = 28.0;

  int? _indexA(double x, double largeur) {
    final n = widget.valeurs.length;
    if (n == 0) return null;
    final zone = largeur - _margeGauche;
    if (zone <= 0) return null;
    final pas = widget._forme == _Forme.barres ? zone / n : zone / (n - 1);
    final i = widget._forme == _Forme.barres
        ? ((x - _margeGauche) / pas).floor()
        : ((x - _margeGauche) / pas).round();
    return i.clamp(0, n - 1);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final serie = couleurSerie(context);
    final max = maxRond(widget.valeurs.fold<int>(0, math.max));
    return Semantics(
      label: widget.resume,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, c) {
          final largeur = c.maxWidth;
          final i = _survol;
          return MouseRegion(
            onHover: (e) =>
                setState(() => _survol = _indexA(e.localPosition.dx, largeur)),
            onExit: (_) => setState(() => _survol = null),
            child: GestureDetector(
              onTapDown: (e) => setState(
                () => _survol = _indexA(e.localPosition.dx, largeur),
              ),
              child: SizedBox(
                height: GraphiqueSerie.hauteur,
                width: largeur,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: Size(largeur, GraphiqueSerie.hauteur),
                      painter: _Peintre(
                        forme: widget._forme,
                        valeurs: widget.valeurs,
                        etiquettes: widget.etiquettes,
                        graduation: widget.graduation,
                        max: max,
                        survol: i,
                        serie: serie,
                        grille: t.line,
                        texte: t.caption.copyWith(color: t.inkMuted),
                        surface: t.surfaceRaised,
                        gauche: _margeGauche,
                        bas: _margeBas,
                      ),
                    ),
                    if (i != null)
                      Positioned(
                        left:
                            (_margeGauche +
                                    (largeur - _margeGauche) *
                                        (widget._forme == _Forme.barres
                                            ? (i + 0.5) / widget.valeurs.length
                                            : i /
                                                  math.max(
                                                    1,
                                                    widget.valeurs.length - 1,
                                                  )))
                                .clamp(0, math.max(0, largeur - 180))
                                .toDouble(),
                        top: 0,
                        child: _Bulle(texte: widget.detail(i)),
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

class _Bulle extends StatelessWidget {
  const _Bulle({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return IgnorePointer(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: KassaSpace.s2,
          vertical: KassaSpace.s1,
        ),
        decoration: BoxDecoration(
          color: t.ink,
          borderRadius: BorderRadius.circular(KassaRadius.sm),
        ),
        child: Text(texte, style: t.caption.copyWith(color: t.surfaceRaised)),
      ),
    );
  }
}

class _Peintre extends CustomPainter {
  _Peintre({
    required this.forme,
    required this.valeurs,
    required this.etiquettes,
    required this.graduation,
    required this.max,
    required this.survol,
    required this.serie,
    required this.grille,
    required this.texte,
    required this.surface,
    required this.gauche,
    required this.bas,
  });

  final _Forme forme;
  final List<int> valeurs;
  final List<String> etiquettes;
  final String Function(double v) graduation;
  final double max;
  final int? survol;
  final Color serie;
  final Color grille;
  final TextStyle texte;
  final Color surface;
  final double gauche;
  final double bas;

  void _ecrire(
    Canvas c,
    String s,
    Offset o, {
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: texte),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    final dx = switch (align) {
      TextAlign.right => o.dx - tp.width,
      TextAlign.center => o.dx - tp.width / 2,
      _ => o.dx,
    };
    tp.paint(c, Offset(dx, o.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final haut = 24.0; // place pour la bulle
    final zoneH = size.height - bas - haut;
    final zoneL = size.width - gauche;
    double y(num v) => haut + zoneH * (1 - v / max);

    // Repères horizontaux : traits fins, discrets.
    final traitGrille = Paint()
      ..color = grille
      ..strokeWidth = 1;
    for (var k = 0; k <= 2; k++) {
      final v = max * k / 2;
      canvas.drawLine(
        Offset(gauche, y(v)),
        Offset(size.width, y(v)),
        traitGrille,
      );
      _ecrire(
        canvas,
        graduation(v),
        Offset(gauche - 8, y(v)),
        align: TextAlign.right,
      );
    }

    final n = valeurs.length;
    if (n == 0) return;
    final pinceau = Paint()..color = serie;

    if (forme == _Forme.barres) {
      final pas = zoneL / n;
      final epaisseur = math.min(24.0, pas * 0.6);
      for (var i = 0; i < n; i++) {
        final cx = gauche + pas * (i + 0.5);
        final top = y(valeurs[i]);
        final base = y(0);
        if (base - top > 0) {
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              Rect.fromLTRB(cx - epaisseur / 2, top, cx + epaisseur / 2, base),
              topLeft: const Radius.circular(4),
              topRight: const Radius.circular(4),
            ),
            survol == null || survol == i
                ? pinceau
                : (Paint()..color = serie.withValues(alpha: 0.45)),
          );
        }
        if (etiquettes[i].isNotEmpty) {
          _ecrire(
            canvas,
            etiquettes[i],
            Offset(cx, size.height - bas / 2),
            align: TextAlign.center,
          );
        }
      }
      return;
    }

    // Courbe : trait de 2 px, voile à 10 %, point final et point survolé.
    final pas = zoneL / math.max(1, n - 1);
    Offset p(int i) => Offset(gauche + pas * i, y(valeurs[i]));
    final chemin = Path()..moveTo(p(0).dx, p(0).dy);
    for (var i = 1; i < n; i++) {
      chemin.lineTo(p(i).dx, p(i).dy);
    }
    final voile = Path.from(chemin)
      ..lineTo(p(n - 1).dx, y(0))
      ..lineTo(p(0).dx, y(0))
      ..close();
    canvas.drawPath(voile, Paint()..color = serie.withValues(alpha: 0.10));
    canvas.drawPath(
      chemin,
      Paint()
        ..color = serie
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < n; i++) {
      if (etiquettes[i].isNotEmpty) {
        _ecrire(
          canvas,
          etiquettes[i],
          Offset(p(i).dx, size.height - bas / 2),
          align: i == 0
              ? TextAlign.left
              : i == n - 1
              ? TextAlign.right
              : TextAlign.center,
        );
      }
    }
    void point(int i) {
      canvas.drawCircle(p(i), 6, Paint()..color = surface);
      canvas.drawCircle(p(i), 4, pinceau);
    }

    point(n - 1);
    final s = survol;
    if (s != null) {
      canvas.drawLine(
        Offset(p(s).dx, haut),
        Offset(p(s).dx, y(0)),
        traitGrille,
      );
      point(s);
    }
  }

  @override
  bool shouldRepaint(_Peintre old) =>
      old.valeurs != valeurs ||
      old.survol != survol ||
      old.serie != serie ||
      old.max != max ||
      old.texte != texte;
}
