import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../ui/state/langue.dart';
import '../ui/theme/kassa_theme.dart';
import 'ecrans/boutiques_admin_screen.dart';
import 'ecrans/carte_admin_screen.dart';
import 'ecrans/connexion_admin_screen.dart';
import 'ecrans/coquille_admin.dart';
import 'ecrans/paiements_admin_screen.dart';
import 'ecrans/tableau_bord_screen.dart';
import 'etat/etat_admin.dart';

/// Écrans où l'on peut revenir après la connexion (pas d'adresse venue
/// d'ailleurs).
const _retoursPossibles = {
  CheminsAdmin.tableauDeBord,
  CheminsAdmin.boutiques,
  CheminsAdmin.paiements,
  CheminsAdmin.carte,
};

/// Où aller selon la session admin. Sans session, on passe par la
/// connexion en gardant l'écran demandé (recharger la page ou ouvrir un
/// favori ramène au bon écran).
String? redirectionAdmin(EtatSessionAdmin session, Uri adresse) {
  final lieu = adresse.path;
  if (session is AdminConnecte) {
    if (lieu != CheminsAdmin.connexion) return null;
    final retour = adresse.queryParameters['retour'];
    return _retoursPossibles.contains(retour)
        ? retour
        : CheminsAdmin.tableauDeBord;
  }
  if (lieu == CheminsAdmin.connexion) return null;
  return Uri(
    path: CheminsAdmin.connexion,
    queryParameters: lieu == CheminsAdmin.tableauDeBord
        ? null
        : {'retour': lieu},
  ).toString();
}

final routeurAdminProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<EtatSessionAdmin>(
    ref.read(sessionAdminProvider),
  );
  ref
    ..listen(sessionAdminProvider, (_, s) => session.value = s)
    ..onDispose(session.dispose);
  return GoRouter(
    initialLocation: CheminsAdmin.tableauDeBord,
    refreshListenable: session,
    redirect: (context, state) => redirectionAdmin(session.value, state.uri),
    routes: [
      GoRoute(
        path: CheminsAdmin.connexion,
        builder: (context, state) => const ConnexionAdminScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            CoquilleAdmin(lieu: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: CheminsAdmin.tableauDeBord,
            builder: (context, state) => const TableauBordScreen(),
          ),
          GoRoute(
            path: CheminsAdmin.boutiques,
            builder: (context, state) => const BoutiquesAdminScreen(),
          ),
          GoRoute(
            path: CheminsAdmin.paiements,
            builder: (context, state) => const PaiementsAdminScreen(),
          ),
          GoRoute(
            path: CheminsAdmin.carte,
            builder: (context, state) => const CarteAdminScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Le tableau de bord de l'équipe Kassa (Flutter web).
class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).adminTitle,
      debugShowCheckedModeBanner: false,
      theme: KassaTheme.clair(),
      darkTheme: KassaTheme.sombre(),
      themeMode: ThemeMode.system,
      locale: ref.watch(langueProvider),
      supportedLocales: languesKassa,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: (langues, _) => resoudreLangue(langues),
      routerConfig: ref.watch(routeurAdminProvider),
    );
  }
}
