import 'package:flutter/material.dart';

import '../theme/kassa_tokens.dart';
import 'amount_text.dart';

/// Un chiffre clé du tableau de bord : libellé, grand montant, ligne d'aide.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.tone = AmountTone.neutre,
    this.hint,
  });

  final String label;
  final int value;
  final AmountTone tone;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(KassaSpace.s4),
        decoration: BoxDecoration(
          color: t.surfaceRaised,
          borderRadius: BorderRadius.circular(KassaRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: t.label.copyWith(color: t.inkMuted)),
            const SizedBox(height: KassaSpace.s1),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AmountText(value: value, tone: tone, size: AmountSize.lg),
            ),
            if (hint != null) ...[
              const SizedBox(height: KassaSpace.s1),
              Text(hint!, style: t.caption.copyWith(color: t.inkMuted)),
            ],
          ],
        ),
      ),
    );
  }
}
