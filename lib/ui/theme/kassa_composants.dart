import 'package:flutter/painting.dart';

import 'kassa_tokens.dart';

/// Tailles propres aux composants, reprises des fiches de la charte.
/// Les widgets n'écrivent aucune valeur en dur : tout vient d'ici,
/// de [KassaSpace], [KassaRadius], [KassaSize] ou de [KassaTokens].
abstract final class KassaComposants {
  /// Hauteur minimale d'une étiquette (badge).
  static const badgeHauteur = 24.0;

  /// Icône dans une étiquette ou une légende.
  static const iconeEtiquette = 16.0;

  /// Icône dans un bouton de taille normale (24 en taille principale).
  static const iconeBouton = 20.0;

  /// Bordure d'un bouton secondaire, d'une carte pressée, de l'anneau de focus.
  static const trait = 2.0;

  /// Filet de séparation.
  static const filet = 1.0;

  /// Pastille « quantité au panier » sur une carte produit.
  static const pastillePanier = 28.0;

  /// Lignes de la liste des clients.
  static const ligneClientHauteur = 64.0;
  static const avatarClient = 44.0;

  /// Part maximale de la largeur d'une ligne client donnée au montant.
  static const partMaxMontantLigne = 0.45;

  /// Pavé numérique : 9 chiffres au plus (montants jusqu'à 999 999 999 FCFA).
  static const paveChiffresMax = 9;

  /// Barre du bas : zone de toucher de 64 px, pilule 64 × 32.
  static const navHauteur = 72.0;

  /// Vignette d'un produit dans une liste, et dans le formulaire.
  static const vignetteLigne = 48.0;
  static const vignetteFormulaire = 120.0;

  /// Icône d'un écran vide.
  static const iconeEtatVide = 48.0;

  /// Largeur maximale du contenu (tablette, paysage) : lisible, centré.
  static const largeurContenuMax = 640.0;

  /// Hauteur maximale d'une feuille du bas (part de l'écran).
  static const hauteurMaxFeuille = 0.8;

  /// Nombre de colonnes de la grille « Nouvelle vente ».
  static const grilleProduitsColonnes = 3;

  /// Opacité d'un bouton désactivé.
  static const opaciteDesactive = 0.45;

  /// Taille de texte de référence pour savoir si le téléphone grossit le
  /// texte, et l'échelle à partir de laquelle les tuiles s'empilent.
  static const texteRepere = 16.0;
  static const echelleEmpilement = 1.3;
}

/// Styles de texte des composants.
///
/// Chaque style part d'un style de base qui a déjà la bonne graisse
/// (google_fonts charge un fichier par graisse) : on ne change que la taille.
/// w600 → label · w700 → title · w800 → display.
extension KassaStylesComposants on KassaTokens {
  static const _chiffres = [FontFeature.tabularFigures()];

  /// Libellé d'un bouton : 16/20, gras.
  TextStyle get bouton => title.copyWith(fontSize: 16, height: 20 / 16);

  /// Libellé du bouton principal (56 px) : 18/24, gras.
  TextStyle get boutonPrincipal =>
      title.copyWith(fontSize: 18, height: 24 / 18);

  /// Texte d'une étiquette : 12/16, gras.
  TextStyle get etiquette => title.copyWith(fontSize: 12, height: 16 / 12);

  /// Onglet de la barre du bas : 12/16, demi-gras ; actif en extra-gras.
  TextStyle get onglet => label.copyWith(fontSize: 12, height: 16 / 12);
  TextStyle get ongletActif => display.copyWith(fontSize: 12, height: 16 / 12);

  /// Initiales d'un produit sans photo.
  TextStyle get initialesProduit => display.copyWith(fontSize: 28, height: 1);

  /// Initiales d'un client.
  TextStyle get initialesClient => display.copyWith(fontSize: 15, height: 1);

  /// Touche du pavé numérique.
  TextStyle get touchePave =>
      title.copyWith(fontSize: 24, height: 1.2, fontFeatures: _chiffres);

  /// Chiffre dans une pastille (panier, alertes).
  TextStyle get pastille =>
      display.copyWith(fontSize: 14, height: 1, fontFeatures: _chiffres);

  /// Préfixe « Doit » devant un montant : 70 % de la taille du montant.
  TextStyle prefixeMontant(TextStyle montant) =>
      montant.copyWith(fontSize: (montant.fontSize ?? 20) * 0.7);
}
