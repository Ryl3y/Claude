import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/telephone.dart';
import '../../../domain/abonnement.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/abonnement.dart';
import '../../state/rapports.dart';
import '../../state/session.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';
import '../abonnement/abonnement_screen.dart';

/// Écran 15 : réglages. Langue, abonnement Kassa Pro, sauvegarde en
/// ligne, et déconnexion de ce téléphone.
class ReglagesScreen extends ConsumerStatefulWidget {
  const ReglagesScreen({super.key});

  @override
  ConsumerState<ReglagesScreen> createState() => _ReglagesScreenState();
}

class _ReglagesScreenState extends ConsumerState<ReglagesScreen> {
  var _sauvegardeEnCours = false;
  var _deconnexionEnCours = false;

  Future<void> _sauvegarder() async {
    final planificateur = ref.read(planificateurSynchroProvider);
    if (planificateur == null || _sauvegardeEnCours) return;
    final l = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    setState(() => _sauvegardeEnCours = true);
    final bilan = await planificateur.lancer();
    if (!mounted) return;
    setState(() => _sauvegardeEnCours = false);
    messager
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(bilan.reussi ? l.backupDone : l.backupFailed)),
      );
  }

  Future<void> _deconnecter() async {
    final l = AppLocalizations.of(context);
    final enLigne = ref.read(synchroServiceProvider) != null;
    final enAttente = ref.read(enAttenteProvider).value ?? 0;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogue) {
        final t = dialogue.kassa;
        return AlertDialog(
          title: Text(l.logoutTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(enLigne ? l.logoutBody : l.logoutLocalOnly, style: t.body),
                if (enLigne && enAttente > 0) ...[
                  const SizedBox(height: KassaSpace.s4),
                  Avertissement(texte: l.logoutPending(enAttente)),
                ],
              ],
            ),
          ),
          actions: [
            KassaButton(
              label: l.cancel,
              variant: KassaButtonVariant.ghost,
              onPressed: () => Navigator.of(dialogue).pop(false),
            ),
            KassaButton(
              label: l.logoutConfirm,
              icon: Symbols.logout_rounded,
              variant: KassaButtonVariant.danger,
              onPressed: () => Navigator.of(dialogue).pop(true),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    setState(() => _deconnexionEnCours = true);
    final messager = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(sessionProvider.notifier)
          .deconnecter(
            attendreSynchro: ref.read(synchroServiceProvider)?.attendreFin,
          );
    } on Object {
      if (!mounted) return;
      setState(() => _deconnexionEnCours = false);
      messager.showSnackBar(SnackBar(content: Text(l.errOther)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final session = ref.watch(sessionProvider);
    final compte = session is SessionOuverte ? session.compte : null;
    final abonnement = ref.watch(abonnementProvider).value;
    final enLigne = ref.watch(synchroServiceProvider) != null;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: ListView(
            padding: const EdgeInsets.all(KassaSpace.s4),
            children: [
              _Section(titre: l.language, child: const ChoixLangue()),
              _Section(
                titre: l.settingsSubscription,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (abonnement != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              libelleAbonnement(l, abonnement, langue),
                              style: t.body,
                            ),
                          ),
                          if (abonnement is AbonnementPro)
                            KassaBadge(
                              label: l.proBadge,
                              tone: KassaBadgeTone.or,
                            ),
                        ],
                      ),
                      if (abonnement is AbonnementEssai)
                        Text(
                          l.trialUntil(dateFin(abonnement, langue)),
                          style: t.caption.copyWith(color: t.inkMuted),
                        ),
                      const SizedBox(height: KassaSpace.s2),
                    ],
                    KassaButton(
                      label: abonnement is AbonnementPro
                          ? l.payExtend
                          : l.goPro,
                      icon: Symbols.workspace_premium_rounded,
                      variant: abonnement is AbonnementPro
                          ? KassaButtonVariant.secondary
                          : KassaButtonVariant.or,
                      fullWidth: true,
                      onPressed: () => context.push(Chemins.abonnement),
                    ),
                  ],
                ),
              ),
              _Section(
                titre: l.settingsBackup,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EtatSauvegarde(etat: ref.watch(etatSauvegardeProvider)),
                    if (enLigne) ...[
                      const SizedBox(height: KassaSpace.s2),
                      KassaButton(
                        label: l.backupNow,
                        icon: Symbols.cloud_upload_rounded,
                        variant: KassaButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: _sauvegardeEnCours ? null : _sauvegarder,
                      ),
                    ],
                  ],
                ),
              ),
              _Section(
                titre: l.settingsAccount,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (compte != null &&
                        compte.telephone.startsWith(Telephone.indicatif))
                      Text(Telephone.afficher(compte.telephone), style: t.body),
                    const SizedBox(height: KassaSpace.s2),
                    KassaButton(
                      label: l.logout,
                      icon: Symbols.logout_rounded,
                      variant: KassaButtonVariant.danger,
                      fullWidth: true,
                      onPressed: _deconnexionEnCours ? null : _deconnecter,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.titre, required this.child});

  final String titre;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Padding(
      padding: const EdgeInsets.only(bottom: KassaSpace.s6),
      child: Container(
        padding: const EdgeInsets.all(KassaSpace.s4),
        decoration: BoxDecoration(
          color: t.surfaceRaised,
          borderRadius: BorderRadius.circular(KassaRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(titre, style: t.label.copyWith(color: t.inkMuted)),
            ),
            const SizedBox(height: KassaSpace.s2),
            child,
          ],
        ),
      ),
    );
  }
}

/// État de la sauvegarde, en clair : icône, mot, et ce que cela veut dire.
class _EtatSauvegarde extends StatelessWidget {
  const _EtatSauvegarde({required this.etat});

  final EtatSauvegarde etat;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final (icone, libelle, aide) = switch (etat) {
      EtatSauvegarde.sauvegarde => (
        Symbols.cloud_done_rounded,
        l.saved,
        l.saveStateSavedHelp,
      ),
      EtatSauvegarde.enAttente => (
        Symbols.cloud_upload_rounded,
        l.saveStatePending,
        l.saveStatePendingHelp,
      ),
      EtatSauvegarde.surCeTelephone => (
        Symbols.smartphone_rounded,
        l.saveStateLocal,
        l.saveStateLocalHelp,
      ),
    };
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icone,
                color: etat == EtatSauvegarde.sauvegarde ? t.kassa : t.ink,
              ),
              const SizedBox(width: KassaSpace.s2),
              Expanded(child: Text(libelle, style: t.label)),
            ],
          ),
          const SizedBox(height: KassaSpace.s1),
          Text(aide, style: t.body),
        ],
      ),
    );
  }
}
