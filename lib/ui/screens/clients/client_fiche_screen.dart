import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/heure_douala.dart';
import '../../../core/montant.dart';
import '../../../data/db/kassa_database.dart';
import '../../../data/db/tables.dart';
import '../../../data/repositories/clients_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/clients.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';
import 'encaissement_screen.dart';
import 'whatsapp_client.dart';

/// Écran 13 : fiche client. Solde, téléphone, note, historique des achats
/// et versements ; « Rappeler » (WhatsApp) et « Encaisser » si dette.
class ClientFicheScreen extends ConsumerWidget {
  const ClientFicheScreen({super.key, required this.clientId});

  final String clientId;

  Future<void> _encaisser(
    BuildContext context,
    WidgetRef ref,
    Client client,
  ) async {
    // Deux appuis rapides : l'écran d'encaissement n'est ouvert qu'une fois.
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
    final resultat = await context.push<VersementEnregistre>(
      Chemins.encaisser(client.id),
    );
    if (resultat == null || !context.mounted) return;
    await _montrerRecu(context, ref, client, resultat);
  }

  Future<void> _montrerRecu(
    BuildContext context,
    WidgetRef ref,
    Client client,
    VersementEnregistre r,
  ) {
    final l = AppLocalizations.of(context);
    final langue = langueDe(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (feuille) {
        final t = feuille.kassa;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(KassaSpace.s4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Symbols.check_circle_rounded, color: t.kassa),
                    const SizedBox(width: KassaSpace.s2),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(l.paymentRecordedTitle, style: t.title),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KassaSpace.s4),
                Text(
                  l.paymentRecordedBody(
                    Montant.format(r.montant, langue),
                    client.nom,
                  ),
                  style: t.body,
                ),
                Text(
                  r.reste > 0
                      ? l.paymentRemaining(Montant.format(r.reste, langue))
                      : l.paymentPaidOff,
                  style: t.body.copyWith(
                    color: r.reste > 0 ? t.dette : t.kassa,
                  ),
                ),
                const SizedBox(height: KassaSpace.s6),
                if (peutRecevoirWhatsApp(client.telephone)) ...[
                  KassaButton(
                    label: l.sendReceipt,
                    icon: Symbols.chat_rounded,
                    variant: KassaButtonVariant.secondary,
                    fullWidth: true,
                    onPressed: () async {
                      final boutique = await signatureBoutique(ref);
                      if (!feuille.mounted) return;
                      // Le client peut avoir changé pendant l'encaissement.
                      final actuel =
                          ref.read(clientProvider(client.id)).value ?? client;
                      await envoyerWhatsApp(
                        feuille,
                        ref,
                        telephone: actuel.telephone,
                        message: MessagesClient.recu(
                          l,
                          langue,
                          nom: actuel.nom,
                          montant: r.montant,
                          reste: r.reste,
                          date: r.date,
                          boutique: boutique,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: KassaSpace.s2),
                ],
                KassaButton(
                  label: l.done,
                  size: KassaButtonSize.main,
                  fullWidth: true,
                  onPressed: () => Navigator.of(feuille).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final client = ref.watch(clientProvider(clientId));

    return client.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (erreur, pile) => Scaffold(
        appBar: AppBar(),
        body: EtatVide(icone: Symbols.error_rounded, titre: l.loadError),
      ),
      data: (c) {
        if (c == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EtatVide(
              icone: Symbols.person_off_rounded,
              titre: l.customerNotFound,
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(c.nom),
            actions: [
              TextButton.icon(
                onPressed: () => context.push(Chemins.modifierClient(c.id)),
                icon: const Icon(Symbols.edit_rounded),
                label: Text(l.edit),
              ),
              const SizedBox(width: KassaSpace.s2),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: KassaComposants.largeurContenuMax,
              ),
              child: ListView(
                padding: const EdgeInsets.all(KassaSpace.s4),
                children: [
                  _CarteSolde(
                    client: c,
                    onRappel: () => rappelerClient(
                      context,
                      ref,
                      nom: c.nom,
                      telephone: c.telephone,
                      solde: c.soldeDette,
                    ),
                  ),
                  const SizedBox(height: KassaSpace.s6),
                  _Historique(clientId: c.id),
                ],
              ),
            ),
          ),
          bottomNavigationBar: c.soldeDette > 0
              ? SafeArea(
                  minimum: const EdgeInsets.all(KassaSpace.s4),
                  child: KassaButton(
                    label: l.collectPayment,
                    icon: Symbols.payments_rounded,
                    size: KassaButtonSize.main,
                    fullWidth: true,
                    onPressed: () => _encaisser(context, ref, c),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _CarteSolde extends StatelessWidget {
  const _CarteSolde({required this.client, required this.onRappel});

  final Client client;
  final VoidCallback onRappel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final doit = client.soldeDette > 0;
    final peutRappeler = peutRecevoirWhatsApp(client.telephone);

    return Container(
      padding: const EdgeInsets.all(KassaSpace.s4),
      decoration: BoxDecoration(
        color: t.surfaceRaised,
        borderRadius: BorderRadius.circular(KassaRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.balance, style: t.label.copyWith(color: t.inkMuted)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: doit
                      ? AmountText(
                          value: client.soldeDette,
                          tone: AmountTone.dette,
                          size: AmountSize.lg,
                        )
                      : Text(
                          l.paidUp,
                          style: t.amountLg.copyWith(color: t.kassa),
                        ),
                ),
              ],
            ),
          ),
          if (client.telephone != null) ...[
            const SizedBox(height: KassaSpace.s2),
            _Info(icone: Symbols.call_rounded, texte: client.telephone!),
          ],
          if (client.note != null) ...[
            const SizedBox(height: KassaSpace.s2),
            _Info(icone: Symbols.sticky_note_2_rounded, texte: client.note!),
          ],
          if (doit) ...[
            const SizedBox(height: KassaSpace.s4),
            if (peutRappeler)
              KassaButton(
                label: l.remind,
                icon: Symbols.chat_rounded,
                variant: KassaButtonVariant.secondary,
                fullWidth: true,
                semanticLabel: l.remindOnWhatsapp(client.nom),
                onPressed: onRappel,
              )
            else
              Text(
                l.addPhoneToRemind,
                style: t.caption.copyWith(color: t.inkMuted),
              ),
          ],
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icone, required this.texte});

  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Icon(
            icone,
            size: KassaComposants.iconeEtiquette,
            color: t.inkMuted,
          ),
        ),
        const SizedBox(width: KassaSpace.s2),
        Expanded(child: Text(texte, style: t.body)),
      ],
    );
  }
}

class _Historique extends ConsumerWidget {
  const _Historique({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final historique = ref.watch(historiqueClientProvider(clientId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text(l.history, style: t.title)),
        const SizedBox(height: KassaSpace.s2),
        historique.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erreur, pile) =>
              Text(l.loadError, style: t.body.copyWith(color: t.dette)),
          data: (operations) => operations.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: KassaSpace.s4),
                  child: Text(
                    l.customerHistoryEmpty,
                    style: t.body.copyWith(color: t.inkMuted),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(KassaRadius.md),
                  child: Column(
                    children: [
                      for (final (i, o) in operations.indexed) ...[
                        if (i > 0) const Divider(),
                        _LigneOperation(operation: o),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _LigneOperation extends StatelessWidget {
  const _LigneOperation({required this.operation});

  final OperationClient operation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final date = l.saleDateTime(
      HeureDouala.dateCourte(operation.date, langue),
      HeureDouala.heure(operation.date, langue),
    );

    // Une ligne, un montant : ce que l'achat a ajouté à la dette (crédit),
    // ce qui a été payé comptant, ou le versement reçu.
    final (titre, sousTitre, montant, badge, onTap) = switch (operation) {
      AchatClient(:final vente) => (
        vente.modePaiement == ModePaiement.credit
            ? l.creditPurchaseNumber(vente.numero)
            : l.purchaseNumber(vente.numero),
        vente.resteAPayer > 0 && !vente.annulee
            ? l.dateAndTotal(
                date,
                Montant.format(vente.total, langue, court: true),
              )
            : date,
        vente.resteAPayer > 0 && !vente.annulee
            ? AmountText(
                value: vente.resteAPayer,
                tone: AmountTone.dette,
                short: true,
              )
            : AmountText(value: vente.total, short: true),
        vente.annulee
            ? KassaBadge(label: l.cancelled, tone: KassaBadgeTone.dette)
            : null,
        () => context.push(Chemins.vente(vente.id)),
      ),
      VersementClient(:final versement) => (
        l.debtPayment(libelleMode(l, versement.modePaiement)),
        date,
        AmountText(
          value: versement.montant,
          tone: AmountTone.encaisse,
          short: true,
        ),
        null,
        null,
      ),
    };

    return Material(
      color: t.surfaceRaised,
      child: MergeSemantics(
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: KassaSize.touchMin),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KassaSpace.s4,
                vertical: KassaSpace.s2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titre,
                          style: t.label.copyWith(
                            fontSize: t.body.fontSize,
                            height: t.body.height,
                          ),
                        ),
                        Text(
                          sousTitre,
                          style: t.caption.copyWith(color: t.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: KassaSpace.s2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [montant, ?badge],
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
