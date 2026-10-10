import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/montant.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';
import 'contexte.dart';

/// Pavé numérique pour saisir un montant reçu ou une quantité.
///
/// [valeur] est une chaîne de chiffres (9 au plus) que l'appelant convertit
/// en entier. Touches de 56 px : 1-9, « 000 », 0 et Effacer (appui long :
/// tout effacer). L'affichage reprend le format des montants, à droite.
class NumPad extends StatelessWidget {
  const NumPad({super.key, required this.valeur, required this.onChanged});

  final String valeur;
  final ValueChanged<String> onChanged;

  static const effacer = 'effacer';
  static const _touches = [
    '1', '2', '3', //
    '4', '5', '6', //
    '7', '8', '9', //
    '000', '0', effacer,
  ];

  /// Nouvelle valeur après l'appui sur [touche]. Pas de zéro en tête,
  /// jamais plus de [KassaComposants.paveChiffresMax] chiffres.
  static String appuyer(String valeur, String touche) {
    if (touche == effacer) {
      return valeur.isEmpty ? '' : valeur.substring(0, valeur.length - 1);
    }
    final base = valeur == '0' ? '' : valeur;
    if (base.isEmpty && touche.startsWith('0')) return touche == '0' ? '0' : '';
    final suivante = base + touche;
    return suivante.length > KassaComposants.paveChiffresMax
        ? valeur
        : suivante;
  }

  /// Montant saisi en entier (0 si vide).
  static int enEntier(String valeur) => int.tryParse(valeur) ?? 0;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final montant = Montant.format(enEntier(valeur), langueDe(context));

    return Container(
      padding: const EdgeInsets.all(KassaSpace.s4),
      decoration: BoxDecoration(
        color: t.surfaceRaised,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KassaRadius.lg),
        ),
        boxShadow: kassaShadowSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                montant,
                style: t.amountLg,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(height: KassaSpace.s4),
          for (var ligne = 0; ligne < 4; ligne++) ...[
            if (ligne > 0) const SizedBox(height: KassaSpace.s2),
            Row(
              children: [
                for (var col = 0; col < 3; col++) ...[
                  if (col > 0) const SizedBox(width: KassaSpace.s2),
                  Expanded(
                    child: _Touche(
                      touche: _touches[ligne * 3 + col],
                      onAppui: (touche) {
                        HapticFeedback.selectionClick();
                        onChanged(appuyer(valeur, touche));
                      },
                      onToutEffacer: () {
                        HapticFeedback.mediumImpact();
                        onChanged('');
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Touche extends StatelessWidget {
  const _Touche({
    required this.touche,
    required this.onAppui,
    required this.onToutEffacer,
  });

  final String touche;
  final ValueChanged<String> onAppui;
  final VoidCallback onToutEffacer;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final l = AppLocalizations.of(context);
    final estEffacer = touche == NumPad.effacer;

    final contenu = estEffacer
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.backspace_rounded,
                size: KassaComposants.iconeBouton,
                color: t.dette,
              ),
              const SizedBox(width: KassaSpace.s1),
              Flexible(
                child: Text(l.erase, style: t.bouton.copyWith(color: t.dette)),
              ),
            ],
          )
        : Text(touche, style: t.touchePave.copyWith(color: t.ink));

    return Semantics(
      button: true,
      label: estEffacer ? l.erase : touche,
      excludeSemantics: true,
      child: Material(
        color: t.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(KassaRadius.md)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onAppui(touche),
          onLongPress: estEffacer ? onToutEffacer : null,
          splashColor: t.kassaSoft,
          highlightColor: t.kassaSoft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: KassaSize.buttonMain),
            child: Center(child: contenu),
          ),
        ),
      ),
    );
  }
}
