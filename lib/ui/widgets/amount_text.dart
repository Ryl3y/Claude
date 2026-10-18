import 'package:flutter/material.dart';

import '../../core/montant.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';
import 'contexte.dart';

/// `neutre` : ink · `encaisse` : vert kassa · `dette` : rouge, précédé de « Doit ».
enum AmountTone { neutre, encaisse, dette }

/// `md` : montants des cartes et listes · `lg` : total, chiffres du tableau de bord.
enum AmountSize { md, lg }

/// Un montant en FCFA, toujours formaté de la même façon, chiffres tabulaires.
///
/// Reçoit un entier, jamais un texte déjà formaté. Une dette est toujours
/// précédée de « Doit » / « Owes » : le sens ne dépend pas de la couleur seule.
class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.value,
    this.tone = AmountTone.neutre,
    this.size = AmountSize.md,
    this.short = false,
  });

  final int value;
  final AmountTone tone;
  final AmountSize size;

  /// « 12 500 F » au lieu de « 12 500 FCFA ».
  final bool short;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final l = AppLocalizations.of(context);
    final couleur = switch (tone) {
      AmountTone.neutre => t.ink,
      AmountTone.encaisse => t.kassa,
      AmountTone.dette => t.dette,
    };
    final style = (size == AmountSize.lg ? t.amountLg : t.amount).copyWith(
      color: couleur,
    );
    final signe = value < 0 ? '−' : '';
    final montant =
        '$signe${Montant.format(value.abs(), langueDe(context), court: short)}';

    if (tone != AmountTone.dette) {
      return Text(montant, style: style, softWrap: false);
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${l.owesLabel} ', style: t.prefixeMontant(style)),
          TextSpan(text: montant),
        ],
      ),
      style: style,
      softWrap: false,
      semanticsLabel: l.owes(montant),
    );
  }
}
