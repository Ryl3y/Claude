import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/ui/theme/kassa_colors.dart';

double _luminance(Color c) => c.computeLuminance();

double contraste(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  // Paires texte / fond prévues par la charte : 4,5:1 minimum, dans les deux thèmes.
  for (final (nom, p) in [('clair', KassaPalette.clair), ('sombre', KassaPalette.sombre)]) {
    final paires = <String, (Color, Color)>{
      'ink / surface': (p.ink, p.surface),
      'ink / surface-raised': (p.ink, p.surfaceRaised),
      'ink / kassa-soft': (p.ink, p.kassaSoft),
      'ink-muted / surface': (p.inkMuted, p.surface),
      'ink-muted / surface-raised': (p.inkMuted, p.surfaceRaised),
      'kassa / surface-raised': (p.kassa, p.surfaceRaised),
      'kassa / kassa-soft': (p.kassa, p.kassaSoft),
      'on-kassa / kassa': (p.onKassa, p.kassa),
      'on-kassa-deep / kassa-deep': (p.onKassaDeep, p.kassaDeep),
      'on-or / or': (p.onOr, p.or),
      'or-ink / or-soft': (p.orInk, p.orSoft),
      'or-ink / surface': (p.orInk, p.surface),
      'dette / surface-raised': (p.dette, p.surfaceRaised),
      'dette / dette-soft': (p.dette, p.detteSoft),
    };
    paires.forEach((paire, c) {
      test('$nom : $paire ≥ 4,5:1', () {
        expect(contraste(c.$1, c.$2), greaterThanOrEqualTo(4.5),
            reason: contraste(c.$1, c.$2).toStringAsFixed(2));
      });
    });
  }
}
