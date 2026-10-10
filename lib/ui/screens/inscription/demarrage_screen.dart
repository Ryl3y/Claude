import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../brand/kassa_logo.dart';
import '../../theme/kassa_tokens.dart';

/// Le temps de lire le compte du téléphone, au démarrage.
class DemarrageScreen extends StatelessWidget {
  const DemarrageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Semantics(
          label: l.loading,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KassaLogo(taille: 32),
              SizedBox(height: KassaSpace.s6),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
