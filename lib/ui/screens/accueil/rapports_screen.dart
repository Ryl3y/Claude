import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/heure_douala.dart';
import '../../../core/montant.dart';
import '../../../core/quantite.dart';
import '../../../data/repositories/rapports_repository.dart';
import '../../../domain/periode.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../state/rapports.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';

/// Nom d'une période : « Aujourd'hui », « La semaine dernière »,
/// « Du 29 sept. au 5 oct. », « Septembre 2026 »…
String libellePeriode(AppLocalizations l, String langue, Periode p) {
  final actuelle = Periode.actuelle(p.type);
  final debut = HeureDouala.versDouala(p.debut);
  return switch (p.type) {
    TypePeriode.jour when p == actuelle => l.today,
    TypePeriode.jour when p == actuelle.precedente => l.yesterday,
    TypePeriode.jour => toBeginningOfSentenceCase(
      DateFormat('EEEE d MMM', langue).format(debut),
    ),
    TypePeriode.semaine when p == actuelle => l.thisWeek,
    TypePeriode.semaine when p == actuelle.precedente => l.lastWeek,
    TypePeriode.semaine => l.weekRange(
      HeureDouala.dateCourte(p.debut, langue),
      HeureDouala.dateCourte(p.fin.subtract(const Duration(hours: 1)), langue),
    ),
    TypePeriode.mois when p == actuelle => l.thisMonth,
    TypePeriode.mois when p == actuelle.precedente => l.lastMonth,
    TypePeriode.mois => toBeginningOfSentenceCase(
      DateFormat('MMMM y', langue).format(debut),
    ),
  };
}

/// Écran 14 : rapports du jour, de la semaine ou du mois (et des périodes
/// passées) : ventes, bénéfice, argent reçu, modes de paiement, meilleurs
/// produits.
class RapportsScreen extends ConsumerStatefulWidget {
  const RapportsScreen({super.key});

  @override
  ConsumerState<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends ConsumerState<RapportsScreen> {
  var _periode = Periode.actuelle(TypePeriode.jour);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final rapport = ref.watch(rapportProvider(_periode));

    return Scaffold(
      appBar: AppBar(title: Text(l.reportsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: ListView(
            padding: const EdgeInsets.all(KassaSpace.s4),
            children: [
              Wrap(
                spacing: KassaSpace.s2,
                runSpacing: KassaSpace.s2,
                children: [
                  for (final (type, libelle) in [
                    (TypePeriode.jour, l.periodDay),
                    (TypePeriode.semaine, l.periodWeek),
                    (TypePeriode.mois, l.periodMonth),
                  ])
                    ChoiceChip(
                      label: Text(libelle),
                      selected: _periode.type == type,
                      showCheckmark: false,
                      onSelected: (_) =>
                          setState(() => _periode = Periode.actuelle(type)),
                    ),
                ],
              ),
              const SizedBox(height: KassaSpace.s2),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _periode = _periode.precedente),
                    icon: const Icon(Symbols.chevron_left_rounded),
                    label: Text(
                      l.periodEarlier,
                      semanticsLabel: l.periodEarlierHint,
                    ),
                  ),
                  Expanded(
                    child: Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        libellePeriode(l, langue, _periode),
                        style: t.label.copyWith(
                          fontSize: t.body.fontSize,
                          height: t.body.height,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _periode.estEnCours
                        ? null
                        : () => setState(() => _periode = _periode.suivante),
                    icon: Text(
                      l.periodLater,
                      semanticsLabel: l.periodLaterHint,
                    ),
                    label: const Icon(Symbols.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: KassaSpace.s4),
              rapport.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(KassaSpace.s6),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (erreur, pile) =>
                    EtatVide(icone: Symbols.error_rounded, titre: l.loadError),
                data: (r) => _Contenu(rapport: r),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Contenu extends StatelessWidget {
  const _Contenu({required this.rapport});

  final Rapport rapport;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final r = rapport;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TuilesCoteACote(
          gauche: StatTile(
            label: l.salesLabel,
            value: r.total,
            tone: AmountTone.encaisse,
            hint: l.salesCount(r.nombreVentes),
          ),
          droite: StatTile(
            label: l.profit,
            value: r.benefice,
            hint: r.nombreVentes == 0
                ? null
                : l.averageSale(
                    Montant.format(r.panierMoyen, langue, court: true),
                  ),
          ),
        ),
        if (r.annulees > 0) ...[
          const SizedBox(height: KassaSpace.s2),
          Text(
            l.cancelledNotCounted(r.annulees),
            style: t.caption.copyWith(color: t.inkMuted),
          ),
        ],
        const SizedBox(height: KassaSpace.s6),
        _Section(
          titre: l.moneyReceivedTitle,
          enfants: [
            _Ligne(
              libelle: l.paidAtSale,
              valeur: AmountText(
                value: r.payeSurVentes,
                tone: AmountTone.encaisse,
                short: true,
              ),
            ),
            _Ligne(
              libelle: l.debtsCollected,
              valeur: AmountText(
                value: r.versements,
                tone: AmountTone.encaisse,
                short: true,
              ),
            ),
            const Divider(),
            _Ligne(
              libelle: l.totalReceived,
              fort: true,
              valeur: AmountText(
                value: r.totalEncaisse,
                tone: AmountTone.encaisse,
              ),
            ),
            if (r.venduACredit > 0) ...[
              const SizedBox(height: KassaSpace.s2),
              _Ligne(
                libelle: l.soldOnCredit,
                valeur: AmountText(
                  value: r.venduACredit,
                  tone: AmountTone.dette,
                  short: true,
                ),
              ),
            ],
          ],
        ),
        if (r.parMode.isNotEmpty) ...[
          const SizedBox(height: KassaSpace.s6),
          _Section(
            titre: l.salesByMode,
            enfants: [
              for (final mode in RapportsRepository.ordreModes)
                if (r.parMode.containsKey(mode))
                  _Ligne(
                    libelle: libelleMode(l, mode),
                    valeur: AmountText(value: r.parMode[mode]!, short: true),
                  ),
            ],
          ),
        ],
        const SizedBox(height: KassaSpace.s6),
        Semantics(header: true, child: Text(l.bestSellers, style: t.title)),
        const SizedBox(height: KassaSpace.s2),
        if (r.top.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: KassaSpace.s4),
            child: Text(
              l.reportEmpty,
              style: t.body.copyWith(color: t.inkMuted),
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(KassaRadius.md),
            child: Column(
              children: [
                for (final (i, p) in r.top.indexed) ...[
                  if (i > 0) const Divider(),
                  _LigneTop(rang: i + 1, produit: p),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.titre, required this.enfants});

  final String titre;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text(titre, style: t.title)),
        const SizedBox(height: KassaSpace.s2),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KassaSpace.s4,
            vertical: KassaSpace.s2,
          ),
          decoration: BoxDecoration(
            color: t.surfaceRaised,
            borderRadius: BorderRadius.circular(KassaRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: enfants,
          ),
        ),
      ],
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.libelle,
    required this.valeur,
    this.fort = false,
  });

  final String libelle;
  final Widget valeur;
  final bool fort;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KassaSpace.s2),
      child: MergeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Text(
                libelle,
                style: fort
                    ? t.label.copyWith(color: t.ink)
                    : t.body.copyWith(color: t.inkMuted),
              ),
            ),
            const SizedBox(width: KassaSpace.s2),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(fit: BoxFit.scaleDown, child: valeur),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneTop extends StatelessWidget {
  const _LigneTop({required this.rang, required this.produit});

  final int rang;
  final TopProduit produit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final quantite = [
      Quantite.format(produit.quantite, langue),
      if (produit.unite.isNotEmpty) produit.unite,
    ].join(' ');

    return Material(
      color: t.surfaceRaised,
      child: MergeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KassaSpace.s4,
            vertical: KassaSpace.s2,
          ),
          child: Row(
            children: [
              // Chiffres tabulaires : les noms restent alignés (N°1, N°2…).
              Text(
                l.bestSellerRank(rang),
                style: t.label.copyWith(
                  color: t.inkMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: KassaSpace.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produit.nom,
                      style: t.label.copyWith(
                        fontSize: t.body.fontSize,
                        height: t.body.height,
                      ),
                    ),
                    Text(
                      l.bestSellerDetail(
                        quantite,
                        Montant.format(produit.benefice, langue, court: true),
                      ),
                      style: t.caption.copyWith(color: t.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KassaSpace.s2),
              AmountText(value: produit.montant, short: true),
            ],
          ),
        ),
      ),
    );
  }
}
