import 'package:flutter/material.dart';

import '../theme/kassa_tokens.dart';
import 'amount_text.dart';

/// Résultat d'un calcul sous le pavé : monnaie à rendre, reste à payer.
/// Fond dette-soft ou kassa-soft selon [tone] ; annoncé quand il change.
class ResultatMontant extends StatelessWidget {
  const ResultatMontant({
    super.key,
    required this.libelle,
    required this.montant,
    required this.tone,
  });

  final String libelle;
  final int montant;
  final AmountTone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return MergeSemantics(
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(KassaSpace.s4),
          decoration: BoxDecoration(
            color: tone == AmountTone.dette ? t.detteSoft : t.kassaSoft,
            borderRadius: BorderRadius.circular(KassaRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(libelle, style: t.label.copyWith(color: t.ink)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AmountText(
                  value: montant,
                  tone: montant == 0 ? AmountTone.neutre : tone,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
