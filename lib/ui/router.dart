import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/demo_widgets_screen.dart';

/// Chemins de l'app. Les 15 écrans s'ajouteront ici étape par étape.
abstract final class Chemins {
  static const demo = '/';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Chemins.demo,
    routes: [
      GoRoute(
        path: Chemins.demo,
        builder: (context, state) => const DemoWidgetsScreen(),
      ),
    ],
  );
});
