import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/montant.dart';
import '../../../core/quantite.dart';
import '../../../core/saisie.dart';
import '../../../data/db/kassa_database.dart';
import '../../../domain/panier.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/produits.dart';
import '../../state/vente.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';

/// Écran 6 : nouvelle vente. Toucher un produit = +1 ; appui long = choisir
/// la quantité. Le panier reste en bas avec le total et « Encaisser ».
class NouvelleVenteScreen extends ConsumerStatefulWidget {
  const NouvelleVenteScreen({super.key});

  @override
  ConsumerState<NouvelleVenteScreen> createState() =>
      _NouvelleVenteScreenState();
}

class _NouvelleVenteScreenState extends ConsumerState<NouvelleVenteScreen> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  void _toucher(Produit p) {
    final avant = ref.read(panierProvider).quantiteDe(p.id);
    ref.read(panierProvider.notifier).ajouter(p);
    // Prévient une seule fois, quand on dépasse le stock.
    if (avant <= p.quantite && avant + 1 > p.quantite) _prevenirStock(p);
  }

  void _prevenirStock(Produit p) {
    final l = AppLocalizations.of(context);
    final reste = l.stockLeft(
      Quantite.format(p.quantite, langueDe(context)),
      p.unite,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.stockInsufficient(reste))));
  }

  Future<void> _choisirQuantite(Produit p) async {
    final actuelle = ref.read(panierProvider).quantiteDe(p.id);
    final quantite = await demanderQuantite(
      context,
      nom: p.nom,
      unite: p.unite,
      initiale: actuelle,
    );
    if (quantite == null || !mounted) return;
    ref.read(panierProvider.notifier).fixer(p, quantite);
    if (quantite > p.quantite) _prevenirStock(p);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final produits = ref.watch(produitsProvider);
    final panier = ref.watch(panierProvider);
    final cherche = Saisie.pourRecherche(_recherche.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.newSale),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(Chemins.historique),
            icon: const Icon(Symbols.receipt_long_rounded),
            label: Text(l.history),
          ),
          const SizedBox(width: KassaSpace.s2),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: produits.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (erreur, pile) =>
                EtatVide(icone: Symbols.error_rounded, titre: l.loadError),
            data: (tous) {
              if (tous.isEmpty) {
                return EtatVide(
                  icone: Symbols.inventory_2_rounded,
                  titre: l.sellNoProductsTitle,
                  message: l.sellNoProductsBody,
                );
              }
              final liste = [
                for (final p in tous)
                  if (cherche.isEmpty ||
                      Saisie.pourRecherche(p.nom).contains(cherche))
                    p,
              ];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KassaSpace.s4,
                      KassaSpace.s2,
                      KassaSpace.s4,
                      KassaSpace.s2,
                    ),
                    child: TextField(
                      controller: _recherche,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l.searchProducts,
                        prefixIcon: const Icon(Symbols.search_rounded),
                      ),
                    ),
                  ),
                  Expanded(
                    child: liste.isEmpty
                        ? EtatVide(
                            icone: Symbols.search_off_rounded,
                            titre: l.stockNoResult(_recherche.text.trim()),
                          )
                        : _Grille(
                            produits: liste,
                            panier: panier,
                            onToucher: _toucher,
                            onAppuiLong: _choisirQuantite,
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _BarrePanier(panier: panier),
    );
  }
}

/// Grille de 3 colonnes ; chaque rangée prend la hauteur de sa plus haute
/// carte (le texte suit la taille choisie sur le téléphone).
class _Grille extends StatelessWidget {
  const _Grille({
    required this.produits,
    required this.panier,
    required this.onToucher,
    required this.onAppuiLong,
  });

  final List<Produit> produits;
  final Panier panier;
  final ValueChanged<Produit> onToucher;
  final ValueChanged<Produit> onAppuiLong;

  @override
  Widget build(BuildContext context) {
    const colonnes = KassaComposants.grilleProduitsColonnes;
    final rangees = (produits.length / colonnes).ceil();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        KassaSpace.s4,
        0,
        KassaSpace.s4,
        KassaSpace.s4,
      ),
      itemCount: rangees,
      separatorBuilder: (_, _) => const SizedBox(height: KassaSpace.s2),
      itemBuilder: (context, r) {
        final rangee = produits.skip(r * colonnes).take(colonnes).toList();
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var c = 0; c < colonnes; c++) ...[
                if (c > 0) const SizedBox(width: KassaSpace.s2),
                Expanded(
                  child: c < rangee.length
                      ? ProductCard(
                          nom: rangee[c].nom,
                          prix: rangee[c].prixVente,
                          stock: rangee[c].quantite,
                          unite: rangee[c].unite,
                          seuilAlerte: rangee[c].seuilAlerte,
                          photo: rangee[c].photoLocale,
                          quantiteDansPanier: panier.quantiteDe(rangee[c].id),
                          onTap: () => onToucher(rangee[c]),
                          onLongPress: () => onAppuiLong(rangee[c]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Barre du panier : nombre de produits, total, bouton « Encaisser ».
/// Toucher le résumé ouvre le détail du panier.
class _BarrePanier extends ConsumerWidget {
  const _BarrePanier({required this.panier});

  final Panier panier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    return Container(
      decoration: BoxDecoration(
        color: t.surfaceRaised,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KassaRadius.lg),
        ),
        boxShadow: kassaShadowSheet,
      ),
      child: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (panier.estVide)
              Padding(
                padding: const EdgeInsets.only(bottom: KassaSpace.s2),
                child: Text(
                  l.cartEmptyHint,
                  style: t.caption.copyWith(color: t.inkMuted),
                  textAlign: TextAlign.center,
                ),
              )
            else
              MergeSemantics(
                child: InkWell(
                  borderRadius: BorderRadius.circular(KassaRadius.md),
                  onTap: () => montrerPanier(context),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: KassaSize.touchMin,
                    ),
                    child: Row(
                      children: [
                        Icon(Symbols.shopping_basket_rounded, color: t.kassa),
                        const SizedBox(width: KassaSpace.s2),
                        Expanded(
                          child: Text(
                            '${l.cartTitle} · ${l.productsCount(panier.lignes.length)}',
                            style: t.label,
                          ),
                        ),
                        AmountText(value: panier.total),
                        const SizedBox(width: KassaSpace.s1),
                        Icon(Symbols.expand_less_rounded, color: t.inkMuted),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: KassaSpace.s2),
            KassaButton(
              label: l.collectPayment,
              icon: Symbols.payments_rounded,
              size: KassaButtonSize.main,
              fullWidth: true,
              onPressed: panier.estVide
                  ? null
                  : () => context.push(Chemins.paiement),
            ),
          ],
        ),
      ),
    );
  }
}

/// Détail du panier : quantités, retrait, total, « Encaisser ».
Future<void> montrerPanier(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => const _FeuillePanier(),
);

class _FeuillePanier extends ConsumerWidget {
  const _FeuillePanier();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final panier = ref.watch(panierProvider);
    final controleur = ref.read(panierProvider.notifier);

    if (panier.estVide) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
    }

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.sizeOf(context).height *
              KassaComposants.hauteurMaxFeuille,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KassaSpace.s4),
              child: Row(
                children: [
                  Expanded(child: Text(l.cartTitle, style: t.title)),
                  KassaButton(
                    label: l.clearCart,
                    icon: Symbols.remove_shopping_cart_rounded,
                    variant: KassaButtonVariant.ghost,
                    onPressed: () {
                      final avant = ref.read(panierProvider);
                      final messager = ScaffoldMessenger.of(context);
                      controleur.vider();
                      messager
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(l.cartCleared),
                            action: SnackBarAction(
                              label: l.undo,
                              onPressed: () => controleur.remplacer(avant),
                            ),
                          ),
                        );
                    },
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: KassaSpace.s4),
                itemCount: panier.lignes.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, i) {
                  final ligne = panier.lignes[i];
                  final pas = ligne.quantite >= 1 ? 1.0 : ligne.quantite;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: KassaSpace.s2,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ligne.nom, style: t.body),
                              Text(
                                l.lineDetail(
                                  l.stockLeft(
                                    Quantite.format(ligne.quantite, langue),
                                    ligne.unite,
                                  ),
                                  Montant.format(
                                    ligne.prixUnitaire,
                                    langue,
                                    court: true,
                                  ),
                                ),
                                style: t.caption.copyWith(color: t.inkMuted),
                              ),
                              if (ligne.depasseLeStock)
                                Text(
                                  l.stockInsufficient(
                                    l.stockLeft(
                                      Quantite.format(
                                        ligne.stockDisponible,
                                        langue,
                                      ),
                                      ligne.unite,
                                    ),
                                  ),
                                  style: t.caption.copyWith(color: t.orInk),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l.decreaseQuantity(ligne.nom),
                          onPressed: () => controleur.changerQuantite(
                            ligne.produitId,
                            ligne.quantite - pas,
                          ),
                          icon: const Icon(Symbols.remove_rounded),
                        ),
                        IconButton(
                          tooltip: l.increaseQuantity(ligne.nom),
                          onPressed: () => controleur.changerQuantite(
                            ligne.produitId,
                            ligne.quantite + 1,
                          ),
                          icon: const Icon(Symbols.add_rounded),
                        ),
                        AmountText(value: ligne.montant, short: true),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(KassaSpace.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(l.totalToPay, style: t.label)),
                      AmountText(value: panier.total, size: AmountSize.lg),
                    ],
                  ),
                  const SizedBox(height: KassaSpace.s4),
                  KassaButton(
                    label: l.collectPayment,
                    icon: Symbols.payments_rounded,
                    size: KassaButtonSize.main,
                    fullWidth: true,
                    onPressed: panier.estVide
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            context.push(Chemins.paiement);
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Demande une quantité (vrac accepté) avec le pavé numérique.
/// Renvoie null si l'utilisateur ferme la feuille.
Future<double?> demanderQuantite(
  BuildContext context, {
  required String nom,
  required String unite,
  double initiale = 0,
}) => showModalBottomSheet<double>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _FeuilleQuantite(nom: nom, unite: unite, initiale: initiale),
);

class _FeuilleQuantite extends StatefulWidget {
  const _FeuilleQuantite({
    required this.nom,
    required this.unite,
    required this.initiale,
  });

  final String nom;
  final String unite;
  final double initiale;

  @override
  State<_FeuilleQuantite> createState() => _FeuilleQuantiteState();
}

class _FeuilleQuantiteState extends State<_FeuilleQuantite> {
  late var _valeur = widget.initiale > 0
      ? Quantite.pourSaisie(widget.initiale, 'en')
      : '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KassaSpace.s4),
              child: Text(l.quantityOf(widget.nom), style: t.title),
            ),
            NumPad(
              valeur: _valeur,
              mode: NumPadMode.quantite,
              unite: widget.unite,
              onChanged: (v) => setState(() => _valeur = v),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KassaSpace.s4,
                0,
                KassaSpace.s4,
                KassaSpace.s4,
              ),
              child: KassaButton(
                label: l.putInCart,
                icon: Symbols.add_shopping_cart_rounded,
                size: KassaButtonSize.main,
                fullWidth: true,
                onPressed: () =>
                    Navigator.of(context).pop(NumPad.enQuantite(_valeur)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
