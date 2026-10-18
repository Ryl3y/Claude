import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/montant.dart';
import '../../../domain/abonnement.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/abonnement.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';

/// À appeler avant chaque enregistrement (vente, stock, client, dette).
/// Essai ou Pro en cours : vrai. Terminé : montre « Passer à Pro » et
/// renvoie faux ; l'app reste consultable.
Future<bool> ecritureAutorisee(BuildContext context, WidgetRef ref) async {
  final etat = ref.read(abonnementProvider).value;
  if (etat is! AbonnementTermine) return true;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FinAbonnement(etat: etat),
  );
  return false;
}

class _FinAbonnement extends StatelessWidget {
  const _FinAbonnement({required this.etat});

  final AbonnementTermine etat;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final prix = Montant.format(prixProFcfa, langueDe(context));
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(KassaSpace.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Symbols.lock_clock_rounded, color: t.orInk),
                const SizedBox(width: KassaSpace.s2),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      etat.etaitPro ? l.proEnded : l.trialEnded,
                      style: t.title,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KassaSpace.s2),
            Text(l.readOnlyBody(prix), style: t.body),
            const SizedBox(height: KassaSpace.s6),
            KassaButton(
              label: l.goPro,
              icon: Symbols.workspace_premium_rounded,
              size: KassaButtonSize.main,
              fullWidth: true,
              onPressed: () {
                final routeur = GoRouter.of(context);
                Navigator.of(context).pop();
                routeur.push(Chemins.abonnement);
              },
            ),
            const SizedBox(height: KassaSpace.s2),
            KassaButton(
              label: l.later,
              variant: KassaButtonVariant.ghost,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
