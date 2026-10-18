import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/generated/app_localizations.dart';
import '../widgets/widgets.dart';

/// Onglet dont l'écran arrive à une prochaine étape (Vendre, Clients).
class AVenirScreen extends StatelessWidget {
  const AVenirScreen({super.key, required this.titre});

  final String titre;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(titre)),
      body: EtatVide(
        icone: Symbols.construction_rounded,
        titre: titre,
        message: l.comingSoon,
      ),
    );
  }
}
