import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/kassa_tokens.dart';

/// Variantes du symbole Kassa (piste 2 « Le reçu »).
enum KassaSymboleVariante {
  /// Symbole principal, sur fond clair.
  principal,

  /// Version simplifiée, pour 24 px et moins (favicon, notification).
  petit,

  /// Sur les grandes zones `kassa-deep` (bienvenue, en-tête de l'accueil).
  surFonce,
}

/// Le symbole : un reçu de caisse vert marqué d'un K, avec une pièce d'or.
///
/// Le contour de la pièce (et, sur fond foncé, le K) prend la couleur
/// du fond pour la « détacher » du reçu : [fond], par défaut
/// `surface-raised` (cartes), ou `kassa-deep` pour la variante surFonce.
class KassaSymbole extends StatelessWidget {
  const KassaSymbole({super.key, this.taille = 48, this.variante, this.fond});

  final double taille;

  /// Si absent : [KassaSymboleVariante.petit] à 24 px et moins,
  /// sinon [KassaSymboleVariante.principal].
  final KassaSymboleVariante? variante;
  final Color? fond;

  @override
  Widget build(BuildContext context) {
    final v =
        variante ??
        (taille <= 24
            ? KassaSymboleVariante.petit
            : KassaSymboleVariante.principal);
    final contour =
        fond ??
        (v == KassaSymboleVariante.surFonce
            ? context.kassa.kassaDeep
            : context.kassa.surfaceRaised);
    return SvgPicture.string(
      KassaSvg.pour(v, contourPiece: contour),
      width: taille,
      height: taille,
      excludeFromSemantics: true,
    );
  }
}

/// Le nom « kassa » : minuscules, Plus Jakarta Sans 800, lettres resserrées −3 %.
class KassaNom extends StatelessWidget {
  const KassaNom({super.key, this.taille = 32, this.couleur});

  final double taille;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    return Text(
      'kassa',
      style: context.kassa.display.copyWith(
        fontSize: taille,
        height: 1,
        letterSpacing: kassaWordmarkSpacing(taille),
        color: couleur ?? context.kassa.ink,
      ),
      semanticsLabel: 'Kassa',
    );
  }
}

/// Logo complet : symbole + nom.
class KassaLogo extends StatelessWidget {
  const KassaLogo({super.key, this.taille = 32, this.surFonce = false});

  /// Hauteur du nom ; le symbole fait 1,15 fois cette taille.
  final double taille;
  final bool surFonce;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        KassaSymbole(
          taille: taille * 1.15,
          variante: surFonce
              ? KassaSymboleVariante.surFonce
              : KassaSymboleVariante.principal,
          fond: surFonce ? t.kassaDeep : null,
        ),
        SizedBox(width: taille * 0.25),
        KassaNom(taille: taille, couleur: surFonce ? t.onKassaDeep : t.ink),
      ],
    );
  }
}

/// SVG exacts du logo (viewBox 0 0 100 100). Mêmes fichiers dans assets/logo.
abstract final class KassaSvg {
  static const _recu =
      'M22 10 H78 A8 8 0 0 1 86 18 V84 L77 90 L68 84 L59 90 L50 84 L41 90 '
      'L32 84 L23 90 L14 84 V18 A8 8 0 0 1 22 10 Z';

  static String principal({String contourPiece = '#f6f8f5'}) =>
      '<svg viewBox="0 0 100 100">'
      '<path d="$_recu" fill="#1d7349"/>'
      '<path d="M38 26 V58 M60 26 L42 42 L60 58" fill="none" stroke="#ffffff" '
      'stroke-width="9" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M36 72 H64" stroke="#e2f3e8" stroke-width="5" stroke-linecap="round"/>'
      '<circle cx="82" cy="18" r="13" fill="#f2b233" stroke="$contourPiece" stroke-width="4"/>'
      '</svg>';

  static const petit =
      '<svg viewBox="0 0 100 100">'
      '<rect x="12" y="6" width="76" height="88" rx="14" fill="#1d7349"/>'
      '<path d="M38 28 V72 M64 28 L43 50 L64 72" fill="none" stroke="#ffffff" '
      'stroke-width="13" stroke-linecap="round" stroke-linejoin="round"/>'
      '</svg>';

  static String surFonce({String contourPiece = '#0e3b26'}) =>
      '<svg viewBox="0 0 100 100">'
      '<path d="$_recu" fill="#e2f3e8"/>'
      '<path d="M38 26 V58 M60 26 L42 42 L60 58" fill="none" stroke="$contourPiece" '
      'stroke-width="9" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M36 72 H64" stroke="#1d7349" stroke-width="5" stroke-linecap="round"/>'
      '<circle cx="82" cy="18" r="13" fill="#f2b233" stroke="$contourPiece" stroke-width="4"/>'
      '</svg>';

  static String pour(KassaSymboleVariante v, {required Color contourPiece}) {
    final hex =
        '#${(contourPiece.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    return switch (v) {
      KassaSymboleVariante.principal => principal(contourPiece: hex),
      KassaSymboleVariante.petit => petit,
      KassaSymboleVariante.surFonce => surFonce(contourPiece: hex),
    };
  }
}
