import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/montant.dart';
import '../../../data/db/kassa_database.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/clients_repository.dart';
import '../../../domain/panier.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../state/clients.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';
import '../abonnement/garde_abonnement.dart';

/// Ce que l'écran d'encaissement renvoie à la fiche client.
class VersementEnregistre {
  const VersementEnregistre({
    required this.montant,
    required this.reste,
    required this.date,
  });

  final int montant;

  /// Dette restante après le versement.
  final int reste;
  final DateTime date;
}

/// Encaissement d'une dette : mode (espèces, MoMo, Orange Money), montant
/// au pavé (au plus la dette), puis versement enregistré et solde recalculé.
class EncaissementScreen extends ConsumerStatefulWidget {
  const EncaissementScreen({super.key, required this.clientId});

  final String clientId;

  /// Modes possibles pour un versement (pas de crédit).
  static const modes = [
    ModeChoisi.especes,
    ModeChoisi.momo,
    ModeChoisi.orangeMoney,
  ];

  @override
  ConsumerState<EncaissementScreen> createState() => _EncaissementScreenState();
}

class _EncaissementScreenState extends ConsumerState<EncaissementScreen> {
  var _mode = ModeChoisi.especes;
  var _saisie = '';
  var _enCours = false;

  int get _montant => NumPad.enEntier(_saisie);

  Future<void> _valider(Client client) async {
    if (!await ecritureAutorisee(context, ref) || !mounted) return;
    if (_enCours) return;
    final l = AppLocalizations.of(context);
    setState(() => _enCours = true);
    try {
      final r = await ref
          .read(clientsRepositoryProvider)
          .enregistrerVersement(
            clientId: client.id,
            montant: _montant,
            mode: _mode,
          );
      if (!mounted) return;
      Navigator.of(context).pop(
        VersementEnregistre(
          montant: r.versement.montant,
          reste: r.reste,
          date: r.versement.dateVersement,
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _enCours = false);
      final langue = langueDe(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is VersementTropGrand
                ? l.errPaymentTooHigh(
                    client.nom,
                    Montant.format(e.soldeDette, langue),
                  )
                : l.saveError,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final client = ref.watch(clientProvider(widget.clientId));

    return client.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (erreur, pile) => Scaffold(
        appBar: AppBar(),
        body: EtatVide(icone: Symbols.error_rounded, titre: l.loadError),
      ),
      data: (c) => c == null
          ? Scaffold(
              appBar: AppBar(),
              body: EtatVide(
                icone: Symbols.person_off_rounded,
                titre: l.customerNotFound,
              ),
            )
          : c.soldeDette <= 0
          ? Scaffold(
              appBar: AppBar(title: Text(l.collectDebtTitle)),
              body: EtatVide(
                icone: Symbols.check_circle_rounded,
                titre: l.paymentPaidOff,
              ),
            )
          : _contenu(c),
    );
  }

  Widget _contenu(Client c) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final dette = c.soldeDette;
    final montant = _montant;
    final tropGrand = montant > dette;
    final reste = tropGrand ? dette : dette - montant;

    return Scaffold(
      appBar: AppBar(title: Text(l.collectDebtTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: ListView(
            padding: const EdgeInsets.all(KassaSpace.s4),
            children: [
              Container(
                padding: const EdgeInsets.all(KassaSpace.s4),
                decoration: BoxDecoration(
                  color: t.surfaceRaised,
                  borderRadius: BorderRadius.circular(KassaRadius.md),
                ),
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.nom, style: t.label.copyWith(color: t.inkMuted)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AmountText(
                          value: dette,
                          tone: AmountTone.dette,
                          size: AmountSize.lg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: KassaSpace.s4),
              ChoixModePaiement(
                modes: EncaissementScreen.modes,
                mode: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
              const SizedBox(height: KassaSpace.s4),
              Text(l.amountPaidNow, style: t.label),
              Text(
                l.amountPaidNowHint,
                style: t.caption.copyWith(color: t.inkMuted),
              ),
              const SizedBox(height: KassaSpace.s2),
              Wrap(
                children: [
                  ChoiceChip(
                    label: Text(
                      l.wholeDebt(Montant.format(dette, langue, court: true)),
                    ),
                    selected: montant == dette,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _saisie = '$dette'),
                  ),
                ],
              ),
              const SizedBox(height: KassaSpace.s2),
              if (tropGrand)
                MessageDette(
                  texte: l.errPaymentTooHigh(
                    c.nom,
                    Montant.format(dette, langue),
                  ),
                )
              else
                ResultatMontant(
                  libelle: reste == 0
                      ? l.debtPaidOffLabel
                      : l.remainingAfterPayment,
                  montant: reste,
                  tone: reste == 0 ? AmountTone.encaisse : AmountTone.dette,
                ),
              const SizedBox(height: KassaSpace.s2),
              NumPad(
                valeur: _saisie,
                onChanged: (v) => setState(() => _saisie = v),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: KassaButton(
          label: montant > 0
              ? l.collectAmount(Montant.format(montant, langue))
              : l.collectPayment,
          icon: Symbols.payments_rounded,
          size: KassaButtonSize.main,
          fullWidth: true,
          onPressed: _enCours || montant == 0 || tropGrand
              ? null
              : () => _valider(c),
        ),
      ),
    );
  }
}
