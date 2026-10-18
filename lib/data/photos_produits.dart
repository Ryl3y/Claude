import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../core/identifiant.dart';

/// Photos des produits, gardées sur le téléphone (jamais envoyées en v1).
abstract final class PhotosProduits {
  /// Largeur maximale demandée à l'appareil photo ou à la galerie.
  static const largeurMax = 1024.0;

  /// Qualité JPEG (0-100) : léger mais net pour une vignette.
  static const qualite = 80;

  /// Copie la photo choisie dans le dossier de l'app et renvoie son chemin.
  static Future<String> enregistrer(String cheminSource) async {
    final documents = await getApplicationDocumentsDirectory();
    final dossier = Directory('${documents.path}/photos');
    await dossier.create(recursive: true);
    final destination = '${dossier.path}/${Identifiant.nouveau()}.jpg';
    await File(cheminSource).copy(destination);
    return destination;
  }

  /// Efface une photo devenue inutile (remplacée, retirée, produit supprimé).
  /// Ne fait rien si le fichier n'existe plus.
  static Future<void> effacer(String? chemin) async {
    if (chemin == null) return;
    try {
      final fichier = File(chemin);
      if (await fichier.exists()) await fichier.delete();
    } on FileSystemException {
      // Fichier déjà absent ou verrouillé : sans conséquence pour les données.
    }
  }
}
