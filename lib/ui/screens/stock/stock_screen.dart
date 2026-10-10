import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/montant.dart';
import '../../../core/quantite.dart';
import '../../../core/saisie.dart';
import '../../../data/db/kassa_database.dart';
import '../../../domain/calculs.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/produits.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';

/// Filtre de la liste : tous, stock bas, ou une catégorie.
sealed class _Filtre {
  const _Filtre();
}

class _Tous extends _Filtre {
  const _Tous();
}

class _StockBas extends _Filtre {
  const _StockBas();
}

class _Categorie extends _Filtre {
  const _Categorie(this.id);
  final String id;
  @override
  bool operator ==(Object other) => other is _Categorie && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

/// Écran 9 : liste du stock, recherche, filtre par catégorie, alertes.
class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key, this.demandeStockBas});

  /// Demande de l'accueil (« Voir le stock ») : chaque nouvelle valeur
  /// remet le filtre sur le stock bas et vide la recherche.
  final String? demandeStockBas;

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _recherche = TextEditingController();
  late _Filtre _filtre = widget.demandeStockBas != null
      ? const _StockBas()
      : const _Tous();

  @override
  void didUpdateWidget(StockScreen ancien) {
    super.didUpdateWidget(ancien);
    // L'onglet garde son état : une nouvelle demande de l'accueil remet
    // toujours le filtre, même si l'utilisateur l'avait changé entre-temps.
    if (widget.demandeStockBas != null &&
        widget.demandeStockBas != ancien.demandeStockBas) {
      _filtre = const _StockBas();
      _recherche.clear();
    }
  }

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  List<Produit> _filtrer(List<Produit> produits) {
    final cherche = Saisie.pourRecherche(_recherche.text);
    return [
      for (final p in produits)
        if ((cherche.isEmpty ||
                Saisie.pourRecherche(p.nom).contains(cherche)) &&
            switch (_filtre) {
              _Tous() => true,
              _StockBas() => Calculs.stockBas(
                quantite: p.quantite,
                seuil: p.seuilAlerte,
              ),
              _Categorie(:final id) => p.categorieId == id,
            })
          p,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final produits = ref.watch(produitsProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final alertes = ref.watch(alertesStockProvider);
    final nomsCategories = {for (final c in categories) c.id: c.nom};

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navStock),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(Chemins.reappro()),
            icon: const Icon(Symbols.local_shipping_rounded),
            label: Text(l.restock),
          ),
          const SizedBox(width: KassaSpace.s2),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: Column(
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
              SizedBox(
                height: KassaSize.touchMin,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: KassaSpace.s4,
                  ),
                  children: [
                    _Puce(
                      libelle: l.filterAll,
                      choisie: _filtre is _Tous,
                      onTap: () => setState(() => _filtre = const _Tous()),
                    ),
                    _Puce(
                      libelle: l.filterLowStock(alertes),
                      icone: Symbols.warning_rounded,
                      choisie: _filtre is _StockBas,
                      onTap: () => setState(() => _filtre = const _StockBas()),
                    ),
                    for (final c in categories)
                      _Puce(
                        libelle: c.nom,
                        icone: IconeCategorie.depuisNom(c.icone).icone,
                        choisie: _filtre == _Categorie(c.id),
                        onTap: () => setState(() => _filtre = _Categorie(c.id)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: KassaSpace.s2),
              Expanded(
                child: produits.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (erreur, pile) => EtatVide(
                    icone: Symbols.error_rounded,
                    titre: l.loadError,
                  ),
                  data: (tous) {
                    if (tous.isEmpty) {
                      return EtatVide(
                        icone: Symbols.inventory_2_rounded,
                        titre: l.stockEmptyTitle,
                        message: l.stockEmptyBody,
                      );
                    }
                    final liste = _filtrer(tous);
                    if (liste.isEmpty) {
                      return EtatVide(
                        icone: Symbols.search_off_rounded,
                        titre: _recherche.text.trim().isNotEmpty
                            ? l.stockNoResult(_recherche.text.trim())
                            : _filtre is _StockBas
                            ? l.stockNoLowStock
                            : l.stockNoInCategory,
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: KassaSpace.s4),
                      itemCount: liste.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, i) => LigneStock(
                        produit: liste[i],
                        categorie: nomsCategories[liste[i].categorieId],
                        onTap: () => context.push(Chemins.produit(liste[i].id)),
                        onReappro: () => context.push(
                          Chemins.reappro(produitId: liste[i].id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: KassaButton(
          label: l.addProduct,
          icon: Symbols.add_rounded,
          size: KassaButtonSize.main,
          fullWidth: true,
          onPressed: () => context.push(Chemins.nouveauProduit),
        ),
      ),
    );
  }
}

class _Puce extends StatelessWidget {
  const _Puce({
    required this.libelle,
    required this.choisie,
    required this.onTap,
    this.icone,
  });

  final String libelle;
  final bool choisie;
  final VoidCallback onTap;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Padding(
      padding: const EdgeInsets.only(right: KassaSpace.s2),
      child: ChoiceChip(
        label: Text(libelle),
        avatar: icone == null
            ? null
            : Icon(icone, size: KassaComposants.iconeEtiquette, color: t.ink),
        selected: choisie,
        showCheckmark: false,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

/// Une ligne de la liste du stock : vignette, nom, prix, stock et bouton Réappro.
class LigneStock extends StatelessWidget {
  const LigneStock({
    super.key,
    required this.produit,
    required this.categorie,
    required this.onTap,
    required this.onReappro,
  });

  final Produit produit;
  final String? categorie;
  final VoidCallback onTap;
  final VoidCallback onReappro;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final l = AppLocalizations.of(context);
    final langue = langueDe(context);
    final bas = Calculs.stockBas(
      quantite: produit.quantite,
      seuil: produit.seuilAlerte,
    );
    final stock = l.stockOf(
      l.stockLeft(Quantite.format(produit.quantite, langue), produit.unite),
    );

    return Material(
      color: t.surfaceRaised,
      child: Row(
        children: [
          Expanded(
            child: MergeSemantics(
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KassaSpace.s4,
                    KassaSpace.s2,
                    KassaSpace.s2,
                    KassaSpace.s2,
                  ),
                  child: Row(
                    children: [
                      VignetteProduit(
                        nom: produit.nom,
                        photo: produit.photoLocale,
                        taille: KassaComposants.vignetteLigne,
                      ),
                      const SizedBox(width: KassaSpace.s4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produit.nom,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: t.label.copyWith(
                                fontSize: t.body.fontSize,
                                height: t.body.height,
                              ),
                            ),
                            Text(
                              [
                                Montant.format(
                                  produit.prixVente,
                                  langue,
                                  court: true,
                                ),
                                ?categorie,
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.caption.copyWith(color: t.inkMuted),
                            ),
                            const SizedBox(height: KassaSpace.s1),
                            Wrap(
                              spacing: KassaSpace.s2,
                              runSpacing: KassaSpace.s1,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  stock,
                                  style: t.label.copyWith(color: t.ink),
                                ),
                                if (bas)
                                  KassaBadge(
                                    label: l.lowStock,
                                    tone: KassaBadgeTone.alerte,
                                    icon: Symbols.warning_rounded,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: KassaSpace.s4),
            child: KassaButton(
              label: l.restock,
              semanticLabel: l.restockProduct(produit.nom),
              variant: KassaButtonVariant.secondary,
              onPressed: onReappro,
            ),
          ),
        ],
      ),
    );
  }
}
