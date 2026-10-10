import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/clients/client_fiche_screen.dart';
import 'screens/clients/client_form_screen.dart';
import 'screens/clients/clients_screen.dart';
import 'screens/clients/encaissement_screen.dart';
import 'screens/accueil/accueil_screen.dart';
import 'screens/accueil/rapports_screen.dart';
import 'screens/demo_widgets_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/stock/produit_form_screen.dart';
import 'screens/stock/reappro_screen.dart';
import 'screens/stock/stock_screen.dart';
import 'screens/vente/historique_screen.dart';
import 'screens/vente/nouvelle_vente_screen.dart';
import 'screens/vente/paiement_screen.dart';
import 'screens/vente/vente_detail_screen.dart';

/// Chemins de l'app. Les 15 écrans s'ajoutent ici étape par étape.
abstract final class Chemins {
  static const accueil = '/';
  static const vendre = '/vendre';
  static const stock = '/stock';
  static const clients = '/clients';
  static const nouveauProduit = '/stock/produit/nouveau';
  static const paiement = '/vendre/paiement';
  static const historique = '/vendre/historique';

  static const nouveauClient = '/clients/nouveau';

  /// Stock filtré sur le stock bas ; [demande] change à chaque appui.
  static String stockBas(String demande) => Uri(
    path: stock,
    queryParameters: {'filtre': 'bas', 'demande': demande},
  ).toString();
  static const rapports = '/rapports';
  static const demo = '/demo';

  /// Détail d'une vente, ouvert depuis l'historique ou une fiche client.
  static String vente(String id) => '/vente/$id';

  static String client(String id) => '/clients/$id';

  static String modifierClient(String id) => '/clients/$id/modifier';

  static String encaisser(String id) => '/clients/$id/encaisser';

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
                builder: (context, state) => const AccueilScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Chemins.vendre,
                builder: (context, state) => const NouvelleVenteScreen(),
                routes: [
                  GoRoute(
                    path: 'paiement',
                    parentNavigatorKey: racine,
                    builder: (context, state) => const PaiementScreen(),
                  ),
                  GoRoute(
                    path: 'historique',
                    parentNavigatorKey: racine,
                    builder: (context, state) => const HistoriqueScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Chemins.stock,
                builder: (context, state) => StockScreen(
                  demandeStockBas: state.uri.queryParameters['filtre'] == 'bas'
                      ? state.uri.queryParameters['demande'] ?? ''
                      : null,
                ),
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
                builder: (context, state) => const ClientsScreen(),
                routes: [
                  GoRoute(
                    path: 'nouveau',
                    parentNavigatorKey: racine,
                    builder: (context, state) => const ClientFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: racine,
                    builder: (context, state) => ClientFicheScreen(
                      clientId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'modifier',
                        parentNavigatorKey: racine,
                        builder: (context, state) => ClientFormScreen(
                          clientId: state.pathParameters['id'],
                        ),
                      ),
                      GoRoute(
                        path: 'encaisser',
                        parentNavigatorKey: racine,
                        builder: (context, state) => EncaissementScreen(
                          clientId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Chemins.rapports,
        builder: (context, state) => const RapportsScreen(),
      ),
      // Page de démonstration des composants (étape 3), sans lien dans l'app.
      GoRoute(
        path: Chemins.demo,
        builder: (context, state) => const DemoWidgetsScreen(),
      ),
      // Hors des onglets : ouvert depuis Vendre ou depuis une fiche client.
      GoRoute(
        path: '/vente/:id',
        builder: (context, state) =>
            VenteDetailScreen(venteId: state.pathParameters['id']!),
      ),
    ],
  );
});
