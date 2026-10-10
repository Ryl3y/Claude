import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/montant.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/theme/kassa_tokens.dart';
import '../../ui/widgets/contexte.dart';
import '../../ui/widgets/kassa_button.dart';
import '../donnees/serveur_admin.dart';
import '../etat/etat_admin.dart';
import '../ui/carte_cameroun.dart';
import '../ui/communs.dart';
import '../ui/graphiques.dart';

/// Tableau de bord : chiffres clés, inscriptions, revenus, zones couvertes.
class TableauBordScreen extends ConsumerWidget {
  const TableauBordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final chiffres = ref.watch(chiffresAdminProvider);
    final zones = ref.watch(zonesAdminProvider);
    final large = MediaQuery.sizeOf(context).width >= largeurBureau;

    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(chiffresAdminProvider)
          ..invalidate(zonesAdminProvider);
        await ref.read(chiffresAdminProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(KassaSpace.s4),
        children: [
          // Sur ordinateur, pas de « tirer pour actualiser » à la souris.
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: KassaButton(
              label: l.adminRefresh,
              icon: Symbols.refresh_rounded,
              variant: KassaButtonVariant.ghost,
              onPressed: () => ref
                ..invalidate(chiffresAdminProvider)
                ..invalidate(zonesAdminProvider),
            ),
          ),
          const SizedBox(height: KassaSpace.s2),
          switch (chiffres) {
            AsyncData(:final value) => _Contenu(
              chiffres: value,
              large: large,
              carte: CarteAdmin(
                titre: l.adminMapTitle,
                child: switch (zones) {
                  AsyncData(value: final z) =>
                    z.isEmpty
                        ? Text(l.adminMapEmpty)
                        : CarteCameroun(zones: z, hauteur: 360),
                  AsyncError() => ErreurAdmin(
                    reessayer: () => ref.invalidate(zonesAdminProvider),
                  ),
                  _ => const ChargementAdmin(),
                },
              ),
            ),
            AsyncError() => ErreurAdmin(
              reessayer: () => ref.invalidate(chiffresAdminProvider),
            ),
            _ => const ChargementAdmin(),
          },
        ],
      ),
    );
  }
}

class _Contenu extends StatelessWidget {
  const _Contenu({
    required this.chiffres,
    required this.large,
    required this.carte,
  });

  final ChiffresAdmin chiffres;
  final bool large;
  final Widget carte;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final langue = langueDe(context);
    final c = chiffres;
    final nombre = NumberFormat.decimalPattern(langue);

    final tuiles = [
      _Tuile(
        icone: Symbols.storefront_rounded,
        libelle: l.adminStatShops,
        valeur: Montant.sansEspaceFine(nombre.format(c.boutiques)),
        aide: l.adminStatNewShops(c.nouvelles7Jours),
      ),
      _Tuile(
        icone: Symbols.hourglass_top_rounded,
        libelle: l.adminStatTrials,
        valeur: Montant.sansEspaceFine(nombre.format(c.essais)),
      ),
      _Tuile(
        icone: Symbols.workspace_premium_rounded,
        libelle: l.adminStatPro,
        valeur: Montant.sansEspaceFine(nombre.format(c.pro)),
      ),
      _Tuile(
        icone: Symbols.lock_clock_rounded,
        libelle: l.adminStatEnded,
        valeur: Montant.sansEspaceFine(nombre.format(c.termines)),
        aide: l.adminStatEndedHint,
      ),
      _Tuile(
        icone: Symbols.payments_rounded,
        libelle: l.adminStatRevenue,
        valeur: Montant.format(c.revenusMois, langue),
        aide: l.adminStatPayments(c.paiementsMois),
        argent: true,
      ),
    ];

    final inscriptions = CarteAdmin(
      titre: l.adminChartSignups,
      child: GraphiqueSerie.courbe(
        valeurs: [for (final p in c.inscriptions) p.$2],
        etiquettes: [
          // Une date par semaine, en partant d'aujourd'hui (pas de collision).
          for (final (i, p) in c.inscriptions.indexed)
            (c.inscriptions.length - 1 - i) % 7 == 0
                ? DateFormat('d MMM', langue).format(p.$1)
                : '',
        ],
        detail: (i) => l.adminSignupsOn(
          DateFormat('EEE d MMM', langue).format(c.inscriptions[i].$1),
          c.inscriptions[i].$2,
        ),
        graduation: (v) => nombre.format(v.round()),
        resume: l.adminChartSignupsSummary(
          c.inscriptions.fold(0, (s, p) => s + p.$2),
        ),
      ),
    );
    final revenus = CarteAdmin(
      titre: l.adminChartRevenue,
      child: GraphiqueSerie.barres(
        valeurs: [for (final p in c.revenus) p.$2],
        etiquettes: [
          for (final p in c.revenus) DateFormat('MMM', langue).format(p.$1),
        ],
        detail: (i) => l.adminRevenueOn(
          DateFormat('MMMM y', langue).format(c.revenus[i].$1),
          Montant.format(c.revenus[i].$2, langue),
        ),
        graduation: (v) => Montant.format(v.round(), langue, court: true),
        resume: l.adminChartRevenueSummary(
          Montant.format(c.revenus.fold(0, (s, p) => s + p.$2), langue),
        ),
      ),
    );

    const ecart = SizedBox(width: KassaSpace.s4, height: KassaSpace.s4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, contraintes) {
            final colonnes = (contraintes.maxWidth / 190).floor().clamp(1, 5);
            final largeur =
                (contraintes.maxWidth - KassaSpace.s4 * (colonnes - 1)) /
                colonnes;
            return Wrap(
              spacing: KassaSpace.s4,
              runSpacing: KassaSpace.s4,
              children: [
                for (final t in tuiles) SizedBox(width: largeur, child: t),
              ],
            );
          },
        ),
        ecart,
        if (large)
          // Les deux cartes ont la même hauteur : titre + graphique fixe.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: inscriptions),
              ecart,
              Expanded(flex: 2, child: revenus),
            ],
          )
        else ...[
          inscriptions,
          ecart,
          revenus,
        ],
        ecart,
        carte,
      ],
    );
  }
}

class _Tuile extends StatelessWidget {
  const _Tuile({
    required this.icone,
    required this.libelle,
    required this.valeur,
    this.aide,
    this.argent = false,
  });

  final IconData icone;
  final String libelle;
  final String valeur;
  final String? aide;
  final bool argent;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(KassaSpace.s4),
        decoration: BoxDecoration(
          color: t.surfaceRaised,
          borderRadius: BorderRadius.circular(KassaRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: t.inkMuted),
                const SizedBox(width: KassaSpace.s2),
                Expanded(
                  child: Text(
                    libelle,
                    style: t.label.copyWith(color: t.inkMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KassaSpace.s2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valeur,
                style: t.amountLg.copyWith(color: argent ? t.kassa : t.ink),
              ),
            ),
            if (aide != null) ...[
              const SizedBox(height: KassaSpace.s1),
              Text(aide!, style: t.caption.copyWith(color: t.inkMuted)),
            ],
          ],
        ),
      ),
    );
  }
}
