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
import '../abonnement/garde_abonnement.dart';

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
    if (!await ecritureAutorisee(context, ref) || !mounted) return;
    final l = AppLocalizations.of(context);
    if (_mode == ModeChoisi.credit && _clientId == null) {
      setState(() => _clientManquant = true);
      return;
    }
    // Deux appuis rapides avant le rebuild : une seule vente.
    if (_enCours) return;
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
              ChoixModePaiement(
                modes: ModeChoisi.values,
                mode: _mode,
                onChanged: _changerMode,
              ),
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
              // Rien de saisi = montant exact : sa puce est choisie.
              selected: (_montantSaisi ?? panier.total) == montant,
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
        ResultatMontant(
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
      ResultatMontant(
        libelle: l.remainingDebt,
        montant: paiement.resteAPayer,
        tone: AmountTone.dette,
      ),
      if (paiement.monnaie > 0) ...[
        const SizedBox(height: KassaSpace.s2),
        ResultatMontant(
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
