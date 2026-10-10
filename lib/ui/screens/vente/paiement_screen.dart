import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/montant.dart';
import '../../../data/db/kassa_database.dart';
import '../../../data/providers.dart';
import '../../../domain/panier.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../state/vente.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';
import 'choix_client_sheet.dart';

/// Écran 7 : paiement de la vente.
///
/// Espèces : montant reçu au pavé (vide = montant exact), monnaie à rendre.
/// MoMo / Orange Money : le total. Crédit : client + avance (0 possible),
/// le reste s'ajoute à sa dette.
class PaiementScreen extends ConsumerStatefulWidget {
  const PaiementScreen({super.key});

  @override
  ConsumerState<PaiementScreen> createState() => _PaiementScreenState();
}

class _PaiementScreenState extends ConsumerState<PaiementScreen> {
  var _mode = ModeChoisi.especes;
  var _saisie = '';
  String? _clientId;
  var _clientManquant = false;
  var _enCours = false;

  int? get _montantSaisi => _saisie.isEmpty ? null : NumPad.enEntier(_saisie);

  void _changerMode(ModeChoisi mode) => setState(() {
    _mode = mode;
    _saisie = '';
    _clientManquant = false;
  });

  Future<void> _choisirClient() async {
    final id = await choisirClient(context);
    if (id != null && mounted) {
      setState(() {
        _clientId = id;
        _clientManquant = false;
      });
    }
  }

  Future<void> _valider(Panier panier, CalculPaiement paiement) async {
    final l = AppLocalizations.of(context);
    if (_mode == ModeChoisi.credit && _clientId == null) {
      setState(() => _clientManquant = true);
      return;
    }
    setState(() => _enCours = true);
    try {
      final utilisateur = await ref
          .read(boutiqueRepositoryProvider)
          .utilisateurCourant();
      final vente = await ref
          .read(ventesRepositoryProvider)
          .enregistrerVente(
            panier: panier,
            mode: _mode,
            paiement: paiement,
            utilisateurId: utilisateur.id,
            clientId: _mode == ModeChoisi.credit ? _clientId : null,
          );
      if (!mounted) return;
      final langue = langueDe(context);
      final messager = ScaffoldMessenger.of(context);
      ref.read(panierProvider.notifier).vider();
      context.pop();
      messager
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              paiement.monnaie > 0
                  ? l.saleRecordedChange(
                      vente.numero,
                      Montant.format(paiement.monnaie, langue),
                    )
                  : l.saleRecorded(
                      vente.numero,
                      Montant.format(vente.total, langue),
                    ),
            ),
          ),
        );
    } on Object {
      if (mounted) {
        setState(() => _enCours = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.saveError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final panier = ref.watch(panierProvider);
    final paiement = CalculPaiement.pour(
      mode: _mode,
      total: panier.total,
      saisi: _montantSaisi,
    );
    final bloque = _mode == ModeChoisi.especes && paiement.manque > 0;

    return Scaffold(
      appBar: AppBar(title: Text(l.paymentTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: ListView(
            padding: const EdgeInsets.all(KassaSpace.s4),
            children: [
              MergeSemantics(
                child: Container(
                  padding: const EdgeInsets.all(KassaSpace.s4),
                  decoration: BoxDecoration(
                    color: t.surfaceRaised,
                    borderRadius: BorderRadius.circular(KassaRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l.totalToPay} · ${l.productsCount(panier.lignes.length)}',
                        style: t.label.copyWith(color: t.inkMuted),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AmountText(
                          value: panier.total,
                          size: AmountSize.lg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: KassaSpace.s4),
              _ChoixMode(mode: _mode, onChanged: _changerMode),
              const SizedBox(height: KassaSpace.s4),
              ...switch (_mode) {
                ModeChoisi.especes => _especes(l, t, langue, panier, paiement),
                ModeChoisi.momo || ModeChoisi.orangeMoney => [
                  Container(
                    padding: const EdgeInsets.all(KassaSpace.s4),
                    decoration: BoxDecoration(
                      color: t.kassaSoft,
                      borderRadius: BorderRadius.circular(KassaRadius.md),
                    ),
                    child: Text(
                      l.mobileMoneyHint(Montant.format(panier.total, langue)),
                      style: t.body,
                    ),
                  ),
                ],
                ModeChoisi.credit => _credit(l, t, paiement),
              },
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: KassaButton(
          label: _mode == ModeChoisi.credit
              ? l.sellOnCredit
              : l.collectAmount(Montant.format(panier.total, langue)),
          icon: _mode == ModeChoisi.credit
              ? Symbols.menu_book_rounded
              : Symbols.payments_rounded,
          size: KassaButtonSize.main,
          fullWidth: true,
          onPressed: _enCours || bloque || panier.estVide
              ? null
              : () => _valider(panier, paiement),
        ),
      ),
    );
  }

  List<Widget> _especes(
    AppLocalizations l,
    KassaTokens t,
    String langue,
    Panier panier,
    CalculPaiement paiement,
  ) {
    final propositions = montantsProposes(panier.total);
    return [
      Text(l.amountReceived, style: t.label),
      Text(l.amountReceivedHint, style: t.caption.copyWith(color: t.inkMuted)),
      const SizedBox(height: KassaSpace.s2),
      Wrap(
        spacing: KassaSpace.s2,
        runSpacing: KassaSpace.s2,
        children: [
          for (final montant in propositions)
            ChoiceChip(
              label: Text(Montant.format(montant, langue, court: true)),
              selected: _montantSaisi == montant,
              showCheckmark: false,
              onSelected: (_) => setState(() => _saisie = '$montant'),
            ),
        ],
      ),
      const SizedBox(height: KassaSpace.s2),
      NumPad(valeur: _saisie, onChanged: (v) => setState(() => _saisie = v)),
      const SizedBox(height: KassaSpace.s4),
      if (paiement.manque > 0)
        MessageDette(
          texte: l.missingAmount(Montant.format(paiement.manque, langue)),
        )
      else
        _Resultat(
          libelle: l.changeToGive,
          montant: paiement.monnaie,
          tone: AmountTone.encaisse,
        ),
    ];
  }

  List<Widget> _credit(
    AppLocalizations l,
    KassaTokens t,
    CalculPaiement paiement,
  ) {
    final client = (ref.watch(clientsProvider).value ?? const <Client>[])
        .where((c) => c.id == _clientId)
        .firstOrNull;
    return [
      Text(l.customer, style: t.label),
      const SizedBox(height: KassaSpace.s2),
      if (client == null)
        KassaButton(
          label: l.chooseCustomer,
          icon: Symbols.person_search_rounded,
          variant: KassaButtonVariant.secondary,
          fullWidth: true,
          onPressed: _choisirClient,
        )
      else
        ClipRRect(
          borderRadius: BorderRadius.circular(KassaRadius.md),
          child: Row(
            children: [
              Expanded(
                child: ClientRow(
                  nom: client.nom,
                  meta: client.telephone ?? '',
                  montantDu: client.soldeDette,
                  onTap: _choisirClient,
                ),
              ),
            ],
          ),
        ),
      if (client != null)
        Align(
          alignment: Alignment.centerRight,
          child: KassaButton(
            label: l.changeCustomer,
            variant: KassaButtonVariant.ghost,
            onPressed: _choisirClient,
          ),
        ),
      if (_clientManquant) ...[
        const SizedBox(height: KassaSpace.s2),
        MessageDette(texte: l.errChooseCustomer),
      ],
      const SizedBox(height: KassaSpace.s4),
      Text(l.advancePaid, style: t.label),
      Text(l.advancePaidHint, style: t.caption.copyWith(color: t.inkMuted)),
      const SizedBox(height: KassaSpace.s2),
      // Le reste à payer passe au-dessus du pavé pour rester visible
      // sans défiler, même avec le bloc client.
      _Resultat(
        libelle: l.remainingDebt,
        montant: paiement.resteAPayer,
        tone: AmountTone.dette,
      ),
      if (paiement.monnaie > 0) ...[
        const SizedBox(height: KassaSpace.s2),
        _Resultat(
          libelle: l.changeToGive,
          montant: paiement.monnaie,
          tone: AmountTone.encaisse,
        ),
      ],
      const SizedBox(height: KassaSpace.s2),
      NumPad(valeur: _saisie, onChanged: (v) => setState(() => _saisie = v)),
    ];
  }
}

class _ChoixMode extends StatelessWidget {
  const _ChoixMode({required this.mode, required this.onChanged});

  final ModeChoisi mode;
  final ValueChanged<ModeChoisi> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final modes = ModeChoisi.values;
    return Column(
      children: [
        for (var ligne = 0; ligne < 2; ligne++) ...[
          if (ligne > 0) const SizedBox(height: KassaSpace.s2),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: KassaSpace.s2),
                  Expanded(
                    child: _TuileMode(
                      mode: modes[ligne * 2 + col],
                      choisi: mode == modes[ligne * 2 + col],
                      libelle: libelleModeChoisi(l, modes[ligne * 2 + col]),
                      onTap: () => onChanged(modes[ligne * 2 + col]),
                      tokens: t,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TuileMode extends StatelessWidget {
  const _TuileMode({
    required this.mode,
    required this.choisi,
    required this.libelle,
    required this.onTap,
    required this.tokens,
  });

  final ModeChoisi mode;
  final bool choisi;
  final String libelle;
  final VoidCallback onTap;
  final KassaTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final couleur = choisi ? t.kassa : t.ink;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: choisi,
      button: true,
      child: Material(
        color: choisi ? t.kassaSoft : t.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KassaRadius.md),
          side: BorderSide(
            color: choisi ? t.kassa : t.line,
            width: KassaComposants.trait,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: KassaSize.buttonMain),
            child: Padding(
              padding: const EdgeInsets.all(KassaSpace.s2),
              child: Row(
                children: [
                  Icon(iconeMode(mode), color: couleur),
                  const SizedBox(width: KassaSpace.s2),
                  Expanded(
                    child: Text(
                      libelle,
                      style: t.label.copyWith(color: couleur),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Resultat extends StatelessWidget {
  const _Resultat({
    required this.libelle,
    required this.montant,
    required this.tone,
  });

  final String libelle;
  final int montant;
  final AmountTone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return MergeSemantics(
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(KassaSpace.s4),
          decoration: BoxDecoration(
            color: tone == AmountTone.dette ? t.detteSoft : t.kassaSoft,
            borderRadius: BorderRadius.circular(KassaRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(libelle, style: t.label.copyWith(color: t.ink)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AmountText(
                  value: montant,
                  tone: montant == 0 ? AmountTone.neutre : tone,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
