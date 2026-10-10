import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/generated/app_localizations.dart';
import 'ui/router.dart';
import 'ui/state/langue.dart';
import 'ui/theme/kassa_theme.dart';

class KassaApp extends ConsumerWidget {
  const KassaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langue = ref.watch(langueProvider);
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
