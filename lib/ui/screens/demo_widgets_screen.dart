import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/heure_douala.dart';
import '../../core/montant.dart';
import '../../core/whatsapp.dart';
import '../../domain/calculs.dart';
import '../../l10n/generated/app_localizations.dart';
import '../brand/kassa_logo.dart';
import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';
import '../widgets/contexte.dart';
import '../widgets/widgets.dart';
import 'demo_donnees.dart';

/// Page de démonstration des widgets de la charte (étape 3).
/// Elle sera remplacée par l'accueil (écran 5) à l'étape 7.
class DemoWidgetsScreen extends StatefulWidget {
  const DemoWidgetsScreen({super.key});

  @override
  State<DemoWidgetsScreen> createState() => _DemoWidgetsScreenState();
}

class _DemoWidgetsScreenState extends State<DemoWidgetsScreen> {
  final _panier = <String, double>{};
  var _montantRecu = '';
  var _onglet = KassaOnglet.accueil;

  void _ajouter(ProduitDemo p) =>
      setState(() => _panier[p.id] = (_panier[p.id] ?? 0) + 1);

  void _rappeler(ClientDemo c) {
    final l = AppLocalizations.of(context);
    final message = l.reminderMessage(
      c.nom,
      Montant.format(c.dette, langueDe(context)),
      nomBoutiqueDemo,
    );
    // Le lien s'ouvrira dans WhatsApp à l'étape 6 (écran Fiche client).
    WhatsApp.lien(telephone: c.telephone, message: message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.demoReminderSent(c.nom))));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final alertes = produitsDemo
        .where((p) => Calculs.stockBas(quantite: p.stock, seuil: p.seuil))
        .length;
    final totalDettes = clientsDemo.fold(0, (s, c) => s + c.dette);
    final clientsEnDette = clientsDemo.where((c) => c.dette > 0).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _EnTete(titre: l.demoTitle)),
          SliverPadding(
            padding: const EdgeInsets.all(KassaSpace.s4),
            sliver: SliverList.list(
              children: [
                _Section(
                  titre: l.language,
                  child: const _Carte(child: ChoixLangue()),
                ),
                _Section(
                  titre: l.demoStats,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: StatTile(
                          label: l.todaySales,
                          value: 45000,
                          tone: AmountTone.encaisse,
                          hint: l.salesCount(23),
                        ),
                      ),
                      const SizedBox(width: KassaSpace.s2),
                      Expanded(
                        child: StatTile(
                          label: l.moneyOwed,
                          value: totalDettes,
                          tone: AmountTone.dette,
                          hint: l.customersCount(clientsEnDette),
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(
                  titre: l.demoAmounts,
                  child: const _Carte(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AmountText(value: 12500, size: AmountSize.lg),
                        AmountText(value: 45000, tone: AmountTone.encaisse),
                        AmountText(
                          value: 7500,
                          tone: AmountTone.dette,
                          short: true,
                        ),
                      ],
                    ),
                  ),
                ),
                _Section(
                  titre: l.demoBadges,
                  child: Wrap(
                    spacing: KassaSpace.s2,
                    runSpacing: KassaSpace.s2,
                    children: [
                      KassaBadge(label: l.paid, tone: KassaBadgeTone.kassa),
                      KassaBadge(
                        label: l.saved,
                        tone: KassaBadgeTone.kassa,
                        icon: Symbols.cloud_done_rounded,
                      ),
                      KassaBadge(label: l.proBadge, tone: KassaBadgeTone.or),
                      KassaBadge(
                        label: l.lowStock,
                        tone: KassaBadgeTone.alerte,
                        icon: Symbols.warning_rounded,
                      ),
                      KassaBadge(
                        label: l.cancelled,
                        tone: KassaBadgeTone.dette,
                      ),
                      KassaBadge(label: produitsDemo.first.unite),
                    ],
                  ),
                ),
                _Section(
                  titre: l.demoButtons,
                  child: Wrap(
                    spacing: KassaSpace.s2,
                    runSpacing: KassaSpace.s2,
                    children: [
                      KassaButton(
                        label: l.restock,
                        icon: Symbols.local_shipping_rounded,
                        variant: KassaButtonVariant.secondary,
                        onPressed: () {},
                      ),
                      KassaButton(
                        label: l.goPro,
                        icon: Symbols.workspace_premium_rounded,
                        variant: KassaButtonVariant.or,
                        onPressed: () {},
                      ),
                      KassaButton(
                        label: l.cancelSale,
                        icon: Symbols.cancel_rounded,
                        variant: KassaButtonVariant.danger,
                        onPressed: () {},
                      ),
                      KassaButton(
                        label: l.later,
                        variant: KassaButtonVariant.ghost,
                        onPressed: () {},
                      ),
                      KassaButton(
                        label: l.add,
                        icon: Symbols.add_rounded,
                        variant: KassaButtonVariant.secondary,
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
                _Section(
                  titre: l.demoProducts,
                  aide: l.demoProductsHint,
                  child: _GrilleProduits(panier: _panier, onAjouter: _ajouter),
                ),
                _Section(
                  titre: l.demoCustomers,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(KassaRadius.md),
                    child: Column(
                      children: [
                        for (final (i, c) in clientsDemo.indexed) ...[
                          if (i > 0) Divider(color: t.line),
                          ClientRow(
                            nom: c.nom,
                            meta: l.lastPurchase(
                              HeureDouala.dateCourte(c.dernierAchat, langue),
                            ),
                            montantDu: c.dette,
                            onTap: () {},
                            onRappel: () => _rappeler(c),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _Section(
                  titre: l.demoNumPad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NumPad(
                        valeur: _montantRecu,
                        onChanged: (v) => setState(() => _montantRecu = v),
                      ),
                      const SizedBox(height: KassaSpace.s4),
                      KassaButton(
                        label: l.collectPayment,
                        icon: Symbols.payments_rounded,
                        size: KassaButtonSize.main,
                        fullWidth: true,
                        onPressed: NumPad.enEntier(_montantRecu) > 0
                            ? () {}
                            : null,
                      ),
                    ],
                  ),
                ),
                Text(
                  l.previewStepNote,
                  style: t.caption.copyWith(color: t.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: KassaBottomNav(
        actif: _onglet,
        alertesStock: alertes,
        onChanged: (o) => setState(() => _onglet = o),
      ),
    );
  }
}

/// Grille de 3 colonnes ; chaque rangée prend la hauteur de sa plus haute
/// carte, ce qui suit la taille de texte choisie sur le téléphone.
class _GrilleProduits extends StatelessWidget {
  const _GrilleProduits({required this.panier, required this.onAjouter});

  final Map<String, double> panier;
  final ValueChanged<ProduitDemo> onAjouter;

  @override
  Widget build(BuildContext context) {
    const colonnes = KassaComposants.grilleProduitsColonnes;
    final rangees = <List<ProduitDemo>>[
      for (var i = 0; i < produitsDemo.length; i += colonnes)
        produitsDemo.skip(i).take(colonnes).toList(),
    ];
    return Column(
      children: [
        for (final (i, rangee) in rangees.indexed) ...[
          if (i > 0) const SizedBox(height: KassaSpace.s2),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = 0; c < colonnes; c++) ...[
                  if (c > 0) const SizedBox(width: KassaSpace.s2),
                  Expanded(
                    child: c < rangee.length
                        ? ProductCard(
                            nom: rangee[c].nom,
                            prix: rangee[c].prix,
                            stock: rangee[c].stock,
                            unite: rangee[c].unite,
                            seuilAlerte: rangee[c].seuil,
                            quantiteDansPanier: panier[rangee[c].id] ?? 0,
                            onTap: () => onAjouter(rangee[c]),
                            onLongPress: () => onAjouter(rangee[c]),
                          )
                        : const SizedBox.shrink(),
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

class _EnTete extends StatelessWidget {
  const _EnTete({required this.titre});

  final String titre;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Container(
      color: t.kassaDeep,
      padding: EdgeInsets.fromLTRB(
        KassaSpace.s4,
        MediaQuery.paddingOf(context).top + KassaSpace.s6,
        KassaSpace.s4,
        KassaSpace.s6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KassaLogo(taille: KassaSpace.s8, surFonce: true),
          const SizedBox(height: KassaSpace.s4),
          Semantics(
            header: true,
            child: Text(titre, style: t.title.copyWith(color: t.onKassaDeep)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.titre, required this.child, this.aide});

  final String titre;
  final String? aide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Padding(
      padding: const EdgeInsets.only(bottom: KassaSpace.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(titre, style: t.title)),
          if (aide != null)
            Text(aide!, style: t.caption.copyWith(color: t.inkMuted)),
          const SizedBox(height: KassaSpace.s2),
          child,
        ],
      ),
    );
  }
}

class _Carte extends StatelessWidget {
  const _Carte({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(KassaSpace.s4),
    decoration: BoxDecoration(
      color: context.kassa.surfaceRaised,
      borderRadius: BorderRadius.circular(KassaRadius.md),
    ),
    child: child,
  );
}
