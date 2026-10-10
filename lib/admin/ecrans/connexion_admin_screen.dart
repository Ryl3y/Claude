import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../ui/brand/kassa_logo.dart';
import '../../ui/theme/kassa_tokens.dart';
import '../../ui/widgets/kassa_button.dart';
import '../donnees/auth_admin.dart';
import '../etat/etat_admin.dart';

/// Connexion de l'équipe Kassa par e-mail et mot de passe.
class ConnexionAdminScreen extends ConsumerStatefulWidget {
  const ConnexionAdminScreen({super.key});

  @override
  ConsumerState<ConnexionAdminScreen> createState() =>
      _ConnexionAdminScreenState();
}

class _ConnexionAdminScreenState extends ConsumerState<ConnexionAdminScreen> {
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();
  var _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  Future<void> _connecter() async {
    final l = AppLocalizations.of(context);
    if (_enCours) return;
    if (_email.text.trim().isEmpty || _motDePasse.text.isEmpty) {
      setState(() => _erreur = l.adminErrEmpty);
      return;
    }
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      await ref
          .read(sessionAdminProvider.notifier)
          .connecter(_email.text, _motDePasse.text);
    } on ConnexionAdminImpossible catch (e) {
      if (!mounted) return;
      setState(() {
        _enCours = false;
        _motDePasse.clear();
        _erreur = switch (e.raison) {
          ErreurConnexionAdmin.identifiants => l.adminErrCredentials,
          ErreurConnexionAdmin.pasAdmin => l.adminErrNotAdmin,
          ErreurConnexionAdmin.tropDeDemandes => l.adminErrTooMany,
          ErreurConnexionAdmin.reseau => l.errNetwork,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    // Reprise d'une session gardée : on attend la réponse du serveur.
    if (ref.watch(sessionAdminProvider) is AdminChargement) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KassaSpace.s4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(KassaSpace.s6),
              decoration: BoxDecoration(
                color: t.surfaceRaised,
                borderRadius: BorderRadius.circular(KassaRadius.lg),
              ),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: KassaLogo(taille: 32),
                    ),
                    const SizedBox(height: KassaSpace.s6),
                    Semantics(
                      header: true,
                      child: Text(l.adminLoginTitle, style: t.title),
                    ),
                    const SizedBox(height: KassaSpace.s1),
                    Text(
                      l.adminLoginBody,
                      style: t.body.copyWith(color: t.inkMuted),
                    ),
                    const SizedBox(height: KassaSpace.s6),
                    TextField(
                      controller: _email,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: l.adminEmail),
                    ),
                    const SizedBox(height: KassaSpace.s4),
                    TextField(
                      controller: _motDePasse,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _connecter(),
                      decoration: InputDecoration(labelText: l.adminPassword),
                    ),
                    if (_erreur != null) ...[
                      const SizedBox(height: KassaSpace.s4),
                      Semantics(
                        liveRegion: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Symbols.error_rounded, color: t.dette),
                            const SizedBox(width: KassaSpace.s2),
                            Expanded(
                              child: Text(
                                _erreur!,
                                style: t.label.copyWith(color: t.dette),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: KassaSpace.s6),
                    KassaButton(
                      label: l.adminLogin,
                      icon: Symbols.login_rounded,
                      size: KassaButtonSize.main,
                      fullWidth: true,
                      onPressed: _enCours ? null : _connecter,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
