import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'screens/a_venir_screen.dart';
import 'screens/demo_widgets_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/stock/produit_form_screen.dart';
import 'screens/stock/reappro_screen.dart';
import 'screens/stock/stock_screen.dart';

/// Chemins de l'app. Les 15 écrans s'ajoutent ici étape par étape.
abstract final class Chemins {
  static const accueil = '/';
  static const vendre = '/vendre';
  static const stock = '/stock';
  static const clients = '/clients';
  static const nouveauProduit = '/stock/produit/nouveau';

  static String produit(String id) => '/stock/produit/$id';

  static String reappro({String? produitId}) => produitId == null
      ? '/stock/reappro'
      : Uri(
          path: '/stock/reappro',
          queryParameters: {'produit': produitId},
        ).toString();
}

final routerProvider = Provider<GoRouter>((ref) {
  final racine = GlobalKey<NavigatorState>(debugLabel: 'racine');
  return GoRouter(
    navigatorKey: racine,
    initialLocation: Chemins.accueil,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigation) =>
            ShellScreen(navigation: navigation),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Chemins.accueil,
                builder: (context, state) => const DemoWidgetsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Chemins.vendre,
                builder: (context, state) =>
                    AVenirScreen(titre: AppLocalizations.of(context).navSell),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Chemins.stock,
                builder: (context, state) => const StockScreen(),
                routes: [
                  // Écrans plein écran, au-dessus de la barre du bas.
                  GoRoute(
                    path: 'produit/nouveau',
                    parentNavigatorKey: racine,
                    builder: (context, state) => const ProduitFormScreen(),
                  ),
                  GoRoute(
                    path: 'produit/:id',
                    parentNavigatorKey: racine,
                    builder: (context, state) => ProduitFormScreen(
                      produitId: state.pathParameters['id'],
                    ),
                  ),
                  GoRoute(
                    path: 'reappro',
                    parentNavigatorKey: racine,
                    builder: (context, state) => ReapproScreen(
                      produitId: state.uri.queryParameters['produit'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Chemins.clients,
                builder: (context, state) => AVenirScreen(
                  titre: AppLocalizations.of(context).navCustomers,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
