import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/heure_douala.dart';
import '../../../core/montant.dart';
import '../../../data/db/kassa_database.dart';
import '../../../data/db/tables.dart';
import '../../../data/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/vente.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';

/// Ventes d'un jour choisi (null = toutes), les plus récentes d'abord.
final _ventesProvider = StreamProvider.family<List<Vente>, DateTime?>((
  ref,
  jour,
) {
  final repo = ref.watch(ventesRepositoryProvider);
  if (jour == null) return repo.surveillerVentes();
  final debut = HeureDouala.debutDuJourUtc(jour);
  return repo.surveillerVentes(
    depuis: debut,
    jusqua: debut.add(const Duration(days: 1)),
  );
});

/// Écran 8 : historique des ventes, regroupées par jour (heure de Douala),
/// filtre par date, accès au détail et à l'annulation.
class HistoriqueScreen extends ConsumerStatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  ConsumerState<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends ConsumerState<HistoriqueScreen> {
  /// Jour choisi (UTC, à midi heure de Douala) ; null = toutes les dates.
  DateTime? _jour;

  Future<void> _choisirDate() async {
    final maintenant = HeureDouala.versDouala(HeureDouala.maintenantUtc());
    final choisi = await showDatePicker(
      context: context,
      initialDate: _jour == null ? maintenant : HeureDouala.versDouala(_jour!),
      firstDate: DateTime(maintenant.year - 5),
      lastDate: maintenant,
    );
    if (choisi == null) return;
    // Midi à Douala = 11 h UTC : le jour ne bascule jamais.
    setState(
      () => _jour = DateTime.utc(choisi.year, choisi.month, choisi.day, 11),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final langue = langueDe(context);
    final ventes = ref.watch(_ventesProvider(_jour));
    final clients = {
      for (final c in ref.watch(clientsProvider).value ?? const <Client>[])
        c.id: c.nom,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KassaSpace.s4,
                  KassaSpace.s2,
                  KassaSpace.s4,
                  KassaSpace.s2,
                ),
                child: Wrap(
                  spacing: KassaSpace.s2,
                  runSpacing: KassaSpace.s2,
                  children: [
                    ChoiceChip(
                      label: Text(l.allDates),
                      selected: _jour == null,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _jour = null),
                    ),
                    ChoiceChip(
                      avatar: const Icon(Symbols.calendar_month_rounded),
                      label: Text(
                        _jour == null
                            ? l.chooseDate
                            : _libelleJour(l, langue, _jour!),
                      ),
                      selected: _jour != null,
                      showCheckmark: false,
                      onSelected: (_) => _choisirDate(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ventes.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (erreur, pile) => EtatVide(
                    icone: Symbols.error_rounded,
                    titre: l.loadError,
                  ),
                  data: (liste) {
                    if (liste.isEmpty) {
                      return _jour == null
                          ? EtatVide(
                              icone: Symbols.receipt_long_rounded,
                              titre: l.historyEmptyTitle,
                              message: l.historyEmptyBody,
                            )
                          : EtatVide(
                              icone: Symbols.event_busy_rounded,
                              titre: l.historyEmptyDay,
                            );
                    }
                    return _ListeParJour(ventes: liste, clients: clients);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// « Aujourd'hui », « Hier » ou la date courte (« 8 oct. »).
String _libelleJour(AppLocalizations l, String langue, DateTime instant) {
  final aujourdhui = HeureDouala.debutDuJourUtc(HeureDouala.maintenantUtc());
  final jour = HeureDouala.debutDuJourUtc(instant);
  if (jour == aujourdhui) return l.today;
  if (jour == aujourdhui.subtract(const Duration(days: 1))) return l.yesterday;
  return HeureDouala.dateCourte(instant, langue);
}

class _ListeParJour extends StatelessWidget {
  const _ListeParJour({required this.ventes, required this.clients});

  final List<Vente> ventes;
  final Map<String, String> clients;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);

    final jours = <DateTime, List<Vente>>{};
    for (final v in ventes) {
      jours
          .putIfAbsent(HeureDouala.debutDuJourUtc(v.dateVente), () => [])
          .add(v);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: KassaSpace.s6),
      children: [
        for (final duJour in jours.values) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KassaSpace.s4,
              KassaSpace.s4,
              KassaSpace.s4,
              KassaSpace.s2,
            ),
            child: MergeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        _libelleJour(l, langue, duJour.first.dateVente),
                        style: t.title,
                      ),
                    ),
                  ),
                  Text(
                    l.daySummary(
                      duJour.where((v) => !v.annulee).length,
                      Montant.format(
                        duJour
                            .where((v) => !v.annulee)
                            .fold(0, (s, v) => s + v.total),
                        langue,
                        court: true,
                      ),
                    ),
                    style: t.label.copyWith(color: t.inkMuted),
                  ),
                ],
              ),
            ),
          ),
          for (final (i, v) in duJour.indexed) ...[
            if (i > 0) const Divider(),
            _LigneVente(vente: v, client: clients[v.clientId]),
          ],
        ],
      ],
    );
  }
}

class _LigneVente extends StatelessWidget {
  const _LigneVente({required this.vente, required this.client});

  final Vente vente;
  final String? client;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final details = [libelleMode(l, vente.modePaiement), ?client].join(' · ');

    return Material(
      color: t.surfaceRaised,
      child: MergeSemantics(
        child: InkWell(
          onTap: () => context.push(Chemins.vente(vente.id)),
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
                        l.saleNumberTime(
                          vente.numero,
                          HeureDouala.heure(vente.dateVente, langue),
                        ),
                        style: t.label.copyWith(
                          fontSize: t.body.fontSize,
                          height: t.body.height,
                        ),
                      ),
                      Text(
                        details,
                        style: t.caption.copyWith(color: t.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: KassaSpace.s2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AmountText(
                      value: vente.total,
                      short: true,
                      tone: vente.annulee
                          ? AmountTone.neutre
                          : vente.modePaiement == ModePaiement.credit
                          ? AmountTone.neutre
                          : AmountTone.encaisse,
                    ),
                    if (vente.annulee)
                      KassaBadge(label: l.cancelled, tone: KassaBadgeTone.dette)
                    else if (vente.resteAPayer > 0)
                      AmountText(
                        value: vente.resteAPayer,
                        tone: AmountTone.dette,
                        short: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
