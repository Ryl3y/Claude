import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/generated/app_localizations.dart';
import '../state/langue.dart';
import '../theme/kassa_tokens.dart';

/// Choix de la langue : celle du téléphone, français ou anglais.
/// Le choix est gardé sur le téléphone.
class ChoixLangue extends ConsumerWidget {
  const ChoixLangue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final choix = ref.watch(langueProvider)?.languageCode ?? '';
    final options = [
      ('', l.languagePhone),
      ('fr', l.languageFrench),
      ('en', l.languageEnglish),
    ];
    return Column(
      children: [
        for (final (code, nom) in options)
          MergeSemantics(
            child: Semantics(
              inMutuallyExclusiveGroup: true,
              checked: code == choix,
              child: InkWell(
                borderRadius: BorderRadius.circular(KassaRadius.sm),
                onTap: () => ref
                    .read(langueProvider.notifier)
                    .choisir(code.isEmpty ? null : Locale(code)),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: KassaSize.touchMin,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: KassaSpace.s2,
                  ),
                  decoration: BoxDecoration(
                    color: code == choix ? t.kassaSoft : null,
                    borderRadius: BorderRadius.circular(KassaRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        code == choix
                            ? Symbols.radio_button_checked_rounded
                            : Symbols.radio_button_unchecked_rounded,
                        color: code == choix ? t.kassa : t.inkMuted,
                      ),
                      const SizedBox(width: KassaSpace.s2),
                      Expanded(child: Text(nom, style: t.body)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
