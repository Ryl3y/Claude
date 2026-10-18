import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/generated/app_localizations.dart';

/// Les quatre onglets de la barre du bas.
enum KassaOnglet { accueil, vendre, stock, clients }

/// Barre de navigation du bas : Accueil, Vendre, Stock, Clients.
///
/// Onglet actif : icône dans une pilule kassa-soft, libellé kassa en gras
/// (thème). [alertesStock] > 0 : pastille or sur l'onglet Stock.
class KassaBottomNav extends StatelessWidget {
  const KassaBottomNav({
    super.key,
    required this.actif,
    this.alertesStock = 0,
    required this.onChanged,
  });

  final KassaOnglet actif;
  final int alertesStock;
  final ValueChanged<KassaOnglet> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    Widget iconeStock() {
      final icone = const Icon(Symbols.inventory_2_rounded);
      if (alertesStock <= 0) return icone;
      return Semantics(
        label: l.stockAlerts(alertesStock),
        child: Badge(
          label: ExcludeSemantics(child: Text('$alertesStock')),
          child: icone,
        ),
      );
    }

    return NavigationBar(
      selectedIndex: KassaOnglet.values.indexOf(actif),
      onDestinationSelected: (i) => onChanged(KassaOnglet.values[i]),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: const Icon(Symbols.home_rounded),
          label: l.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Symbols.point_of_sale_rounded),
          label: l.navSell,
        ),
        NavigationDestination(icon: iconeStock(), label: l.navStock),
        NavigationDestination(
          icon: const Icon(Symbols.group_rounded),
          label: l.navCustomers,
        ),
      ],
    );
  }
}
