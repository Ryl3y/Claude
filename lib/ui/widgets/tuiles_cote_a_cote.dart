import 'package:flutter/material.dart';

import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';

/// Deux tuiles côte à côte, de même hauteur ; l'une sous l'autre quand le
/// téléphone grossit beaucoup le texte, pour que les montants restent lisibles.
class TuilesCoteACote extends StatelessWidget {
  const TuilesCoteACote({
    super.key,
    required this.gauche,
    required this.droite,
  });

  final Widget gauche;
  final Widget droite;

  @override
  Widget build(BuildContext context) {
    final grandTexte =
        MediaQuery.textScalerOf(context).scale(KassaComposants.texteRepere) >
        KassaComposants.texteRepere * KassaComposants.echelleEmpilement;
    if (grandTexte) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          gauche,
          const SizedBox(height: KassaSpace.s2),
          droite,
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: gauche),
          const SizedBox(width: KassaSpace.s2),
          Expanded(child: droite),
        ],
      ),
    );
  }
}
