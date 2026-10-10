import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/generated/app_localizations.dart';
import '../state/rapports.dart';
import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';

/// État de la sauvegarde sur l'en-tête de l'accueil (fond kassa-deep) :
/// une icône et un mot ; un toucher explique ce que cela veut dire.
/// Jamais le mot « synchronisation ».
class EtatSauvegardePuce extends StatelessWidget {
  const EtatSauvegardePuce({super.key, required this.etat});

  final EtatSauvegarde etat;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final (icone, libelle, aide) = switch (etat) {
      EtatSauvegarde.sauvegarde => (
        Symbols.cloud_done_rounded,
        l.saved,
        l.saveStateSavedHelp,
      ),
      EtatSauvegarde.enAttente => (
        Symbols.cloud_upload_rounded,
        l.saveStatePending,
        l.saveStatePendingHelp,
      ),
      EtatSauvegarde.surCeTelephone => (
        Symbols.smartphone_rounded,
        l.saveStateLocal,
        l.saveStateLocalHelp,
      ),
    };
    return Tooltip(
      message: aide,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 6),
      child: Semantics(
        button: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: KassaSize.touchMin),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icone,
                size: KassaComposants.iconeEtiquette,
                color: t.onKassaDeep,
              ),
              const SizedBox(width: KassaSpace.s1),
              Flexible(
                child: Text(
                  libelle,
                  style: t.label.copyWith(color: t.onKassaDeep),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
