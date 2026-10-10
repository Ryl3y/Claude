import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/heure_douala.dart';
import 'l10n/generated/app_localizations.dart';
import 'ui/router.dart';
import 'ui/state/langue.dart';
import 'ui/state/session.dart';
import 'ui/theme/kassa_theme.dart';

class KassaApp extends ConsumerStatefulWidget {
  const KassaApp({super.key});

  @override
  ConsumerState<KassaApp> createState() => _KassaAppState();
}

class _KassaAppState extends ConsumerState<KassaApp> {
  late final AppLifecycleListener _cycle;
  DateTime? _cacheeDepuis;

  @override
  void initState() {
    super.initState();
    // Après un long moment en arrière-plan, l'app redemande le code PIN.
    _cycle = AppLifecycleListener(
      onHide: () => _cacheeDepuis = HeureDouala.maintenantUtc(),
      onShow: () {
        final depuis = _cacheeDepuis;
        _cacheeDepuis = null;
        if (depuis != null &&
            HeureDouala.maintenantUtc().difference(depuis) >=
                verrouillageApres) {
          ref.read(sessionProvider.notifier).verrouiller();
        }
      },
    );
  }

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langue = ref.watch(langueProvider);
    // La synchronisation tourne tant que l'app est ouverte.
    ref
      ..watch(planificateurSynchroProvider)
      ..watch(notificationsProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: KassaTheme.clair(),
      darkTheme: KassaTheme.sombre(),
      themeMode: ThemeMode.system,
      locale: langue,
      supportedLocales: languesKassa,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: (langues, _) => resoudreLangue(langues),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
