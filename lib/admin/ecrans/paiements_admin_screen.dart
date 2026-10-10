import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/heure_douala.dart';
import '../../core/montant.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/theme/kassa_tokens.dart';
import '../../ui/widgets/contexte.dart';
import '../../ui/widgets/kassa_badge.dart';
import '../../ui/widgets/kassa_button.dart';
import '../donnees/serveur_admin.dart';
import '../etat/etat_admin.dart';
import '../ui/communs.dart';

/// Paiements Notch Pay de l'abonnement, filtrés par statut.
class PaiementsAdminScreen extends ConsumerStatefulWidget {
  const PaiementsAdminScreen({super.key});

  @override
  ConsumerState<PaiementsAdminScreen> createState() =>
      _PaiementsAdminScreenState();
}

class _PaiementsAdminScreenState extends ConsumerState<PaiementsAdminScreen> {
  String? _statut;
  var _pages = 1;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final pages = Pages<PaiementAdmin>([
      for (var i = 0; i < _pages; i++)
        ref.watch(
          paiementsAdminProvider((statut: _statut, decalage: i * tailleDePage)),
        ),
    ]);
    final filtres = [
      (null, l.adminPayAll),
      ('reussi', l.adminPaySuccess),
      ('en_attente', l.adminPayPending),
      ('echoue', l.adminPayFailed),
    ];

    return ListView(
      padding: const EdgeInsets.all(KassaSpace.s4),
      children: [
        Wrap(
          spacing: KassaSpace.s2,
          runSpacing: KassaSpace.s2,
          children: [
            for (final (statut, libelle) in filtres)
              ChoiceChip(
                label: Text(libelle),
                selected: _statut == statut,
                showCheckmark: false,
                onSelected: (_) => setState(() {
                  _statut = statut;
                  _pages = 1;
                }),
              ),
          ],
        ),
        const SizedBox(height: KassaSpace.s4),
        if (pages.total == 0)
          Padding(
            padding: const EdgeInsets.all(KassaSpace.s4),
            child: Text(l.adminNoPayments, style: t.body),
          )
        else if (pages.total != null) ...[
          Semantics(
            container: true,
            child: Text(
              l.adminShownOf(pages.elements.length, pages.total!),
              style: t.caption.copyWith(color: t.ink),
            ),
          ),
          const SizedBox(height: KassaSpace.s2),
        ],
        for (final p in pages.elements) _LignePaiement(paiement: p),
        if (pages.enErreur)
          ErreurAdmin(reessayer: () => ref.invalidate(paiementsAdminProvider))
        else if (pages.enChargement)
          const ChargementAdmin()
        else if (pages.plusAAfficher)
          Padding(
            padding: const EdgeInsets.only(top: KassaSpace.s2),
            child: KassaButton(
              label: l.adminShowMore,
              icon: Symbols.expand_more_rounded,
              variant: KassaButtonVariant.secondary,
              onPressed: () => setState(() => _pages++),
            ),
          ),
      ],
    );
  }
}

class _LignePaiement extends StatelessWidget {
  const _LignePaiement({required this.paiement});

  final PaiementAdmin paiement;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final p = paiement;
    final (statut, ton, icone) = switch (p.statut) {
      'reussi' => (
        l.adminPayStatusSuccess,
        KassaBadgeTone.kassa,
        Symbols.check_circle_rounded,
      ),
      'echoue' => (
        l.adminPayStatusFailed,
        KassaBadgeTone.dette,
        Symbols.cancel_rounded,
      ),
      _ => (
        l.adminPayStatusPending,
        KassaBadgeTone.alerte,
        Symbols.hourglass_top_rounded,
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: KassaSpace.s2),
      child: MergeSemantics(
        child: Container(
          padding: const EdgeInsets.all(KassaSpace.s4),
          decoration: BoxDecoration(
            color: t.surfaceRaised,
            borderRadius: BorderRadius.circular(KassaRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.boutiqueNom, style: t.label.copyWith(color: t.ink)),
              Text(
                '${p.operateur == 'cm.orange' ? l.payOrange : l.payMomo}'
                ' · ${HeureDouala.dateCourte(p.creeLe, langue)} '
                '${HeureDouala.heure(p.creeLe, langue)}',
                style: t.caption.copyWith(color: t.inkMuted),
              ),
              const SizedBox(height: KassaSpace.s1),
              Wrap(
                spacing: KassaSpace.s4,
                runSpacing: KassaSpace.s1,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    Montant.format(p.montant, langue),
                    style: t.amount.copyWith(color: t.ink),
                  ),
                  KassaBadge(label: statut, tone: ton, icon: icone),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
