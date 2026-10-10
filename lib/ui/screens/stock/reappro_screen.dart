import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/montant.dart';
import '../../../core/quantite.dart';
import '../../../core/saisie.dart';
import '../../../data/db/kassa_database.dart';
import '../../../data/providers.dart';
import '../../../domain/calculs.dart';
import '../../../domain/produit_saisie.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../state/produits.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';

/// Écran 11 : réapprovisionnement.
///
/// Sans [produitId], l'écran demande d'abord le produit reçu. Ensuite :
/// quantité reçue et, si besoin, nouveau prix d'achat → mouvement « entree ».
class ReapproScreen extends ConsumerStatefulWidget {
  const ReapproScreen({super.key, this.produitId});

  final String? produitId;

  @override
  ConsumerState<ReapproScreen> createState() => _ReapproScreenState();
}

class _ReapproScreenState extends ConsumerState<ReapproScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _quantite = TextEditingController();
  final _prix = TextEditingController();
  final _recherche = TextEditingController();
  String? _produitId;
  String? _prixInitialisePour;
  var _enCours = false;

  @override
  void initState() {
    super.initState();
    _produitId = widget.produitId;
    _quantite.addListener(() => setState(() {}));
    _prix.addListener(() => setState(() {}));
    // Prix d'achat proposé = prix actuel du produit, dès qu'il est connu
    // (jamais pendant un build).
    ref.listenManual(produitsProvider, (_, produits) {
      final p = produits.value?.where((x) => x.id == _produitId).firstOrNull;
      if (p != null && _prixInitialisePour != p.id) {
        _prixInitialisePour = p.id;
        _prix.text = '${p.prixAchat}';
      }
    }, fireImmediately: true);
  }

  void _choisir(String id) {
    setState(() => _produitId = id);
    final p = ref
        .read(produitsProvider)
        .value
        ?.where((x) => x.id == id)
        .firstOrNull;
    if (p != null) {
      _prixInitialisePour = p.id;
      _prix.text = '${p.prixAchat}';
    }
  }

  @override
  void dispose() {
    _quantite.dispose();
    _prix.dispose();
    _recherche.dispose();
    super.dispose();
  }

  Future<void> _valider(Produit p) async {
    final l = AppLocalizations.of(context);
    if (!_formulaire.currentState!.validate()) return;
    final quantite = Saisie.quantite(_quantite.text)!;
    final prix = Saisie.montant(_prix.text);
    setState(() => _enCours = true);
    try {
      final stock = await ref
          .read(produitsRepositoryProvider)
          .reapprovisionner(
            produitId: p.id,
            quantite: quantite,
            nouveauPrixAchat: prix,
          );
      if (!mounted) return;
      final langue = langueDe(context);
      final messager = ScaffoldMessenger.of(context);
      context.pop();
      messager.showSnackBar(
        SnackBar(
          content: Text(
            l.stockUpdated(
              l.stockLeft(Quantite.format(stock, langue), p.unite),
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
    final id = _produitId;
    if (id == null) return _choixProduit(context, l);

    final produit = ref
        .watch(produitsProvider)
        .value
        ?.where((p) => p.id == id)
        .firstOrNull;
    if (produit == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.restock)),
        body: ref.watch(produitsProvider).isLoading
            ? const Center(child: CircularProgressIndicator())
            : EtatVide(
                icone: Symbols.search_off_rounded,
                titre: l.productNotFound,
              ),
      );
    }
    return _formulaireReappro(context, l, produit);
  }

  Widget _choixProduit(BuildContext context, AppLocalizations l) {
    final t = context.kassa;
    final langue = langueDe(context);
    final cherche = Saisie.pourRecherche(_recherche.text);
    final produits = (ref.watch(produitsProvider).value ?? const <Produit>[])
        .where((p) => Saisie.pourRecherche(p.nom).contains(cherche))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.restock)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.restockChooseProduct, style: t.body),
                    const SizedBox(height: KassaSpace.s2),
                    TextField(
                      controller: _recherche,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: l.searchProducts,
                        prefixIcon: const Icon(Symbols.search_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: produits.isEmpty
                    ? EtatVide(
                        icone: Symbols.search_off_rounded,
                        titre: _recherche.text.trim().isEmpty
                            ? l.stockEmptyTitle
                            : l.stockNoResult(_recherche.text.trim()),
                      )
                    : ListView.separated(
                        itemCount: produits.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (context, i) {
                          final p = produits[i];
                          final bas = Calculs.stockBas(
                            quantite: p.quantite,
                            seuil: p.seuilAlerte,
                          );
                          return ListTile(
                            leading: VignetteProduit(
                              nom: p.nom,
                              photo: p.photoLocale,
                              taille: KassaComposants.vignetteLigne,
                            ),
                            title: Text(p.nom),
                            subtitle: Text(
                              l.stockOf(
                                l.stockLeft(
                                  Quantite.format(p.quantite, langue),
                                  p.unite,
                                ),
                              ),
                              style: t.caption.copyWith(
                                color: bas ? t.orInk : t.inkMuted,
                              ),
                            ),
                            trailing: const Icon(Symbols.chevron_right_rounded),
                            onTap: () => _choisir(p.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulaireReappro(
    BuildContext context,
    AppLocalizations l,
    Produit p,
  ) {
    final t = context.kassa;
    final langue = langueDe(context);
    final recue = Saisie.quantite(_quantite.text);
    final prix = Saisie.montant(_prix.text);
    String quantiteTexte(double q) =>
        l.stockLeft(Quantite.format(q, langue), p.unite);
    final perte = prix == null
        ? 0
        : ReglesProduit.perteParUnite(prixAchat: prix, prixVente: p.prixVente);

    return Scaffold(
      appBar: AppBar(title: Text(l.restock)),
      body: Form(
        key: _formulaire,
        child: Center(
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
                  child: Row(
                    children: [
                      VignetteProduit(
                        nom: p.nom,
                        photo: p.photoLocale,
                        taille: KassaComposants.vignetteLigne,
                      ),
                      const SizedBox(width: KassaSpace.s4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.nom, style: t.title),
                            Text(
                              l.currentStock(quantiteTexte(p.quantite)),
                              style: t.body,
                            ),
                            Text(
                              l.currentPurchasePrice(
                                Montant.format(p.prixAchat, langue),
                              ),
                              style: t.caption.copyWith(color: t.inkMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KassaSpace.s6),
                TextFormField(
                  controller: _quantite,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  style: t.amount,
                  decoration: InputDecoration(
                    labelText: l.fieldReceivedQuantity,
                    suffixText: p.unite,
                  ),
                  validator: (v) {
                    final q = Saisie.quantite(v ?? '');
                    return q == null || q <= 0 ? l.errReceivedQuantity : null;
                  },
                ),
                const SizedBox(height: KassaSpace.s4),
                TextFormField(
                  controller: _prix,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: t.amount,
                  decoration: InputDecoration(
                    labelText: l.fieldPurchasePrice,
                    helperText: l.fieldNewPurchasePriceHelp,
                    helperMaxLines: 2,
                    suffixText: Montant.deviseLongue,
                  ),
                  validator: (v) => Saisie.montant(v ?? '') == null
                      ? l.errPriceRequired
                      : null,
                ),
                if (perte > 0) ...[
                  const SizedBox(height: KassaSpace.s2),
                  Avertissement(
                    texte: l.warnSellingAtLoss(Montant.format(perte, langue)),
                  ),
                ],
                if (recue != null && recue > 0) ...[
                  const SizedBox(height: KassaSpace.s6),
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(KassaSpace.s4),
                      decoration: BoxDecoration(
                        color: t.kassaSoft,
                        borderRadius: BorderRadius.circular(KassaRadius.md),
                      ),
                      child: Text(
                        l.newStockPreview(
                          quantiteTexte(
                            Calculs.arrondirQuantite(p.quantite + recue),
                          ),
                        ),
                        style: t.amount.copyWith(color: t.ink),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: KassaButton(
          label: l.addToStock,
          icon: Symbols.add_rounded,
          size: KassaButtonSize.main,
          fullWidth: true,
          onPressed: _enCours ? null : () => _valider(p),
        ),
      ),
    );
  }
}
