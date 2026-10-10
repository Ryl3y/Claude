import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../ui/brand/kassa_logo.dart';
import '../../ui/state/langue.dart';
import '../../ui/theme/kassa_tokens.dart';
import '../etat/etat_admin.dart';
import '../ui/communs.dart';

/// Chemins de l'admin.
abstract final class CheminsAdmin {
  static const connexion = '/connexion';
  static const tableauDeBord = '/';
  static const boutiques = '/boutiques';
  static const paiements = '/paiements';
  static const carte = '/carte';
}

typedef _Entree = (
  String chemin,
  IconData icone,
  String Function(AppLocalizations) libelle,
);

final List<_Entree> _entrees = [
  (
    CheminsAdmin.tableauDeBord,
    Symbols.dashboard_rounded,
    (l) => l.adminNavDashboard,
  ),
  (CheminsAdmin.boutiques, Symbols.storefront_rounded, (l) => l.adminNavShops),
  (CheminsAdmin.paiements, Symbols.payments_rounded, (l) => l.adminNavPayments),
  (CheminsAdmin.carte, Symbols.map_rounded, (l) => l.adminNavMap),
];

/// Cadre de l'admin : menu à gauche (ordinateur) ou en bas (petit écran),
/// barre du haut avec le compte, la langue et la déconnexion.
class CoquilleAdmin extends ConsumerWidget {
  const CoquilleAdmin({super.key, required this.lieu, required this.child});

  final String lieu;
  final Widget child;

  int get _index {
    final i = _entrees.indexWhere((e) => e.$1 != '/' && lieu.startsWith(e.$1));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final session = ref.watch(sessionAdminProvider);
    final email = session is AdminConnecte ? session.email : '';
    final large = MediaQuery.sizeOf(context).width >= largeurBureau;
    final francais = Localizations.localeOf(context).languageCode == 'fr';

    void changerLangue() => ref
        .read(langueProvider.notifier)
        .choisir(Locale(francais ? 'en' : 'fr'));
    void deconnecter() => ref.read(sessionAdminProvider.notifier).deconnecter();
    final autreLangue = francais ? l.languageEnglish : l.languageFrench;

    final barre = AppBar(
      backgroundColor: t.kassaDeep,
      foregroundColor: t.onKassaDeep,
      automaticallyImplyLeading: false,
      titleSpacing: KassaSpace.s4,
      title: Row(
        children: [
          const KassaLogo(taille: 22, surFonce: true),
          if (large) ...[
            const SizedBox(width: KassaSpace.s4),
            Flexible(
              child: Text(
                l.adminHello(email),
                overflow: TextOverflow.ellipsis,
                style: t.label.copyWith(color: t.onKassaDeep),
              ),
            ),
          ],
        ],
      ),
      actions: large
          ? [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: t.onKassaDeep),
                onPressed: changerLangue,
                icon: const Icon(Symbols.translate_rounded),
                label: Text(autreLangue),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: t.onKassaDeep),
                onPressed: deconnecter,
                icon: const Icon(Symbols.logout_rounded),
                label: Text(l.logout),
              ),
              const SizedBox(width: KassaSpace.s2),
            ]
          : [
              // Petit écran : compte, langue et déconnexion dans un menu.
              PopupMenuButton<VoidCallback>(
                tooltip: l.adminHello(email),
                icon: const Icon(Symbols.account_circle_rounded),
                onSelected: (action) => action(),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(l.adminHello(email)),
                  ),
                  PopupMenuItem(
                    value: changerLangue,
                    child: ListTile(
                      leading: const Icon(Symbols.translate_rounded),
                      title: Text(autreLangue),
                    ),
                  ),
                  PopupMenuItem(
                    value: deconnecter,
                    child: ListTile(
                      leading: const Icon(Symbols.logout_rounded),
                      title: Text(l.logout),
                    ),
                  ),
                ],
              ),
            ],
    );

    if (!large) {
      return Scaffold(
        appBar: barre,
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => context.go(_entrees[i].$1),
          destinations: [
            for (final e in _entrees)
              NavigationDestination(icon: Icon(e.$2), label: e.$3(l)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: barre,
      body: Row(
        children: [
          Container(
            width: 232,
            color: t.surfaceRaised,
            padding: const EdgeInsets.symmetric(vertical: KassaSpace.s4),
            child: Column(
              children: [
                for (final (i, e) in _entrees.indexed)
                  _EntreeMenu(
                    icone: e.$2,
                    libelle: e.$3(l),
                    choisie: i == _index,
                    onTap: () => context.go(e.$1),
                  ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _EntreeMenu extends StatelessWidget {
  const _EntreeMenu({
    required this.icone,
    required this.libelle,
    required this.choisie,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final bool choisie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final couleur = choisie ? t.kassa : t.ink;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KassaSpace.s2,
        vertical: KassaSpace.s1,
      ),
      child: Semantics(
        selected: choisie,
        button: true,
        child: Material(
          color: choisie ? t.kassaSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(KassaRadius.sm),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: KassaSize.touchMin),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: KassaSpace.s4),
                child: Row(
                  children: [
                    Icon(icone, color: couleur),
                    const SizedBox(width: KassaSpace.s4),
                    Expanded(
                      child: Text(
                        libelle,
                        style: t.label.copyWith(color: couleur),
                      ),
                    ),
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
