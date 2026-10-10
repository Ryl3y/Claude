import 'package:flutter/material.dart';

import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';

/// Variantes du bouton (fiche « Button » de la charte).
enum KassaButtonVariant {
  /// Fond kassa : l'action principale, une seule par écran.
  primary,

  /// Contour line, texte kassa : les autres actions.
  secondary,

  /// Fond or : action à faire remarquer (« Passer à Pro »).
  or,

  /// Fond dette-soft, texte dette : annuler une vente, supprimer.
  danger,

  /// Texte seul : actions discrètes (« Plus tard »).
  ghost,
}

/// `normal` : 48 px de haut · `main` : 56 px, pour l'action du bas de l'écran.
enum KassaButtonSize { normal, main }

/// Bouton Kassa : un verbe, avec une icône quand elle aide.
///
/// Le libellé passe à la ligne plutôt que d'être coupé (une langue peut être
/// 30 % plus longue que l'autre). Sans [onPressed], le bouton est désactivé.
class KassaButton extends StatelessWidget {
  const KassaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KassaButtonVariant.primary,
    this.size = KassaButtonSize.normal,
    this.icon,
    this.fullWidth = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final KassaButtonVariant variant;
  final KassaButtonSize size;
  final IconData? icon;
  final bool fullWidth;

  /// Libellé plus précis pour le lecteur d'écran (« Réappro Riz 5 kg »)
  /// quand plusieurs boutons portent le même mot.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final principal = size == KassaButtonSize.main;
    final (fond, texte, bordure) = switch (variant) {
      KassaButtonVariant.primary => (t.kassa, t.onKassa, null),
      KassaButtonVariant.secondary => (t.surfaceRaised, t.kassa, t.line),
      KassaButtonVariant.or => (t.or, t.onOr, null),
      KassaButtonVariant.danger => (t.detteSoft, t.dette, null),
      KassaButtonVariant.ghost => (Colors.transparent, t.kassa, null),
    };
    final hauteur = principal ? KassaSize.buttonMain : KassaSize.touchMin;
    final style = (principal ? t.boutonPrincipal : t.bouton).copyWith(
      color: texte,
    );

    final bouton = TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(fond),
        foregroundColor: WidgetStatePropertyAll(texte),
        overlayColor: WidgetStateProperty.resolveWith(
          (etats) => etats.contains(WidgetState.pressed)
              ? texte.withValues(alpha: 0.12)
              : null,
        ),
        minimumSize: WidgetStatePropertyAll(Size(KassaSize.touchMin, hauteur)),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: principal ? KassaSpace.s6 : KassaSpace.s4,
            vertical: KassaSpace.s2,
          ),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(KassaRadius.md)),
          ),
        ),
        side: WidgetStateProperty.resolveWith((etats) {
          if (etats.contains(WidgetState.focused)) {
            return BorderSide(color: t.focus, width: KassaComposants.trait);
          }
          return bordure == null
              ? BorderSide.none
              : BorderSide(color: bordure, width: KassaComposants.trait);
        }),
        textStyle: WidgetStatePropertyAll(style),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: principal ? KassaSize.icon : KassaComposants.iconeBouton,
              color: texte,
            ),
            const SizedBox(width: KassaSpace.s2),
          ],
          Flexible(
            child: Text(label, textAlign: TextAlign.center, style: style),
          ),
        ],
      ),
    );

    final nomme = semanticLabel == null
        ? bouton
        : Semantics(
            label: semanticLabel,
            button: true,
            enabled: onPressed != null,
            onTap: onPressed,
            excludeSemantics: true,
            child: bouton,
          );
    final dimensionne = fullWidth
        ? SizedBox(width: double.infinity, child: nomme)
        : nomme;
    return onPressed == null
        ? Opacity(opacity: KassaComposants.opaciteDesactive, child: dimensionne)
        : dimensionne;
  }
}
