import 'package:flutter/material.dart';

import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';

/// Écran ou liste vide : ce que c'est, pourquoi c'est vide, quoi faire.
class EtatVide extends StatelessWidget {
  const EtatVide({
    super.key,
    required this.icone,
    required this.titre,
    this.message,
  });

  final IconData icone;
  final String titre;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(KassaSpace.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: KassaComposants.iconeEtatVide, color: t.inkMuted),
            const SizedBox(height: KassaSpace.s4),
            Text(titre, style: t.title, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: KassaSpace.s2),
              Text(
                message!,
                style: t.body.copyWith(color: t.inkMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
