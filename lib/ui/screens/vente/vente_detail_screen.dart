import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/heure_douala.dart';
import '../../../core/montant.dart';
import '../../../core/quantite.dart';
import '../../../data/providers.dart';
import '../../../domain/calculs.dart';
import '../../../data/repositories/ventes_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';

final _venteProvider = StreamProvider.family<VenteDetaillee?, String>(
  (ref, id) => ref.watch(ventesRepositoryProvider).surveillerVente(id),
);

/// Détail d'une vente (écran 8) : produits, paiement, client, annulation.
class VenteDetailScreen extends ConsumerStatefulWidget {
  const VenteDetailScreen({super.key, required this.venteId});

  final String venteId;

  @override
  ConsumerState<VenteDetailScreen> createState() => _VenteDetailScreenState();
}

class _VenteDetailScreenState extends ConsumerState<VenteDetailScreen> {
  var _enCours = false;

  Future<void> _annuler(int numero) async {
    final l = AppLocalizations.of(context);
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.cancelSaleTitle(numero)),
        content: Text(l.cancelSaleBody),
        actions: [
          KassaButton(
            label: l.keepSale,
            variant: KassaButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          KassaButton(
            label: l.cancelSale,
            variant: KassaButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;
    setState(() => _enCours = true);
    try {
      await ref.read(ventesRepositoryProvider).annulerVente(widget.venteId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.saleCancelled(numero))));
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AnnulationImpossible ? l.errCancelRepaid : l.saveError,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final detail = ref.watch(_venteProvider(widget.venteId));

    return detail.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (erreur, pile) => Scaffold(
        appBar: AppBar(),
        body: EtatVide(icone: Symbols.error_rounded, titre: l.loadError),
      ),
      data: (d) {
        if (d == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EtatVide(
              icone: Symbols.search_off_rounded,
              titre: l.saleNotFound,
            ),
          );
        }
        final v = d.vente;
        return Scaffold(
          appBar: AppBar(title: Text(l.saleNumber(v.numero))),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: KassaComposants.largeurContenuMax,
              ),
              child: ListView(
                padding: const EdgeInsets.all(KassaSpace.s4),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.saleDateTime(
                            HeureDouala.dateCourte(v.dateVente, langue),
                            HeureDouala.heure(v.dateVente, langue),
                          ),
                          style: t.body.copyWith(color: t.inkMuted),
                        ),
                      ),
                      if (v.annulee)
                        KassaBadge(
                          label: l.cancelled,
                          tone: KassaBadgeTone.dette,
                          icon: Symbols.cancel_rounded,
                        ),
                    ],
                  ),
                  const SizedBox(height: KassaSpace.s4),
                  _Carte(
                    enfants: [
                      Text(
                        l.products,
                        style: t.label.copyWith(color: t.inkMuted),
                      ),
                      for (final ligne in d.lignes)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: KassaSpace.s2,
                          ),
                          child: MergeSemantics(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(ligne.nomProduit, style: t.body),
                                      Text(
                                        l.lineDetail(
                                          Quantite.format(
                                            ligne.quantite,
                                            langue,
                                          ),
                                          Montant.format(
                                            ligne.prixUnitaire,
                                            langue,
                                            court: true,
                                          ),
                                        ),
                                        style: t.caption.copyWith(
                                          color: t.inkMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AmountText(
                                  value: LigneCalcul(
                                    quantite: ligne.quantite,
                                    prixUnitaire: ligne.prixUnitaire,
                                    prixAchatUnitaire: ligne.prixAchatUnitaire,
                                  ).montant,
                                  short: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: KassaSpace.s4),
                  _Carte(
                    enfants: [
                      _Ligne(
                        libelle: l.saleTotal,
                        valeur: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AmountText(
                            value: v.total,
                            size: AmountSize.lg,
                          ),
                        ),
                      ),
                      _Ligne(
                        libelle: l.paymentMode,
                        valeur: Text(
                          libelleMode(l, v.modePaiement),
                          style: t.label,
                        ),
                      ),
                      _Ligne(
                        libelle: l.paid,
                        valeur: AmountText(
                          value: v.montantPaye,
                          tone: AmountTone.encaisse,
                        ),
                      ),
                      if (v.resteAPayer > 0)
                        _Ligne(
                          libelle: l.remainingDebt,
                          valeur: AmountText(
                            value: v.resteAPayer,
                            tone: AmountTone.dette,
                          ),
                        ),
                      if (d.client != null)
                        _Ligne(
                          libelle: l.customer,
                          valeur: Text(d.client!.nom, style: t.label),
                        ),
                      _Ligne(
                        libelle: l.profit,
                        valeur: AmountText(value: v.benefice),
                      ),
                    ],
                  ),
                  if (!v.annulee) ...[
                    const SizedBox(height: KassaSpace.s6),
                    KassaButton(
                      label: l.cancelSale,
                      icon: Symbols.cancel_rounded,
                      variant: KassaButtonVariant.danger,
                      fullWidth: true,
                      onPressed: _enCours ? null : () => _annuler(v.numero),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Carte extends StatelessWidget {
  const _Carte({required this.enfants});

  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(KassaSpace.s4),
    decoration: BoxDecoration(
      color: context.kassa.surfaceRaised,
      borderRadius: BorderRadius.circular(KassaRadius.md),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: enfants,
    ),
  );
}

class _Ligne extends StatelessWidget {
  const _Ligne({required this.libelle, required this.valeur});

  final String libelle;
  final Widget valeur;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KassaSpace.s1),
      child: MergeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Text(libelle, style: t.label.copyWith(color: t.inkMuted)),
            ),
            Flexible(
              child: Align(alignment: Alignment.centerRight, child: valeur),
            ),
          ],
        ),
      ),
    );
  }
}
