import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/montant.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';
import 'contexte.dart';

/// `montant` : FCFA entiers, touche « 000 ».
/// `quantite` : vrac (1,5 kg), touche virgule à la place de « 000 ».
/// `pin` : code PIN, 4 chiffres, pas d'affichage (l'écran montre des points).
enum NumPadMode { montant, quantite, pin }

/// Pavé numérique pour saisir un montant en FCFA ou une quantité.
///
/// [valeur] est une chaîne de chiffres (point comme séparateur décimal en
/// mode quantité) que l'appelant convertit avec [enEntier] ou [enQuantite].
/// Touches de 56 px : 1-9, « 000 » ou virgule, 0 et Effacer (appui long :
/// tout effacer). L'affichage reprend le format des montants ou l'unité.
class NumPad extends StatelessWidget {
  const NumPad({
    super.key,
    required this.valeur,
    required this.onChanged,
    this.mode = NumPadMode.montant,
    this.unite = '',
  });

  final String valeur;
  final ValueChanged<String> onChanged;
  final NumPadMode mode;

  /// Unité affichée en mode quantité (« kg »).
  final String unite;

  static const effacer = 'effacer';
  static const virgule = '.';

  /// Quantités : 7 chiffres avant la virgule, 3 après.
  static const _chiffresEntiersQuantite = 7;
  static const _decimalesQuantite = 3;

  /// Case vide (mode PIN : pas de « 000 » ni de virgule).
  static const vide = '';

  /// Chiffres d'un code PIN.
  static const _chiffresPin = 4;

  List<String> get _touches => [
    '1', '2', '3', //
    '4', '5', '6', //
    '7', '8', '9', //
    switch (mode) {
      NumPadMode.montant => '000',
      NumPadMode.quantite => virgule,
      NumPadMode.pin => vide,
    },
    '0', effacer,
  ];

  /// Nouvelle valeur après l'appui sur [touche] (règles du [mode]).
  static String appuyer(
    String valeur,
    String touche, {
    NumPadMode mode = NumPadMode.montant,
  }) {
    if (touche == effacer) {
      return valeur.isEmpty ? '' : valeur.substring(0, valeur.length - 1);
    }
    if (mode == NumPadMode.quantite) return _appuyerQuantite(valeur, touche);
    if (mode == NumPadMode.pin) {
      return touche == vide || valeur.length >= _chiffresPin
          ? valeur
          : valeur + touche;
    }

    final base = valeur == '0' ? '' : valeur;
    if (base.isEmpty && touche.startsWith('0')) return touche == '0' ? '0' : '';
    final suivante = base + touche;
    return suivante.length > KassaComposants.paveChiffresMax
        ? valeur
        : suivante;
  }

  static String _appuyerQuantite(String valeur, String touche) {
    if (touche == virgule) {
      if (valeur.contains(virgule)) return valeur;
      return valeur.isEmpty ? '0$virgule' : '$valeur$virgule';
    }
    final parties = valeur.split(virgule);
    if (parties.length == 2) {
      return parties[1].length >= _decimalesQuantite ? valeur : valeur + touche;
    }
    final entier = valeur == '0' ? '' : valeur;
    if (entier.length >= _chiffresEntiersQuantite) return valeur;
    return entier.isEmpty && touche == '0' ? '0' : entier + touche;
  }

  /// Montant saisi en entier (0 si vide).
  static int enEntier(String valeur) => int.tryParse(valeur) ?? 0;

  /// Quantité saisie (0 si vide).
  static double enQuantite(String valeur) => double.tryParse(valeur) ?? 0;

  String _affichage(BuildContext context) {
    final langue = langueDe(context);
    if (mode == NumPadMode.montant) {
      return Montant.format(enEntier(valeur), langue);
    }
    final separateur = NumberFormat.decimalPattern(langue).symbols.DECIMAL_SEP;
    final texte = valeur.isEmpty ? '0' : valeur.replaceAll(virgule, separateur);
    return unite.isEmpty ? texte : '$texte $unite';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final touches = _touches;

    return Container(
      padding: const EdgeInsets.all(KassaSpace.s4),
      decoration: BoxDecoration(
        color: t.surfaceRaised,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KassaRadius.lg),
        ),
        boxShadow: kassaShadowSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mode != NumPadMode.pin) ...[
            Semantics(
              liveRegion: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _affichage(context),
                  style: t.amountLg,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            const SizedBox(height: KassaSpace.s4),
          ],
          for (var ligne = 0; ligne < 4; ligne++) ...[
            if (ligne > 0) const SizedBox(height: KassaSpace.s2),
            Row(
              children: [
                for (var col = 0; col < 3; col++) ...[
                  if (col > 0) const SizedBox(width: KassaSpace.s2),
                  Expanded(
                    child: touches[ligne * 3 + col] == vide
                        ? const SizedBox.shrink()
                        : _Touche(
                            touche: touches[ligne * 3 + col],
                            onAppui: (touche) {
                              HapticFeedback.selectionClick();
                              onChanged(appuyer(valeur, touche, mode: mode));
                            },
                            onToutEffacer: () {
                              HapticFeedback.mediumImpact();
                              onChanged('');
                            },
                          ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Touche extends StatelessWidget {
  const _Touche({
    required this.touche,
    required this.onAppui,
    required this.onToutEffacer,
  });

  final String touche;
  final ValueChanged<String> onAppui;
  final VoidCallback onToutEffacer;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final l = AppLocalizations.of(context);
    final estEffacer = touche == NumPad.effacer;
    final estVirgule = touche == NumPad.virgule;
    final separateur = NumberFormat.decimalPattern(langueDe(context))
        .symbols
        .DECIMAL_SEP;

    final contenu = estEffacer
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.backspace_rounded,
                size: KassaComposants.iconeBouton,
                color: t.dette,
              ),
              const SizedBox(width: KassaSpace.s1),
              Flexible(
                child: Text(l.erase, style: t.bouton.copyWith(color: t.dette)),
              ),
            ],
          )
        : Text(
            estVirgule ? separateur : touche,
            style: t.touchePave.copyWith(color: t.ink),
          );

    // excludeSemantics retire les actions de l'InkWell : on les redonne ici.
    return Semantics(
      button: true,
      label: estEffacer
          ? l.erase
          : estVirgule
          ? l.decimalSeparator
          : touche,
      onTap: () => onAppui(touche),
      onLongPress: estEffacer ? onToutEffacer : null,
      excludeSemantics: true,
      child: Material(
        color: t.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(KassaRadius.md)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onAppui(touche),
          onLongPress: estEffacer ? onToutEffacer : null,
          splashColor: t.kassaSoft,
          highlightColor: t.kassaSoft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: KassaSize.buttonMain),
            child: Center(child: contenu),
          ),
        ),
      ),
    );
  }
}
