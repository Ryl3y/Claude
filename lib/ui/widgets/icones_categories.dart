import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/generated/app_localizations.dart';

/// Icônes proposées pour une catégorie. Le nom est enregistré en base
/// (`categories.icone`) ; l'icône est retrouvée ici.
enum IconeCategorie {
  epicerie('grocery', Symbols.grocery_rounded),
  boissons('local_drink', Symbols.local_drink_rounded),
  hygiene('soap', Symbols.soap_rounded),
  menage('cleaning_services', Symbols.cleaning_services_rounded),
  frais('egg', Symbols.egg_rounded),
  autre('category', Symbols.category_rounded);

  const IconeCategorie(this.nom, this.icone);

  final String nom;
  final IconData icone;

  static IconeCategorie depuisNom(String nom) => IconeCategorie.values
      .firstWhere((i) => i.nom == nom, orElse: () => IconeCategorie.autre);

  /// Nom proposé pour une catégorie créée depuis ce modèle.
  String libelle(AppLocalizations l) => switch (this) {
    epicerie => l.catGrocery,
    boissons => l.catDrinks,
    hygiene => l.catHygiene,
    menage => l.catHousehold,
    frais => l.catFresh,
    autre => l.catOther,
  };
}
