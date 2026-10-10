import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/telephone.dart';
import '../../../data/auth/service_auth.dart';
import '../../../data/inscription.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/session.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/widgets.dart';

/// Écran 2 : connexion par SMS. Le numéro, puis le code à 6 chiffres.
///
/// [codeOublie] : même écran pour « Code oublié » ; le numéro doit être
/// celui du compte de ce téléphone, puis on choisit un nouveau code PIN.
class ConnexionScreen extends ConsumerStatefulWidget {
  const ConnexionScreen({super.key, this.codeOublie = false});

  final bool codeOublie;

  @override
  ConsumerState<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends ConsumerState<ConnexionScreen> {
  /// Attente imposée par Supabase entre deux SMS au même numéro.
  static const _delaiRenvoi = Duration(seconds: 60);

  final _telephone = TextEditingController();
  final _code = TextEditingController();

  /// Numéro international une fois le code envoyé ; null à la 1re étape.
  String? _numero;
  String? _erreur;
  var _enCours = false;
  var _restauration = false;
  var _attente = 0;
  Timer? _minuterie;

  @override
  void dispose() {
    _minuterie?.cancel();
    _telephone.dispose();
    _code.dispose();
    super.dispose();
  }

  String _message(AppLocalizations l, ErreurConnexion e) => switch (e) {
    ErreurConnexion.codeRefuse => l.errCodeRefused,
    ErreurConnexion.envoiSms => l.errSmsFailed,
    ErreurConnexion.tropDeDemandes => l.errTooManyRequests,
    ErreurConnexion.reseau => l.errNetwork,
    ErreurConnexion.autre => l.errOther,
  };

  void _demarrerAttente() {
    _minuterie?.cancel();
    setState(() => _attente = _delaiRenvoi.inSeconds);
    _minuterie = Timer.periodic(const Duration(seconds: 1), (m) {
      if (!mounted) return;
      setState(() => _attente--);
      if (_attente <= 0) m.cancel();
    });
  }

  Future<void> _envoyer({String? numero}) async {
    final l = AppLocalizations.of(context);
    final cible = numero ?? Telephone.versInternational(_telephone.text);
    if (cible == null) {
      setState(() => _erreur = l.errPhone);
      return;
    }
    final auth = ref.read(serviceAuthProvider);
    if (auth == null || _enCours) return;
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      await auth.envoyerCode(cible);
      if (!mounted) return;
      setState(() => _numero = cible);
      _demarrerAttente();
      SemanticsService.sendAnnouncement(
        View.of(context),
        l.codeSent(Telephone.afficher(cible)),
        Directionality.of(context),
      );
    } on ConnexionImpossible catch (e) {
      if (mounted) setState(() => _erreur = _message(l, e.raison));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _verifier() async {
    final l = AppLocalizations.of(context);
    final numero = _numero;
    final auth = ref.read(serviceAuthProvider);
    final inscription = ref.read(inscriptionProvider);
    final code = _code.text.trim();
    if (numero == null || auth == null || inscription == null || _enCours) {
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _erreur = l.errCodeRefused);
      return;
    }
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final id = await auth.verifierCode(numero, code);
      if (!mounted) return;
      if (widget.codeOublie) {
        await _apresCodeOublie(id, auth);
        return;
      }
      setState(() => _restauration = true);
      final suite = await inscription.apresConnexion(id);
      if (!mounted) return;
      switch (suite) {
        case SuiteConnexion.creerBoutique:
          context.go(Chemins.nouvelleBoutique);
        case SuiteConnexion.codePin:
          // Le compte est sur le téléphone : la session passe au code PIN.
          await ref.read(sessionProvider.notifier).charger();
      }
    } on ConnexionImpossible catch (e) {
      if (mounted) setState(() => _erreur = _message(l, e.raison));
    } on AutreCompteSurCeTelephone {
      if (mounted) setState(() => _erreur = l.errOtherAccount);
    } on Object {
      // Restauration interrompue (réseau coupé…) : on pourra réessayer.
      if (mounted) setState(() => _erreur = l.errNetwork);
    } finally {
      if (mounted) {
        setState(() {
          _enCours = false;
          _restauration = false;
        });
      }
    }
  }

  Future<void> _apresCodeOublie(String id, ServiceAuth auth) async {
    final l = AppLocalizations.of(context);
    final session = ref.read(sessionProvider);
    final compteId = switch (session) {
      SessionVerrouillee(:final compte) => compte.id,
      _ => null,
    };
    if (compteId != id) {
      await auth.deconnecter();
      if (mounted) setState(() => _erreur = l.errPinOtherNumber);
      return;
    }
    if (mounted) context.pushReplacement(Chemins.nouveauPin);
  }

  void _changerNumero() {
    _minuterie?.cancel();
    setState(() {
      _numero = null;
      _erreur = null;
      _code.clear();
      _attente = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final numero = _numero;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.codeOublie
              ? l.pinForgot
              : numero == null
              ? l.loginTitle
              : l.codeTitle,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: ListView(
            padding: const EdgeInsets.all(KassaSpace.s4),
            children: [
              if (numero == null) ...[
                Text(
                  widget.codeOublie ? l.pinForgotBody : l.loginBody,
                  style: t.body,
                ),
                const SizedBox(height: KassaSpace.s6),
                TextField(
                  controller: _telephone,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]')),
                  ],
                  onChanged: (_) {
                    if (_erreur != null) setState(() => _erreur = null);
                  },
                  onSubmitted: (_) => _envoyer(),
                  decoration: InputDecoration(
                    labelText: l.phoneLabel,
                    prefixText: '+${Telephone.indicatif} ',
                    errorText: _erreur,
                    errorMaxLines: 3,
                  ),
                ),
              ] else ...[
                Text(l.codeBody(Telephone.afficher(numero)), style: t.body),
                const SizedBox(height: KassaSpace.s6),
                TextField(
                  controller: _code,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    if (_erreur != null) setState(() => _erreur = null);
                    if (v.length == 6) _verifier();
                  },
                  onSubmitted: (_) => _verifier(),
                  decoration: InputDecoration(
                    labelText: l.codeLabel,
                    counterText: '',
                    errorText: _erreur,
                    errorMaxLines: 3,
                  ),
                ),
                const SizedBox(height: KassaSpace.s2),
                Wrap(
                  spacing: KassaSpace.s2,
                  runSpacing: KassaSpace.s2,
                  children: [
                    KassaButton(
                      label: _attente > 0 ? l.resendIn(_attente) : l.resendCode,
                      icon: Symbols.sms_rounded,
                      variant: KassaButtonVariant.ghost,
                      onPressed: _attente > 0 || _enCours
                          ? null
                          : () => _envoyer(numero: numero),
                    ),
                    KassaButton(
                      label: l.changeNumber,
                      icon: Symbols.edit_rounded,
                      variant: KassaButtonVariant.ghost,
                      onPressed: _enCours ? null : _changerNumero,
                    ),
                  ],
                ),
              ],
              if (_restauration) ...[
                const SizedBox(height: KassaSpace.s6),
                Semantics(
                  liveRegion: true,
                  child: Row(
                    children: [
                      const SizedBox.square(
                        dimension: KassaComposants.iconeBouton,
                        child: CircularProgressIndicator(),
                      ),
                      const SizedBox(width: KassaSpace.s4),
                      Expanded(child: Text(l.restoring, style: t.body)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: KassaButton(
          label: numero == null ? l.sendCode : l.verifyCode,
          icon: numero == null ? Symbols.sms_rounded : Symbols.check_rounded,
          size: KassaButtonSize.main,
          fullWidth: true,
          onPressed: _enCours
              ? null
              : numero == null
              ? _envoyer
              : _verifier,
        ),
      ),
    );
  }
}
