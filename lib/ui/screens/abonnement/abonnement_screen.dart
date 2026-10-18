import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/heure_douala.dart';
import '../../../core/montant.dart';
import '../../../core/telephone.dart';
import '../../../data/abonnement/service_abonnement.dart';
import '../../../data/repositories/ventes_repository.dart';
import '../../../domain/abonnement.dart';
import '../../../domain/panier.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../state/abonnement.dart';
import '../../state/session.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';

/// Fin d'un abonnement, en date courte (« 9 nov. »).
String dateFin(EtatAbonnement etat, String langue) =>
    HeureDouala.dateCourte(etat.fin.subtract(HeureDouala.decalage), langue);

/// Une ligne d'état : « Essai gratuit : 12 jours restants », « Kassa Pro
/// jusqu'au 9 nov. », « Votre essai gratuit est terminé ».
String libelleAbonnement(
  AppLocalizations l,
  EtatAbonnement etat,
  String langue,
) => switch (etat) {
  AbonnementEssai(:final joursRestants) => l.trialDaysLeft(joursRestants),
  AbonnementPro() => l.proUntil(dateFin(etat, langue)),
  AbonnementTermine(:final etaitPro) => etaitPro ? l.proEnded : l.trialEnded,
};

enum _Etape { saisie, attente, reussi }

/// Kassa Pro : l'offre, puis le paiement Mobile Money avec Notch Pay
/// (le commerçant valide sur son téléphone ; l'app attend la confirmation).
class AbonnementScreen extends ConsumerStatefulWidget {
  const AbonnementScreen({super.key});

  /// Intervalle entre deux vérifications du paiement, et leur nombre
  /// (3 minutes en tout).
  static const intervalle = Duration(seconds: 3);
  static const verifications = 60;

  @override
  ConsumerState<AbonnementScreen> createState() => _AbonnementScreenState();
}

class _AbonnementScreenState extends ConsumerState<AbonnementScreen> {
  final _telephone = TextEditingController();
  var _mode = ModeChoisi.momo;
  var _etape = _Etape.saisie;
  String? _erreur;
  bool _numeroFaux = false;
  String _numeroPaye = '';

  /// Change à chaque paiement : une attente remplacée s'arrête.
  var _tentative = 0;

  @override
  void initState() {
    super.initState();
    final s = ref.read(sessionProvider);
    if (s is SessionOuverte) {
      final tel = s.compte.telephone;
      if (tel.startsWith(Telephone.indicatif) && tel.length == 12) {
        // « 6 90 00 00 00 » : plus facile à relire.
        _telephone.text = Telephone.afficher(tel)
            .substring(Telephone.indicatif.length + 2);
      }
    }
  }

  @override
  void dispose() {
    _tentative++;
    _telephone.dispose();
    super.dispose();
  }

  Future<void> _payer() async {
    final l = AppLocalizations.of(context);
    final serveur = ref.read(serveurAbonnementProvider);
    if (serveur == null || _etape != _Etape.saisie) return;
    final numero = Telephone.versInternational(_telephone.text);
    setState(() {
      _numeroFaux = numero == null;
      _erreur = null;
    });
    if (numero == null) return;
    final tentative = ++_tentative;
    setState(() {
      _etape = _Etape.attente;
      _numeroPaye = numero;
    });
    String? reference;
    try {
      reference = await serveur.demanderPaiement(
        operateur: _mode == ModeChoisi.orangeMoney
            ? Operateur.orange
            : Operateur.mtn,
        telephone: numero,
      );
    } on PaiementImpossible catch (e) {
      if (!mounted || tentative != _tentative) return;
      setState(() {
        _etape = _Etape.saisie;
        _erreur = switch (e.raison) {
          ErreurPaiement.demandeEnCours => l.payPending,
          ErreurPaiement.numero => l.errPhone,
          ErreurPaiement.reseau => l.errNetwork,
          ErreurPaiement.autre => l.payRefused,
        };
      });
      return;
    }
    await _attendre(serveur, reference, tentative, l);
  }

  Future<void> _attendre(
    ServeurAbonnement serveur,
    String reference,
    int tentative,
    AppLocalizations l,
  ) async {
    for (var i = 0; i < AbonnementScreen.verifications; i++) {
      await Future<void>.delayed(AbonnementScreen.intervalle);
      if (!mounted || tentative != _tentative) return;
      StatutPaiement statut;
      try {
        statut = await serveur.statut(reference);
      } on Exception {
        continue; // Réseau coupé un instant : on réessaie.
      }
      if (!mounted || tentative != _tentative) return;
      if (statut == StatutPaiement.reussi) {
        await ref.read(abonnementProvider.notifier).rafraichir();
        if (mounted) setState(() => _etape = _Etape.reussi);
        return;
      }
      if (statut == StatutPaiement.echoue) {
        setState(() {
          _etape = _Etape.saisie;
          _erreur = l.payFailed;
        });
        return;
      }
    }
    if (mounted && tentative == _tentative) {
      setState(() {
        _etape = _Etape.saisie;
        _erreur = l.payTimeout;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final etat = ref.watch(abonnementProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l.proTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: ListView(
            padding: const EdgeInsets.all(KassaSpace.s4),
            children: switch (_etape) {
              _Etape.saisie => _saisie(context, etat),
              _Etape.attente => _attente(context),
              _Etape.reussi => _reussite(context, etat),
            },
          ),
        ),
      ),
      bottomNavigationBar: _etape == _Etape.saisie
          ? SafeArea(
              minimum: const EdgeInsets.all(KassaSpace.s4),
              child: KassaButton(
                label: etat is AbonnementPro
                    ? l.payExtend
                    : l.payButton(
                        Montant.format(prixProFcfa, langueDe(context)),
                      ),
                icon: Symbols.smartphone_rounded,
                size: KassaButtonSize.main,
                fullWidth: true,
                onPressed: ref.watch(serveurAbonnementProvider) == null
                    ? null
                    : _payer,
              ),
            )
          : null,
    );
  }

  List<Widget> _saisie(BuildContext context, EtatAbonnement? etat) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final prix = Montant.format(prixProFcfa, langue);
    return [
      if (etat != null) ...[
        _EtatActuel(etat: etat),
        const SizedBox(height: KassaSpace.s6),
      ],
      Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(l.proTitle, style: t.title),
            ),
          ),
          KassaBadge(label: l.proBadge, tone: KassaBadgeTone.or),
        ],
      ),
      const SizedBox(height: KassaSpace.s1),
      Text(l.proPrice(prix), style: t.amountLg.copyWith(color: t.ink)),
      const SizedBox(height: KassaSpace.s4),
      for (final avantage in [
        l.proBenefitRecord,
        l.proBenefitBackup,
        l.proBenefitDays,
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: KassaSpace.s2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Symbols.check_circle_rounded, color: t.kassa),
              const SizedBox(width: KassaSpace.s2),
              Expanded(child: Text(avantage, style: t.body)),
            ],
          ),
        ),
      const SizedBox(height: KassaSpace.s4),
      if (ref.watch(serveurAbonnementProvider) == null)
        Avertissement(texte: l.payUnavailable)
      else ...[
        Semantics(header: true, child: Text(l.payWith, style: t.label)),
        const SizedBox(height: KassaSpace.s2),
        ChoixModePaiement(
          modes: const [ModeChoisi.momo, ModeChoisi.orangeMoney],
          mode: _mode,
          onChanged: (m) => setState(() => _mode = m),
        ),
        const SizedBox(height: KassaSpace.s4),
        TextField(
          controller: _telephone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]')),
          ],
          decoration: InputDecoration(
            labelText: l.payPhoneLabel,
            prefixText: '+${Telephone.indicatif} ',
            errorText: _numeroFaux ? l.errPhone : null,
            errorMaxLines: 3,
          ),
          onSubmitted: (_) => _payer(),
        ),
        if (_erreur != null) ...[
          const SizedBox(height: KassaSpace.s4),
          Semantics(liveRegion: true, child: _Message(texte: _erreur!)),
        ],
      ],
    ];
  }

  List<Widget> _attente(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    return [
      const SizedBox(height: KassaSpace.s6),
      const Center(child: CircularProgressIndicator()),
      const SizedBox(height: KassaSpace.s6),
      Semantics(
        header: true,
        liveRegion: true,
        child: Text(
          l.payWaitingTitle,
          style: t.title,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: KassaSpace.s2),
      Text(
        l.payWaitingBody(
          libelleMode(l, VentesRepository.codeMode(_mode)),
          // Insécables : le numéro ne se coupe pas en fin de ligne.
          Telephone.afficher(_numeroPaye).replaceAll(' ', '\u00A0'),
          Montant.format(prixProFcfa, langue),
        ),
        style: t.body,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: KassaSpace.s6),
      KassaButton(
        label: l.payWaitingLater,
        variant: KassaButtonVariant.secondary,
        fullWidth: true,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    ];
  }

  List<Widget> _reussite(BuildContext context, EtatAbonnement? etat) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    return [
      const SizedBox(height: KassaSpace.s6),
      Icon(
        Symbols.verified_rounded,
        color: t.kassa,
        size: KassaComposants.iconeEtatVide,
      ),
      const SizedBox(height: KassaSpace.s4),
      Semantics(
        liveRegion: true,
        child: Text(
          etat == null ? l.proTitle : l.paySuccess(dateFin(etat, langue)),
          style: t.title,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: KassaSpace.s6),
      KassaButton(
        label: l.done,
        icon: Symbols.check_rounded,
        size: KassaButtonSize.main,
        fullWidth: true,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    ];
  }
}

/// État actuel de l'abonnement, en haut de l'écran.
class _EtatActuel extends StatelessWidget {
  const _EtatActuel({required this.etat});

  final EtatAbonnement etat;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final termine = etat is AbonnementTermine;
    return Container(
      padding: const EdgeInsets.all(KassaSpace.s4),
      decoration: BoxDecoration(
        color: termine ? t.orSoft : t.kassaSoft,
        borderRadius: BorderRadius.circular(KassaRadius.md),
      ),
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              libelleAbonnement(l, etat, langue),
              style: t.label.copyWith(color: termine ? t.orInk : t.ink),
            ),
            const SizedBox(height: KassaSpace.s1),
            Text(switch (etat) {
              AbonnementEssai() => l.trialEndingBody(
                Montant.format(prixProFcfa, langue),
              ),
              AbonnementPro() => l.proBenefitDays,
              AbonnementTermine() => l.readOnlyBody(
                Montant.format(prixProFcfa, langue),
              ),
            }, style: t.body.copyWith(color: termine ? t.orInk : t.ink)),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Container(
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
    );
  }
}
