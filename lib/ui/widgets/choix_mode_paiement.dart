import 'package:flutter/material.dart';

import '../../data/repositories/ventes_repository.dart';
import '../../domain/panier.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';
import 'libelles.dart';

/// Tuiles de choix du mode de paiement, deux par ligne (vente : les 4
/// modes ; encaissement d'une dette : espèces, MoMo, Orange Money).
class ChoixModePaiement extends StatelessWidget {
  const ChoixModePaiement({
    super.key,
    required this.modes,
    required this.mode,
    required this.onChanged,
  });

  final List<ModeChoisi> modes;
  final ModeChoisi mode;
  final ValueChanged<ModeChoisi> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final lignes = (modes.length + 1) ~/ 2;
    return Column(
      children: [
        for (var ligne = 0; ligne < lignes; ligne++) ...[
          if (ligne > 0) const SizedBox(height: KassaSpace.s2),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: KassaSpace.s2),
                  if (ligne * 2 + col >= modes.length)
                    const Expanded(child: SizedBox.shrink())
                  else
                    Expanded(
                      child: _TuileMode(
                        mode: modes[ligne * 2 + col],
                        choisi: mode == modes[ligne * 2 + col],
                        libelle: libelleMode(
                          l,
                          VentesRepository.codeMode(modes[ligne * 2 + col]),
                        ),
                        onTap: () => onChanged(modes[ligne * 2 + col]),
                        tokens: t,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TuileMode extends StatelessWidget {
  const _TuileMode({
    required this.mode,
    required this.choisi,
    required this.libelle,
    required this.onTap,
    required this.tokens,
  });

  final ModeChoisi mode;
  final bool choisi;
  final String libelle;
  final VoidCallback onTap;
  final KassaTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final couleur = choisi ? t.kassa : t.ink;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: choisi,
      button: true,
      child: Material(
        color: choisi ? t.kassaSoft : t.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KassaRadius.md),
          side: BorderSide(
            color: choisi ? t.kassa : t.line,
            width: KassaComposants.trait,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: KassaSize.buttonMain),
            child: Padding(
              padding: const EdgeInsets.all(KassaSpace.s2),
              child: Row(
                children: [
                  Icon(iconeMode(mode), color: couleur),
                  const SizedBox(width: KassaSpace.s2),
                  Expanded(
                    child: Text(
                      libelle,
                      style: t.label.copyWith(color: couleur),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
