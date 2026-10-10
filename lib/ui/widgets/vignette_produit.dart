import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';
import 'initiales.dart';

/// Photo carrée d'un produit, ou ses deux premières lettres sur kassa-soft.
/// Décorative : le nom du produit est toujours écrit à côté.
class VignetteProduit extends StatelessWidget {
  const VignetteProduit({
    super.key,
    required this.nom,
    this.photo,
    this.taille,
  });

  final String nom;

  /// Chemin de la photo sur le téléphone.
  final String? photo;

  /// Côté en pixels ; sans taille, la vignette remplit la place donnée.
  final double? taille;

  @override
  Widget build(BuildContext context) {
    final contenu = ClipRRect(
      borderRadius: BorderRadius.circular(KassaRadius.sm),
      child: LayoutBuilder(
        builder: (context, contraintes) => _Visuel(
          nom: nom,
          photo: photo,
          largeurPixels:
              (contraintes.maxWidth.isFinite
                  ? contraintes.maxWidth
                  : (taille ?? KassaComposants.vignetteFormulaire)) *
              MediaQuery.devicePixelRatioOf(context),
          petit:
              (taille ?? contraintes.maxWidth) <= KassaComposants.vignetteLigne,
        ),
      ),
    );
    return ExcludeSemantics(
      child: taille == null
          ? AspectRatio(aspectRatio: 1, child: contenu)
          : SizedBox.square(dimension: taille, child: contenu),
    );
  }
}

class _Visuel extends StatelessWidget {
  const _Visuel({
    required this.nom,
    required this.photo,
    required this.largeurPixels,
    required this.petit,
  });

  final String nom;
  final String? photo;
  final double largeurPixels;
  final bool petit;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final sansPhoto = ColoredBox(
      color: t.kassaSoft,
      child: Center(
        child: Text(
          initiales(nom),
          style: (petit ? t.initialesClient : t.initialesProduit).copyWith(
            color: t.kassa,
          ),
        ),
      ),
    );
    if (photo == null) return sansPhoto;
    // Décode la photo à la taille affichée (une vignette), pas à 12 Mpx.
    return Image.file(
      File(photo!),
      fit: BoxFit.cover,
      cacheWidth: largeurPixels.round(),
      errorBuilder: (context, erreur, pile) => sansPhoto,
    );
  }
}
