// Les règles .check() de drift lisent la colonne elle-même : c'est voulu.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

/// Valeurs autorisées des colonnes texte « énumérées ».
abstract final class ModePaiement {
  static const especes = 'especes';
  static const momo = 'momo';
  static const orangeMoney = 'orange_money';
  static const credit = 'credit';

  /// Modes possibles pour une vente.
  static const pourVente = [especes, momo, orangeMoney, credit];

  /// Modes possibles pour un versement de dette (pas de crédit).
  static const pourVersement = [especes, momo, orangeMoney];
}

abstract final class TypeMouvement {
  static const entree = 'entree';
  static const vente = 'vente';
  static const perte = 'perte';
  static const correction = 'correction';
  static const annulation = 'annulation';

  static const tous = [entree, vente, perte, correction, annulation];
}

abstract final class Role {
  static const proprietaire = 'proprietaire';

  /// Prévu pour plus tard (pas utilisé en version 1).
  static const vendeur = 'vendeur';

  static const tous = [proprietaire, vendeur];
}

/// Champs de synchronisation présents sur chaque table locale.
///
/// - `maj_le` : dernière modification (UTC)
/// - `supprime_le` : suppression logique (jamais de suppression définitive)
/// - `synchro` : false tant que le changement n'est pas envoyé
/// - `appareil_id` : téléphone qui a fait la modification
mixin ColonnesSynchro on Table {
  DateTimeColumn get majLe => dateTime()();
  DateTimeColumn get supprimeLe => dateTime().nullable()();
  BoolColumn get synchro => boolean().withDefault(const Constant(false))();
  TextColumn get appareilId => text()();
}

/// Identifiant UUID généré sur le téléphone.
mixin ColonneId on Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Boutique')
class Boutiques extends Table with ColonneId, ColonnesSynchro {
  TextColumn get nom => text().withLength(min: 1)();

  /// Numéro du propriétaire, chiffres seulement (ex. 237690000000),
  /// même règle que sur le serveur.
  /// (REGEXP est interdit dans un CHECK SQLite : on utilise GLOB.)
  TextColumn get telephone => text().check(
    telephone.length.isBetweenValues(8, 15) &
        const CustomExpression<bool>("telephone NOT GLOB '*[^0-9]*'"),
  )();
  TextColumn get ville => text()();
  TextColumn get quartier => text()();

  /// Code officiel de l'arrondissement (« CM008005001 ») ; null pour les
  /// boutiques créées avant le choix guidé du lieu.
  TextColumn get arrondissement => text().nullable()();

  /// Ville ou village et quartier dans les listes partagées du serveur.
  TextColumn get localiteId => text().nullable()();
  TextColumn get quartierId => text().nullable()();
  TextColumn get typeCommerce => text()();
  IntColumn get seuilAlerteDefaut =>
      integer().check(seuilAlerteDefaut.isBiggerOrEqualValue(0))();
  DateTimeColumn get creeLe => dateTime()();
}

@DataClassName('Utilisateur')
class Utilisateurs extends Table with ColonneId, ColonnesSynchro {
  TextColumn get boutiqueId => text().references(Boutiques, #id)();
  TextColumn get nom => text()();
  TextColumn get telephone => text()();
  TextColumn get role => text()
      .withDefault(const Constant(Role.proprietaire))
      .check(role.isIn(Role.tous))();

  /// Code PIN à 4 chiffres, haché (jamais en clair).
  TextColumn get codePin => text()();
}

@DataClassName('Categorie')
class Categories extends Table with ColonneId, ColonnesSynchro {
  TextColumn get nom => text().withLength(min: 1)();
  TextColumn get icone => text()();
}

@DataClassName('Produit')
@TableIndex(name: 'produits_categorie_id', columns: {#categorieId})
class Produits extends Table with ColonneId, ColonnesSynchro {
  TextColumn get categorieId => text().nullable().references(Categories, #id)();
  TextColumn get nom => text().withLength(min: 1)();
  IntColumn get prixAchat =>
      integer().check(prixAchat.isBiggerOrEqualValue(0))();
  IntColumn get prixVente =>
      integer().check(prixVente.isBiggerOrEqualValue(0))();

  /// Stock actuel, toujours recalculé depuis `mouvements_stock`.
  RealColumn get quantite => real().withDefault(const Constant(0))();
  TextColumn get unite => text()();
  RealColumn get seuilAlerte =>
      real().check(seuilAlerte.isBiggerOrEqualValue(0))();
  TextColumn get photoLocale => text().nullable()();
  TextColumn get codeBarre => text().nullable()();
}

@DataClassName('Client')
class Clients extends Table with ColonneId, ColonnesSynchro {
  TextColumn get nom => text().withLength(min: 1)();
  TextColumn get telephone => text().nullable()();

  /// Ce que le client doit encore, toujours recalculé :
  /// ventes à crédit (reste à payer) − versements.
  IntColumn get soldeDette => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
}

@DataClassName('Vente')
@TableIndex(name: 'ventes_client_id', columns: {#clientId})
@TableIndex(name: 'ventes_date_vente', columns: {#dateVente})
class Ventes extends Table with ColonneId, ColonnesSynchro {
  /// Numéro lisible : n° de la vente dans la journée.
  IntColumn get numero => integer().check(numero.isBiggerThanValue(0))();
  TextColumn get clientId => text().nullable().references(Clients, #id)();
  TextColumn get utilisateurId => text().references(Utilisateurs, #id)();
  IntColumn get total => integer().check(total.isBiggerOrEqualValue(0))();
  IntColumn get montantPaye =>
      integer().check(montantPaye.isBiggerOrEqualValue(0))();
  IntColumn get resteAPayer =>
      integer().check(resteAPayer.isBiggerOrEqualValue(0))();
  TextColumn get modePaiement =>
      text().check(modePaiement.isIn(ModePaiement.pourVente))();
  IntColumn get benefice => integer()();
  DateTimeColumn get dateVente => dateTime()();
  BoolColumn get annulee => boolean().withDefault(const Constant(false))();
}

@DataClassName('LigneVente')
@TableIndex(name: 'lignes_vente_vente_id', columns: {#venteId})
@TableIndex(name: 'lignes_vente_produit_id', columns: {#produitId})
class LignesVente extends Table with ColonneId, ColonnesSynchro {
  @override
  String get tableName => 'lignes_vente';

  TextColumn get venteId => text().references(Ventes, #id)();
  TextColumn get produitId => text().references(Produits, #id)();

  /// Copie du nom au moment de la vente.
  TextColumn get nomProduit => text()();
  RealColumn get quantite => real().check(quantite.isBiggerThanValue(0))();

  /// Copie du prix de vente appliqué.
  IntColumn get prixUnitaire =>
      integer().check(prixUnitaire.isBiggerOrEqualValue(0))();

  /// Copie du coût d'achat, pour le bénéfice.
  IntColumn get prixAchatUnitaire =>
      integer().check(prixAchatUnitaire.isBiggerOrEqualValue(0))();
}

@DataClassName('VersementDette')
@TableIndex(name: 'versements_dette_client_id', columns: {#clientId})
class VersementsDette extends Table with ColonneId, ColonnesSynchro {
  @override
  String get tableName => 'versements_dette';

  TextColumn get clientId => text().references(Clients, #id)();
  IntColumn get montant => integer().check(montant.isBiggerThanValue(0))();
  TextColumn get modePaiement =>
      text().check(modePaiement.isIn(ModePaiement.pourVersement))();
  DateTimeColumn get dateVersement => dateTime()();
}

@DataClassName('MouvementStock')
@TableIndex(name: 'mouvements_stock_produit_id', columns: {#produitId})
class MouvementsStock extends Table with ColonneId, ColonnesSynchro {
  @override
  String get tableName => 'mouvements_stock';

  TextColumn get produitId => text().references(Produits, #id)();
  TextColumn get type => text().check(type.isIn(TypeMouvement.tous))();

  /// Positive pour une entrée, négative pour une sortie.
  RealColumn get quantite => real()();

  /// Pour les entrées : nouveau coût d'achat.
  IntColumn get prixAchatUnitaire =>
      integer().nullable().check(prixAchatUnitaire.isBiggerOrEqualValue(0))();

  /// Vente liée (mouvements « vente » et « annulation »).
  TextColumn get referenceId => text().nullable()();
  DateTimeColumn get dateMouvement => dateTime()();
}
