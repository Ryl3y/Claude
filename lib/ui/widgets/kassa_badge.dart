import 'package:flutter/material.dart';

import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';

/// Tons d'étiquette (fiche « Badge » de la charte).
enum KassaBadgeTone {
  /// Catégorie, unité.
  neutre,

  /// « Payé », « Sauvegardé ».
  kassa,

  /// « Pro », nouveauté.
  or,

  /// « Stock bas » : or-ink sur or-soft.
  alerte,

  /// « Doit », « Annulée ».
  dette,
}

/// Une courte étiquette d'état, un ou deux mots, jamais une action.
class KassaBadge extends StatelessWidget {
  const KassaBadge({
    super.key,
    required this.label,
    this.tone = KassaBadgeTone.neutre,
    this.icon,
  });

  final String label;
  final KassaBadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final (fond, texte, bordure) = switch (tone) {
      KassaBadgeTone.neutre => (t.surface, t.inkMuted, t.line),
      KassaBadgeTone.kassa => (t.kassaSoft, t.kassa, null),
      KassaBadgeTone.or => (t.or, t.onOr, null),
      KassaBadgeTone.alerte => (t.orSoft, t.orInk, null),
      KassaBadgeTone.dette => (t.detteSoft, t.dette, null),
    };
    return Container(
      constraints: const BoxConstraints(
        minHeight: KassaComposants.badgeHauteur,
      ),
      padding: const EdgeInsets.symmetric(horizontal: KassaSpace.s2),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(KassaRadius.sm),
        border: bordure == null
            ? null
            : Border.all(color: bordure, width: KassaComposants.filet),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: KassaComposants.iconeEtiquette, color: texte),
            const SizedBox(width: KassaSpace.s1),
          ],
          Flexible(
            child: Text(label, style: t.etiquette.copyWith(color: texte)),
          ),
        ],
      ),
    );
  }
}
