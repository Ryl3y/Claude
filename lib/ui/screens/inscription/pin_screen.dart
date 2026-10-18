import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../domain/code_pin.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../brand/kassa_logo.dart';
import '../../router.dart';
import '../../state/session.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/widgets.dart';
import 'pin_widgets.dart';

/// Écran 4 : code PIN à l'ouverture de l'app. Vérifié dès le 4e chiffre ;
/// après 5 erreurs, une attente qui double à chaque nouvelle erreur.
class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  var _saisie = '';
  int? _restants;
  var _enCours = false;
  Duration _attente = Duration.zero;
  Timer? _minuterie;

  @override
  void initState() {
    super.initState();
    _surveillerAttente();
  }

  @override
  void dispose() {
    _minuterie?.cancel();
    super.dispose();
  }

  /// Met à jour le compte à rebours tant qu'il faut attendre.
  void _surveillerAttente() {
    _minuterie?.cancel();
    final session = ref.read(sessionProvider.notifier);
    _attente = session.attenteAvantEssai();
    if (_attente == Duration.zero) return;
    _minuterie = Timer.periodic(const Duration(seconds: 1), (m) {
      if (!mounted) return;
      setState(() => _attente = session.attenteAvantEssai());
      if (_attente == Duration.zero) m.cancel();
    });
  }

  Future<void> _changer(String valeur) async {
    if (_enCours || _attente > Duration.zero) return;
    setState(() => _saisie = valeur);
    if (valeur.length < CodePin.longueur) return;
    setState(() => _enCours = true);
    final restants = await ref
        .read(sessionProvider.notifier)
        .deverrouiller(valeur);
    if (!mounted) return;
    if (restants != null) {
      await HapticFeedback.heavyImpact();
      setState(() {
        _saisie = '';
        _restants = restants;
        _enCours = false;
      });
      _surveillerAttente();
    }
    // Code bon : la session s'ouvre et le routeur quitte cet écran.
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final bloque = _attente > Duration.zero;
    final restants = _restants;
    final message = bloque
        ? l.pinLocked(_attente.inSeconds + 1)
        : restants != null
        ? l.pinWrong(restants)
        : null;

    return Scaffold(
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
                        const KassaLogo(taille: 28),
                        const SizedBox(height: KassaSpace.s8),
                        Semantics(
                          header: true,
                          child: Text(
                            l.pinTitle,
                            style: t.title,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: KassaSpace.s6),
                        PointsPin(
                          saisis: _saisie.length,
                          erreur: restants != null && _saisie.isEmpty,
                        ),
                        const SizedBox(height: KassaSpace.s4),
                        if (message != null) MessageDette(texte: message),
                        const Spacer(),
                        Opacity(
                          opacity: bloque
                              ? KassaComposants.opaciteDesactive
                              : 1,
                          child: AbsorbPointer(
                            absorbing: bloque || _enCours,
                            child: NumPad(
                              valeur: _saisie,
                              mode: NumPadMode.pin,
                              onChanged: _changer,
                            ),
                          ),
                        ),
                        const SizedBox(height: KassaSpace.s2),
                        KassaButton(
                          label: l.pinForgot,
                          icon: Symbols.help_rounded,
                          variant: KassaButtonVariant.ghost,
                          onPressed: () => context.push(Chemins.codeOublie),
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
