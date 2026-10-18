import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/code_pin.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/session.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/widgets.dart';
import 'pin_widgets.dart';

/// Nouveau code PIN après « Code oublié » : on le tape, puis on le
/// confirme. Deux codes différents : on recommence.
class NouveauPinScreen extends ConsumerStatefulWidget {
  const NouveauPinScreen({super.key});

  @override
  ConsumerState<NouveauPinScreen> createState() => _NouveauPinScreenState();
}

class _NouveauPinScreenState extends ConsumerState<NouveauPinScreen> {
  var _saisie = '';
  String? _premier;
  var _different = false;
  var _enCours = false;

  Future<void> _changer(String valeur) async {
    if (_enCours) return;
    setState(() {
      _saisie = valeur;
      if (valeur.isNotEmpty) _different = false;
    });
    if (valeur.length < CodePin.longueur) return;
    final premier = _premier;
    if (premier == null) {
      setState(() {
        _premier = valeur;
        _saisie = '';
      });
      return;
    }
    if (premier != valeur) {
      setState(() {
        _premier = null;
        _saisie = '';
        _different = true;
      });
      return;
    }
    final l = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _enCours = true);
    try {
      await ref.read(sessionProvider.notifier).changerPin(valeur);
      messager.showSnackBar(SnackBar(content: Text(l.pinChanged)));
      if (mounted) context.go(Chemins.accueil);
    } on Object {
      if (!mounted) return;
      setState(() {
        _enCours = false;
        _premier = null;
        _saisie = '';
      });
      messager.showSnackBar(SnackBar(content: Text(l.saveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    return Scaffold(
      appBar: AppBar(title: Text(l.pinForgot)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: KassaComposants.largeurContenuMax,
            ),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(KassaSpace.s4),
                    child: Column(
                      children: [
                        const SizedBox(height: KassaSpace.s6),
                        Semantics(
                          header: true,
                          liveRegion: true,
                          child: Text(
                            _premier == null
                                ? l.newPinTitle
                                : l.newPinConfirmTitle,
                            style: t.title,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: KassaSpace.s6),
                        PointsPin(saisis: _saisie.length, erreur: _different),
                        const SizedBox(height: KassaSpace.s4),
                        if (_different) MessageDette(texte: l.errPinMismatch),
                        const Spacer(),
                        AbsorbPointer(
                          absorbing: _enCours,
                          child: NumPad(
                            valeur: _saisie,
                            mode: NumPadMode.pin,
                            onChanged: _changer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
