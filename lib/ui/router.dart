import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/apercu_screen.dart';

/// Chemins de l'app. Les 15 écrans s'ajouteront ici étape par étape.
abstract final class Chemins {
  static const apercu = '/';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Chemins.apercu,
    routes: [
      GoRoute(
        path: Chemins.apercu,
        builder: (context, state) => const ApercuScreen(),
      ),
    ],
  );
});
