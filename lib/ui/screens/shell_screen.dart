import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/produits.dart';
import '../widgets/widgets.dart';

/// Cadre des quatre onglets : la barre du bas reste en place, chaque onglet
/// garde sa propre pile d'écrans.
class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key, required this.navigation});

  final StatefulNavigationShell navigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigation,
      bottomNavigationBar: KassaBottomNav(
        actif: KassaOnglet.values[navigation.currentIndex],
        alertesStock: ref.watch(alertesStockProvider),
        onChanged: (onglet) => navigation.goBranch(
          onglet.index,
          initialLocation: onglet.index == navigation.currentIndex,
        ),
      ),
    );
  }
}
