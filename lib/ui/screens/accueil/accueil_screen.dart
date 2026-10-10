import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/heure_douala.dart';
import '../../../core/montant.dart';
import '../../../core/quantite.dart';
import '../../../data/db/kassa_database.dart';
import '../../../domain/abonnement.dart';
import '../../../domain/calculs.dart';
import '../../../domain/periode.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../brand/kassa_logo.dart';
import '../../router.dart';
import '../../state/abonnement.dart';
import '../abonnement/garde_abonnement.dart';
import '../../state/produits.dart';
import '../../state/rapports.dart';
import '../../state/vente.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';

/// Écran 5 : accueil. Ventes et bénéfice du jour, dettes à recevoir,
/// stock bas, accès aux rapports, état de la sauvegarde, et le bouton
/// « Nouvelle vente ».
class AccueilScreen extends ConsumerWidget {
  const AccueilScreen({super.key});

  /// Produits en stock bas montrés sur l'accueil (les autres : « Voir le stock »).
  static const alertesMontrees = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final produits = ref.watch(produitsProvider).value;
    // Change à minuit : la date et les chiffres passent au nouveau jour.
    final jour = ref.watch(jourCourantProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _EnTete(etat: ref.watch(etatSauvegardeProvider), jour: jour),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(KassaSpace.s4),
            sliver: SliverList.list(
              children: [
                const _BandeauAbonnement(),
                _Chiffres(jour: jour),
                if (produits != null && produits.isEmpty) ...[
                  const SizedBox(height: KassaSpace.s6),
                  const _PremiersProduits(),
                ],
                if (produits != null) ...[_AlertesStock(produits: produits)],
                const SizedBox(height: KassaSpace.s6),
                _Lien(
                  icone: Symbols.bar_chart_rounded,
                  titre: l.reportsTitle,
                  aide: l.reportsHint,
                  chemin: Chemins.rapports,
                ),
                const SizedBox(height: KassaSpace.s2),
                _Lien(
                  icone: Symbols.settings_rounded,
                  titre: l.settingsTitle,
                  aide: l.settingsHint,
                  chemin: Chemins.reglages,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: KassaButton(
          label: l.newSale,
          icon: Symbols.point_of_sale_rounded,
          size: KassaButtonSize.main,
          fullWidth: true,
          onPressed: () async {
            if (await ecritureAutorisee(context, ref) && context.mounted) {
              context.go(Chemins.vendre);
            }
          },
        ),
      ),
    );
  }
}

class _EnTete extends StatelessWidget {
  const _EnTete({required this.etat, required this.jour});

  final EtatSauvegarde etat;

  /// Début du jour en cours (UTC).
  final DateTime jour;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final langue = langueDe(context);
    final aujourdhui = DateFormat(
      'EEEE d MMMM',
      langue,
    ).format(HeureDouala.versDouala(jour));

    return Container(
      decoration: BoxDecoration(
        color: t.kassaDeep,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(KassaRadius.lg),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KassaSpace.s4,
            KassaSpace.s2,
            KassaSpace.s4,
            KassaSpace.s6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const KassaLogo(taille: 24, surFonce: true),
                  const SizedBox(width: KassaSpace.s4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: EtatSauvegardePuce(etat: etat),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KassaSpace.s4),
              Semantics(
                header: true,
                child: Text(
                  toBeginningOfSentenceCase(aujourdhui),
                  style: t.title.copyWith(color: t.onKassaDeep),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ventes du jour et dettes à recevoir, côte à côte (l'une sous l'autre
/// quand le texte est très grand).
class _Chiffres extends ConsumerWidget {
  const _Chiffres({required this.jour});

  /// Début du jour en cours (UTC).
  final DateTime jour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final langue = langueDe(context);
    final rapport = ref
        .watch(rapportProvider(Periode.contenant(TypePeriode.jour, jour)))
        .value;
    final clients = ref.watch(clientsProvider).value ?? const <Client>[];
    final debiteurs = clients.where((c) => c.soldeDette > 0);
    final dettes = debiteurs.fold(0, (s, c) => s + c.soldeDette);

    // Pendant le premier calcul, pas de « 0 FCFA » qui ferait croire à
    // une journée sans vente : un indicateur de chargement.
    final Widget ventes = rapport == null
        ? Container(
            padding: const EdgeInsets.all(KassaSpace.s4),
            decoration: BoxDecoration(
              color: context.kassa.surfaceRaised,
              borderRadius: BorderRadius.circular(KassaRadius.md),
            ),
            alignment: Alignment.center,
            child: Semantics(
              label: l.todaySales,
              child: const CircularProgressIndicator(),
            ),
          )
        : StatTile(
            label: l.todaySales,
            value: rapport.total,
            tone: AmountTone.encaisse,
            hint: l.salesAndProfit(
              l.salesCount(rapport.nombreVentes),
              Montant.format(rapport.benefice, langue, court: true),
            ),
          );
    final aRecevoir = StatTile(
      label: l.moneyOwed,
      value: dettes,
      tone: dettes > 0 ? AmountTone.dette : AmountTone.neutre,
      hint: l.customersCount(debiteurs.length),
    );

    return TuilesCoteACote(gauche: ventes, droite: aRecevoir);
  }
}

class _PremiersProduits extends StatelessWidget {
  const _PremiersProduits();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    return Container(
      padding: const EdgeInsets.all(KassaSpace.s4),
      decoration: BoxDecoration(
        color: t.kassaSoft,
        borderRadius: BorderRadius.circular(KassaRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.homeNoProductsTitle, style: t.label.copyWith(color: t.ink)),
          const SizedBox(height: KassaSpace.s1),
          Text(l.homeNoProductsBody, style: t.body.copyWith(color: t.ink)),
          const SizedBox(height: KassaSpace.s4),
          KassaButton(
            label: l.addProduct,
            icon: Symbols.add_rounded,
            variant: KassaButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => context.push(Chemins.nouveauProduit),
          ),
        ],
      ),
    );
  }
}

class _AlertesStock extends StatelessWidget {
  const _AlertesStock({required this.produits});

  final List<Produit> produits;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final bas =
        produits
            .where(
              (p) =>
                  Calculs.stockBas(quantite: p.quantite, seuil: p.seuilAlerte),
            )
            .toList()
          // Les plus vides d'abord.
          ..sort((a, b) => a.quantite.compareTo(b.quantite));
    if (bas.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: KassaSpace.s6),
      child: Container(
        padding: const EdgeInsets.all(KassaSpace.s4),
        decoration: BoxDecoration(
          color: t.orSoft,
          borderRadius: BorderRadius.circular(KassaRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Symbols.warning_rounded, color: t.orInk),
                const SizedBox(width: KassaSpace.s2),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l.stockAlerts(bas.length),
                      style: t.label.copyWith(color: t.orInk),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KassaSpace.s2),
            for (final p in bas.take(AccueilScreen.alertesMontrees))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: KassaSpace.s1),
                child: MergeSemantics(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.nom,
                          style: t.body.copyWith(color: t.orInk),
                        ),
                      ),
                      const SizedBox(width: KassaSpace.s2),
                      Text(
                        '${Quantite.format(p.quantite, langue)} ${p.unite}',
                        style: t.label.copyWith(color: t.orInk),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: KassaSpace.s2),
            KassaButton(
              label: l.seeStock,
              icon: Symbols.inventory_2_rounded,
              variant: KassaButtonVariant.secondary,
              fullWidth: true,
              onPressed: () => context.go(
                Chemins.stockBas('${DateTime.now().microsecondsSinceEpoch}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Une ligne qui ouvre un autre écran (Rapports, Réglages).
class _Lien extends StatelessWidget {
  const _Lien({
    required this.icone,
    required this.titre,
    required this.aide,
    required this.chemin,
  });

  final IconData icone;
  final String titre;
  final String aide;
  final String chemin;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Material(
      color: t.surfaceRaised,
      borderRadius: BorderRadius.circular(KassaRadius.md),
      clipBehavior: Clip.antiAlias,
      // MergeSemantics autour de l'InkWell : le lecteur d'écran annonce
      // le titre sur la zone qu'on touche.
      child: MergeSemantics(
        child: Semantics(
          button: true,
          child: InkWell(
            onTap: () => context.push(chemin),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: KassaSize.buttonMain,
              ),
              child: Padding(
                padding: const EdgeInsets.all(KassaSpace.s4),
                child: Row(
                  children: [
                    Icon(icone, color: t.kassa),
                    const SizedBox(width: KassaSpace.s4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titre,
                            style: t.label.copyWith(
                              fontSize: t.body.fontSize,
                              height: t.body.height,
                            ),
                          ),
                          Text(
                            aide,
                            style: t.caption.copyWith(color: t.inkMuted),
                          ),
                        ],
                      ),
                    ),
                    Icon(Symbols.chevron_right_rounded, color: t.inkMuted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fin d'essai proche (7 derniers jours) ou abonnement terminé : un
/// rappel avec « Passer à Pro ». Rien le reste du temps.
class _BandeauAbonnement extends ConsumerWidget {
  const _BandeauAbonnement();

  /// L'accueil prévient à partir de ce nombre de jours restants.
  static const joursAvantFin = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final etat = ref.watch(abonnementProvider).value;
    final prix = Montant.format(prixProFcfa, langue);
    final String titre;
    final String texte;
    switch (etat) {
      case AbonnementEssai(:final joursRestants)
          when joursRestants < joursAvantFin:
        titre = l.trialDaysLeft(joursRestants);
        texte = l.trialEndingBody(prix);
      case AbonnementTermine(:final etaitPro):
        titre = etaitPro ? l.proEnded : l.trialEnded;
        texte = l.readOnlyBody(prix);
      default:
        return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: KassaSpace.s6),
      child: Container(
        padding: const EdgeInsets.all(KassaSpace.s4),
        decoration: BoxDecoration(
          color: t.orSoft,
          borderRadius: BorderRadius.circular(KassaRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Symbols.workspace_premium_rounded, color: t.orInk),
                const SizedBox(width: KassaSpace.s2),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(titre, style: t.label.copyWith(color: t.orInk)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KassaSpace.s1),
            Text(texte, style: t.body.copyWith(color: t.orInk)),
            const SizedBox(height: KassaSpace.s4),
            KassaButton(
              label: l.goPro,
              icon: Symbols.workspace_premium_rounded,
              variant: KassaButtonVariant.or,
              fullWidth: true,
              onPressed: () => context.push(Chemins.abonnement),
            ),
          ],
        ),
      ),
    );
  }
}
