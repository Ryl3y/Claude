import 'package:flutter/material.dart';

import '../../../domain/code_pin.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';

/// Les 4 points du code PIN : pleins pour les chiffres déjà tapés.
class PointsPin extends StatelessWidget {
  const PointsPin({super.key, required this.saisis, this.erreur = false});

  final int saisis;

  /// Points en rouge après un code faux.
  final bool erreur;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final couleur = erreur ? t.dette : t.kassa;
    return Semantics(
      label: l.pinProgress(saisis),
      liveRegion: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < CodePin.longueur; i++) ...[
              if (i > 0) const SizedBox(width: KassaSpace.s4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: KassaComposants.pointPin,
                height: KassaComposants.pointPin,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < saisis ? couleur : null,
                  border: Border.all(
                    // Code faux : les cercles vides passent en rouge.
                    color: i < saisis || erreur ? couleur : t.inkMuted,
                    width: KassaComposants.trait,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
