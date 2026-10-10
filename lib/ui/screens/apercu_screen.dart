import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/montant.dart';
import '../../l10n/generated/app_localizations.dart';
import '../brand/kassa_logo.dart';
import '../state/langue.dart';
import '../theme/kassa_tokens.dart';

/// Écran provisoire de l'étape 1 : montre le logo, le thème et les traductions.
/// Il sera remplacé par l'accueil (écran 5) à l'étape 7.
class ApercuScreen extends ConsumerWidget {
  const ApercuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _EnTete(tagline: l.appTagline)),
          SliverPadding(
            padding: const EdgeInsets.all(KassaSpace.s4),
            sliver: SliverList.list(
              children: [
                _Section(
                  titre: l.language,
                  child: _ChoixLangue(),
                ),
                _Section(
                  titre: l.previewAmounts,
                  child: _Montants(locale: locale),
                ),
                _Section(titre: l.previewLogo, child: const _Logos()),
                _Section(titre: l.previewColors, child: const _Couleurs()),
                _Section(titre: l.previewText, child: const _Textes()),
                _Section(titre: l.previewWords, child: const _Lexique()),
                Text(
                  l.previewStepNote,
                  style: t.caption.copyWith(color: t.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: SizedBox(
          height: KassaSize.buttonMain,
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Symbols.point_of_sale_rounded),
            label: Text(l.newSale),
          ),
        ),
      ),
    );
  }
}

class _EnTete extends StatelessWidget {
  const _EnTete({required this.tagline});

  final String tagline;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Container(
      color: t.kassaDeep,
      padding: EdgeInsets.fromLTRB(
        KassaSpace.s4,
        MediaQuery.paddingOf(context).top + KassaSpace.s8,
        KassaSpace.s4,
        KassaSpace.s6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KassaLogo(taille: 40, surFonce: true),
          const SizedBox(height: KassaSpace.s4),
          Text(tagline, style: t.body.copyWith(color: t.onKassaDeep)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.titre, required this.child});

  final String titre;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Padding(
      padding: const EdgeInsets.only(bottom: KassaSpace.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titre, style: t.title),
          const SizedBox(height: KassaSpace.s2),
          Container(
            padding: const EdgeInsets.all(KassaSpace.s4),
            decoration: BoxDecoration(
              color: t.surfaceRaised,
              borderRadius: BorderRadius.circular(KassaRadius.md),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ChoixLangue extends ConsumerWidget {
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
          InkWell(
            borderRadius: BorderRadius.circular(KassaRadius.sm),
            onTap: () => ref
                .read(langueProvider.notifier)
                .choisir(code.isEmpty ? null : Locale(code)),
            child: Container(
              constraints: const BoxConstraints(minHeight: KassaSize.touchMin),
              padding: const EdgeInsets.symmetric(horizontal: KassaSpace.s2),
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
      ],
    );
  }
}

class _Montants extends StatelessWidget {
  const _Montants({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.todaySales, style: t.label.copyWith(color: t.inkMuted)),
        Text(
          Montant.format(45000, locale),
          style: t.amountLg.copyWith(color: t.kassa),
        ),
        Text(
          l.youSoldToday(Montant.format(45000, locale)),
          style: t.body,
        ),
        const SizedBox(height: KassaSpace.s4),
        Wrap(
          spacing: KassaSpace.s2,
          runSpacing: KassaSpace.s2,
          children: [
            _Pastille(
              fond: t.detteSoft,
              couleur: t.dette,
              texte: l.owes(Montant.format(7500, locale, court: true)),
              style: t.label,
            ),
            _Pastille(
              fond: t.kassaSoft,
              couleur: t.kassa,
              icone: Symbols.check_circle_rounded,
              texte: l.paidUp,
              style: t.label,
            ),
            _Pastille(
              fond: t.orSoft,
              couleur: t.orInk,
              icone: Symbols.warning_rounded,
              texte: l.lowStock,
              style: t.label,
            ),
            _Pastille(
              fond: t.or,
              couleur: t.onOr,
              icone: Symbols.workspace_premium_rounded,
              texte: l.goPro,
              style: t.label,
            ),
            _Pastille(
              fond: t.surface,
              couleur: t.kassa,
              icone: Symbols.cloud_done_rounded,
              texte: l.saved,
              style: t.label,
            ),
          ],
        ),
      ],
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({
    required this.fond,
    required this.couleur,
    required this.texte,
    required this.style,
    this.icone,
  });

  final Color fond;
  final Color couleur;
  final String texte;
  final TextStyle style;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KassaSpace.s2,
        vertical: KassaSpace.s1,
      ),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(KassaRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 18, color: couleur),
            const SizedBox(width: KassaSpace.s1),
          ],
          Text(
            texte,
            style: style.copyWith(
              color: couleur,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _Logos extends StatelessWidget {
  const _Logos();

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KassaLogo(taille: 32),
        const SizedBox(height: KassaSpace.s4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const KassaSymbole(taille: 64),
            const SizedBox(width: KassaSpace.s4),
            const KassaSymbole(taille: 32),
            const SizedBox(width: KassaSpace.s4),
            const KassaSymbole(taille: 24),
            const SizedBox(width: KassaSpace.s4),
            const KassaSymbole(taille: 16),
            const SizedBox(width: KassaSpace.s4),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: t.kassaDeep,
                borderRadius: BorderRadius.circular(KassaRadius.md),
              ),
              alignment: Alignment.center,
              child: const KassaSymbole(
                taille: 44,
                variante: KassaSymboleVariante.surFonce,
                fond: Color(0xFF0E3B26),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Couleurs extends StatelessWidget {
  const _Couleurs();

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final nuancier = <(String, Color, Color)>[
      ('surface', t.surface, t.ink),
      ('surface-raised', t.surfaceRaised, t.ink),
      ('line', t.line, t.ink),
      ('ink', t.ink, t.surface),
      ('ink-muted', t.inkMuted, t.surface),
      ('kassa', t.kassa, t.onKassa),
      ('kassa-soft', t.kassaSoft, t.ink),
      ('kassa-deep', t.kassaDeep, t.onKassaDeep),
      ('or', t.or, t.onOr),
      ('or-soft', t.orSoft, t.orInk),
      ('dette', t.dette, t.surfaceRaised),
      ('dette-soft', t.detteSoft, t.dette),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final largeur = (c.maxWidth - 2 * KassaSpace.s2) / 3;
        return Wrap(
          spacing: KassaSpace.s2,
          runSpacing: KassaSpace.s2,
          children: [
            for (final (nom, fond, texte) in nuancier)
              Container(
                width: largeur,
                height: 56,
                padding: const EdgeInsets.all(KassaSpace.s2),
                alignment: Alignment.bottomLeft,
                decoration: BoxDecoration(
                  color: fond,
                  borderRadius: BorderRadius.circular(KassaRadius.sm),
                  border: Border.all(color: t.line),
                ),
                child: Text(nom, style: t.caption.copyWith(color: texte)),
              ),
          ],
        );
      },
    );
  }
}

class _Textes extends StatelessWidget {
  const _Textes();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final exemples = <(String, TextStyle, String)>[
      ('display 32/40', t.display, l.appName),
      ('title 22/28', t.title, l.newSale),
      ('amount-lg 36/44', t.amountLg, Montant.format(12500, locale)),
      ('amount 20/28', t.amount, Montant.format(12500, locale, court: true)),
      ('body 16/24', t.body, l.appTagline),
      ('label 14/20', t.label, l.collectPayment),
      ('caption 12/16', t.caption, l.todayProfit),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (nom, style, texte) in exemples) ...[
          Text(nom, style: t.caption.copyWith(color: t.inkMuted)),
          Text(texte, style: style),
          const SizedBox(height: KassaSpace.s2),
        ],
      ],
    );
  }
}

class _Lexique extends StatelessWidget {
  const _Lexique();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final mots = <(IconData, String)>[
      (Symbols.home_rounded, l.navHome),
      (Symbols.point_of_sale_rounded, l.navSell),
      (Symbols.inventory_2_rounded, l.navStock),
      (Symbols.group_rounded, l.navCustomers),
      (Symbols.add_shopping_cart_rounded, l.newSale),
      (Symbols.payments_rounded, l.collectPayment),
      (Symbols.add_rounded, l.add),
      (Symbols.local_shipping_rounded, l.restock),
      (Symbols.chat_rounded, l.remind),
      (Symbols.warning_rounded, l.lowStock),
      (Symbols.trending_up_rounded, l.todaySales),
      (Symbols.account_balance_wallet_rounded, l.moneyOwed),
      (Symbols.cloud_done_rounded, l.saved),
      (Symbols.workspace_premium_rounded, l.goPro),
      (Symbols.cancel_rounded, l.cancelSale),
    ];
    return Wrap(
      spacing: KassaSpace.s4,
      runSpacing: KassaSpace.s2,
      children: [
        for (final (icone, mot) in mots)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: KassaSize.icon, color: t.ink),
              const SizedBox(width: KassaSpace.s1),
              Text(mot, style: t.body),
            ],
          ),
      ],
    );
  }
}
