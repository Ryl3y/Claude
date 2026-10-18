import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../brand/kassa_logo.dart';
import '../../router.dart';
import '../../state/langue.dart';
import '../../state/session.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/widgets.dart';

/// Écran 1 : bienvenue, sur le vert profond de la marque. Choix de la
/// langue et « Commencer ».
class BienvenueScreen extends ConsumerWidget {
  const BienvenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final serveur = ref.watch(inscriptionProvider) != null;

    return Scaffold(
      backgroundColor: t.kassaDeep,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: KassaComposants.largeurContenuMax,
            ),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(KassaSpace.s4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: _Langues(),
                        ),
                        const Spacer(),
                        const KassaLogo(taille: 40, surFonce: true),
                        const SizedBox(height: KassaSpace.s8),
                        Semantics(
                          header: true,
                          child: Text(
                            l.welcomeTitle,
                            style: t.display.copyWith(color: t.onKassaDeep),
                          ),
                        ),
                        const SizedBox(height: KassaSpace.s4),
                        Text(
                          l.welcomeBody,
                          style: t.body.copyWith(color: t.onKassaDeep),
                        ),
                        const Spacer(),
                        if (!serveur) ...[
                          Text(
                            l.serverMissing,
                            style: t.label.copyWith(color: t.onKassaDeep),
                          ),
                          const SizedBox(height: KassaSpace.s2),
                        ],
                        KassaButton(
                          label: l.start,
                          icon: Symbols.arrow_forward_rounded,
                          size: KassaButtonSize.main,
                          fullWidth: true,
                          onPressed: serveur
                              ? () => context.push(Chemins.connexion)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Français / English en haut à droite, lisibles sur le vert profond.
class _Langues extends ConsumerWidget {
  const _Langues();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final active = Localizations.localeOf(context).languageCode;
    return Wrap(
      spacing: KassaSpace.s2,
      children: [
        for (final (code, nom) in [
          ('fr', l.languageFrench),
          ('en', l.languageEnglish),
        ])
          Semantics(
            inMutuallyExclusiveGroup: true,
            selected: code == active,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: t.onKassaDeep,
                minimumSize: const Size(KassaSize.touchMin, KassaSize.touchMin),
              ),
              onPressed: () =>
                  ref.read(langueProvider.notifier).choisir(Locale(code)),
              icon: Icon(
                code == active
                    ? Symbols.radio_button_checked_rounded
                    : Symbols.radio_button_unchecked_rounded,
                size: KassaComposants.iconeBouton,
              ),
              label: Text(nom),
            ),
          ),
      ],
    );
  }
}
