import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/kassa_tokens.dart';

/// Message d'erreur ou de manque : dette sur dette-soft, avec l'icône.
class MessageDette extends StatelessWidget {
  const MessageDette({super.key, required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(KassaSpace.s2),
        decoration: BoxDecoration(
          color: t.detteSoft,
          borderRadius: BorderRadius.circular(KassaRadius.sm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Symbols.error_rounded, color: t.dette),
            const SizedBox(width: KassaSpace.s2),
            Expanded(
              child: Text(texte, style: t.label.copyWith(color: t.dette)),
            ),
          ],
        ),
      ),
    );
  }
}
