import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/kassa_tokens.dart';

/// Message d'alerte non bloquant : or-ink sur or-soft, avec l'icône.
class Avertissement extends StatelessWidget {
  const Avertissement({super.key, required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Container(
      padding: const EdgeInsets.all(KassaSpace.s2),
      decoration: BoxDecoration(
        color: t.orSoft,
        borderRadius: BorderRadius.circular(KassaRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Symbols.warning_rounded, color: t.orInk),
          const SizedBox(width: KassaSpace.s2),
          Expanded(
            child: Text(texte, style: t.label.copyWith(color: t.orInk)),
          ),
        ],
      ),
    );
  }
}
