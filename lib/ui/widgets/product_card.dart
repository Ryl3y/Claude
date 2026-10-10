import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/montant.dart';
import '../../core/quantite.dart';
import '../../domain/calculs.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';
import 'contexte.dart';
import 'initiales.dart';

/// Une case de la grille « Nouvelle vente ».
///
/// Toucher ajoute 1 au panier ([onTap]) ; un appui long sert à saisir une
/// quantité ([onLongPress]). Sans photo : les deux premières lettres sur
/// kassa-soft. Au seuil d'alerte ou en dessous : stock en or-ink avec l'icône.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.nom,
    required this.prix,
    required this.stock,
    required this.unite,
    required this.seuilAlerte,
    this.photo,
    this.quantiteDansPanier = 0,
    this.onTap,
    this.onLongPress,
  });

  final String nom;

  /// Prix de vente en FCFA.
  final int prix;
  final double stock;
  final String unite;
  final double seuilAlerte;

  /// Chemin de la photo sur le téléphone.
  final String? photo;
  final double quantiteDansPanier;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final l = AppLocalizations.of(context);
    final langue = langueDe(context);
    final bas = Calculs.stockBas(quantite: stock, seuil: seuilAlerte);
    final prixTexte = Montant.format(prix, langue, court: true);
    final stockTexte = l.stockLeft(Quantite.format(stock, langue), unite);
    final panierTexte = Quantite.format(quantiteDansPanier, langue);
    final couleurStock = bas ? t.orInk : t.inkMuted;

    final libelle = [
      l.addToCart(nom),
      prixTexte,
      stockTexte,
      if (bas) l.lowStock,
      if (quantiteDansPanier > 0) l.inCart(panierTexte),
    ].join(', ');

    // excludeSemantics retire les actions de l'InkWell : on les redonne ici.
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: libelle,
      onTap: onTap,
      onLongPress: onLongPress,
      onLongPressHint: onLongPress == null ? null : l.enterQuantity,
      excludeSemantics: true,
      child: Material(
        color: t.surfaceRaised,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(KassaRadius.md)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: t.kassaSoft,
          highlightColor: t.kassaSoft,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KassaSpace.s2,
                  KassaSpace.s2,
                  KassaSpace.s2,
                  KassaSpace.s4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(KassaRadius.sm),
                        child: _Visuel(nom: nom, photo: photo),
                      ),
                    ),
                    const SizedBox(height: KassaSpace.s2),
                    Text(
                      nom,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.body,
                    ),
                    Text(prixTexte, style: t.amount),
                    Row(
                      children: [
                        if (bas) ...[
                          Icon(
                            Symbols.warning_rounded,
                            size: KassaComposants.iconeEtiquette,
                            color: couleurStock,
                          ),
                          const SizedBox(width: KassaSpace.s1),
                        ],
                        Flexible(
                          child: Text(
                            bas ? '$stockTexte · ${l.lowStock}' : stockTexte,
                            style: t.caption.copyWith(color: couleurStock),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (quantiteDansPanier > 0)
                Positioned(
                  top: KassaSpace.s1,
                  right: KassaSpace.s1,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: KassaComposants.pastillePanier,
                      minHeight: KassaComposants.pastillePanier,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: KassaSpace.s1,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.kassa,
                      borderRadius: BorderRadius.circular(
                        KassaComposants.pastillePanier / 2,
                      ),
                    ),
                    child: Text(
                      panierTexte,
                      style: t.pastille.copyWith(color: t.onKassa),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Visuel extends StatelessWidget {
  const _Visuel({required this.nom, required this.photo});

  final String nom;
  final String? photo;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final sansPhoto = ColoredBox(
      color: t.kassaSoft,
      child: Center(
        child: Text(
          initiales(nom),
          style: t.initialesProduit.copyWith(color: t.kassa),
        ),
      ),
    );
    if (photo == null) return sansPhoto;
    // Décode la photo à la taille affichée (une vignette), pas à 12 Mpx.
    return LayoutBuilder(
      builder: (context, contraintes) => Image.file(
        File(photo!),
        fit: BoxFit.cover,
        cacheWidth:
            (contraintes.maxWidth * MediaQuery.devicePixelRatioOf(context))
                .round(),
        errorBuilder: (context, erreur, pile) => sansPhoto,
      ),
    );
  }
}
