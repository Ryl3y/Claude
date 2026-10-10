// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kassa_database.dart';

// ignore_for_file: type=lint
class $BoutiquesTable extends Boutiques
    with TableInfo<$BoutiquesTable, Boutique> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoutiquesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supprimeLeMeta = const VerificationMeta(
    'supprimeLe',
  );
  @override
  late final GeneratedColumn<DateTime> supprimeLe = GeneratedColumn<DateTime>(
    'supprime_le',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchroMeta = const VerificationMeta(
    'synchro',
  );
  @override
  late final GeneratedColumn<bool> synchro = GeneratedColumn<bool>(
    'synchro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appareilIdMeta = const VerificationMeta(
    'appareilId',
  );
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
    'appareil_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telephoneMeta = const VerificationMeta(
    'telephone',
  );
  @override
  late final GeneratedColumn<String> telephone = GeneratedColumn<String>(
    'telephone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villeMeta = const VerificationMeta('ville');
  @override
  late final GeneratedColumn<String> ville = GeneratedColumn<String>(
    'ville',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quartierMeta = const VerificationMeta(
    'quartier',
  );
  @override
  late final GeneratedColumn<String> quartier = GeneratedColumn<String>(
    'quartier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeCommerceMeta = const VerificationMeta(
    'typeCommerce',
  );
  @override
  late final GeneratedColumn<String> typeCommerce = GeneratedColumn<String>(
    'type_commerce',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seuilAlerteDefautMeta = const VerificationMeta(
    'seuilAlerteDefaut',
  );
  @override
  late final GeneratedColumn<int> seuilAlerteDefaut = GeneratedColumn<int>(
    'seuil_alerte_defaut',
    aliasedName,
    false,
    check: () => ComparableExpr(seuilAlerteDefaut).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creeLeMeta = const VerificationMeta('creeLe');
  @override
  late final GeneratedColumn<DateTime> creeLe = GeneratedColumn<DateTime>(
    'cree_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    nom,
    telephone,
    ville,
    quartier,
    typeCommerce,
    seuilAlerteDefaut,
    creeLe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'boutiques';
  @override
  VerificationContext validateIntegrity(
    Insertable<Boutique> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('maj_le')) {
      context.handle(
        _majLeMeta,
        majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta),
      );
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    if (data.containsKey('supprime_le')) {
      context.handle(
        _supprimeLeMeta,
        supprimeLe.isAcceptableOrUnknown(data['supprime_le']!, _supprimeLeMeta),
      );
    }
    if (data.containsKey('synchro')) {
      context.handle(
        _synchroMeta,
        synchro.isAcceptableOrUnknown(data['synchro']!, _synchroMeta),
      );
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
        _appareilIdMeta,
        appareilId.isAcceptableOrUnknown(data['appareil_id']!, _appareilIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('telephone')) {
      context.handle(
        _telephoneMeta,
        telephone.isAcceptableOrUnknown(data['telephone']!, _telephoneMeta),
      );
    } else if (isInserting) {
      context.missing(_telephoneMeta);
    }
    if (data.containsKey('ville')) {
      context.handle(
        _villeMeta,
        ville.isAcceptableOrUnknown(data['ville']!, _villeMeta),
      );
    } else if (isInserting) {
      context.missing(_villeMeta);
    }
    if (data.containsKey('quartier')) {
      context.handle(
        _quartierMeta,
        quartier.isAcceptableOrUnknown(data['quartier']!, _quartierMeta),
      );
    } else if (isInserting) {
      context.missing(_quartierMeta);
    }
    if (data.containsKey('type_commerce')) {
      context.handle(
        _typeCommerceMeta,
        typeCommerce.isAcceptableOrUnknown(
          data['type_commerce']!,
          _typeCommerceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_typeCommerceMeta);
    }
    if (data.containsKey('seuil_alerte_defaut')) {
      context.handle(
        _seuilAlerteDefautMeta,
        seuilAlerteDefaut.isAcceptableOrUnknown(
          data['seuil_alerte_defaut']!,
          _seuilAlerteDefautMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seuilAlerteDefautMeta);
    }
    if (data.containsKey('cree_le')) {
      context.handle(
        _creeLeMeta,
        creeLe.isAcceptableOrUnknown(data['cree_le']!, _creeLeMeta),
      );
    } else if (isInserting) {
      context.missing(_creeLeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Boutique map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Boutique(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      majLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maj_le'],
      )!,
      supprimeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}supprime_le'],
      ),
      synchro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchro'],
      )!,
      appareilId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appareil_id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      telephone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telephone'],
      )!,
      ville: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ville'],
      )!,
      quartier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quartier'],
      )!,
      typeCommerce: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_commerce'],
      )!,
      seuilAlerteDefaut: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seuil_alerte_defaut'],
      )!,
      creeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cree_le'],
      )!,
    );
  }

  @override
  $BoutiquesTable createAlias(String alias) {
    return $BoutiquesTable(attachedDatabase, alias);
  }
}

class Boutique extends DataClass implements Insertable<Boutique> {
  final String id;
  final DateTime majLe;
  final DateTime? supprimeLe;
  final bool synchro;
  final String appareilId;
  final String nom;
  final String telephone;
  final String ville;
  final String quartier;
  final String typeCommerce;
  final int seuilAlerteDefaut;
  final DateTime creeLe;
  const Boutique({
    required this.id,
    required this.majLe,
    this.supprimeLe,
    required this.synchro,
    required this.appareilId,
    required this.nom,
    required this.telephone,
    required this.ville,
    required this.quartier,
    required this.typeCommerce,
    required this.seuilAlerteDefaut,
    required this.creeLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maj_le'] = Variable<DateTime>(majLe);
    if (!nullToAbsent || supprimeLe != null) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe);
    }
    map['synchro'] = Variable<bool>(synchro);
    map['appareil_id'] = Variable<String>(appareilId);
    map['nom'] = Variable<String>(nom);
    map['telephone'] = Variable<String>(telephone);
    map['ville'] = Variable<String>(ville);
    map['quartier'] = Variable<String>(quartier);
    map['type_commerce'] = Variable<String>(typeCommerce);
    map['seuil_alerte_defaut'] = Variable<int>(seuilAlerteDefaut);
    map['cree_le'] = Variable<DateTime>(creeLe);
    return map;
  }

  BoutiquesCompanion toCompanion(bool nullToAbsent) {
    return BoutiquesCompanion(
      id: Value(id),
      majLe: Value(majLe),
      supprimeLe: supprimeLe == null && nullToAbsent
          ? const Value.absent()
          : Value(supprimeLe),
      synchro: Value(synchro),
      appareilId: Value(appareilId),
      nom: Value(nom),
      telephone: Value(telephone),
      ville: Value(ville),
      quartier: Value(quartier),
      typeCommerce: Value(typeCommerce),
      seuilAlerteDefaut: Value(seuilAlerteDefaut),
      creeLe: Value(creeLe),
    );
  }

  factory Boutique.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Boutique(
      id: serializer.fromJson<String>(json['id']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
      supprimeLe: serializer.fromJson<DateTime?>(json['supprimeLe']),
      synchro: serializer.fromJson<bool>(json['synchro']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      nom: serializer.fromJson<String>(json['nom']),
      telephone: serializer.fromJson<String>(json['telephone']),
      ville: serializer.fromJson<String>(json['ville']),
      quartier: serializer.fromJson<String>(json['quartier']),
      typeCommerce: serializer.fromJson<String>(json['typeCommerce']),
      seuilAlerteDefaut: serializer.fromJson<int>(json['seuilAlerteDefaut']),
      creeLe: serializer.fromJson<DateTime>(json['creeLe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'majLe': serializer.toJson<DateTime>(majLe),
      'supprimeLe': serializer.toJson<DateTime?>(supprimeLe),
      'synchro': serializer.toJson<bool>(synchro),
      'appareilId': serializer.toJson<String>(appareilId),
      'nom': serializer.toJson<String>(nom),
      'telephone': serializer.toJson<String>(telephone),
      'ville': serializer.toJson<String>(ville),
      'quartier': serializer.toJson<String>(quartier),
      'typeCommerce': serializer.toJson<String>(typeCommerce),
      'seuilAlerteDefaut': serializer.toJson<int>(seuilAlerteDefaut),
      'creeLe': serializer.toJson<DateTime>(creeLe),
    };
  }

  Boutique copyWith({
    String? id,
    DateTime? majLe,
    Value<DateTime?> supprimeLe = const Value.absent(),
    bool? synchro,
    String? appareilId,
    String? nom,
    String? telephone,
    String? ville,
    String? quartier,
    String? typeCommerce,
    int? seuilAlerteDefaut,
    DateTime? creeLe,
  }) => Boutique(
    id: id ?? this.id,
    majLe: majLe ?? this.majLe,
    supprimeLe: supprimeLe.present ? supprimeLe.value : this.supprimeLe,
    synchro: synchro ?? this.synchro,
    appareilId: appareilId ?? this.appareilId,
    nom: nom ?? this.nom,
    telephone: telephone ?? this.telephone,
    ville: ville ?? this.ville,
    quartier: quartier ?? this.quartier,
    typeCommerce: typeCommerce ?? this.typeCommerce,
    seuilAlerteDefaut: seuilAlerteDefaut ?? this.seuilAlerteDefaut,
    creeLe: creeLe ?? this.creeLe,
  );
  Boutique copyWithCompanion(BoutiquesCompanion data) {
    return Boutique(
      id: data.id.present ? data.id.value : this.id,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
      supprimeLe: data.supprimeLe.present
          ? data.supprimeLe.value
          : this.supprimeLe,
      synchro: data.synchro.present ? data.synchro.value : this.synchro,
      appareilId: data.appareilId.present
          ? data.appareilId.value
          : this.appareilId,
      nom: data.nom.present ? data.nom.value : this.nom,
      telephone: data.telephone.present ? data.telephone.value : this.telephone,
      ville: data.ville.present ? data.ville.value : this.ville,
      quartier: data.quartier.present ? data.quartier.value : this.quartier,
      typeCommerce: data.typeCommerce.present
          ? data.typeCommerce.value
          : this.typeCommerce,
      seuilAlerteDefaut: data.seuilAlerteDefaut.present
          ? data.seuilAlerteDefaut.value
          : this.seuilAlerteDefaut,
      creeLe: data.creeLe.present ? data.creeLe.value : this.creeLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Boutique(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('nom: $nom, ')
          ..write('telephone: $telephone, ')
          ..write('ville: $ville, ')
          ..write('quartier: $quartier, ')
          ..write('typeCommerce: $typeCommerce, ')
          ..write('seuilAlerteDefaut: $seuilAlerteDefaut, ')
          ..write('creeLe: $creeLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    nom,
    telephone,
    ville,
    quartier,
    typeCommerce,
    seuilAlerteDefaut,
    creeLe,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Boutique &&
          other.id == this.id &&
          other.majLe == this.majLe &&
          other.supprimeLe == this.supprimeLe &&
          other.synchro == this.synchro &&
          other.appareilId == this.appareilId &&
          other.nom == this.nom &&
          other.telephone == this.telephone &&
          other.ville == this.ville &&
          other.quartier == this.quartier &&
          other.typeCommerce == this.typeCommerce &&
          other.seuilAlerteDefaut == this.seuilAlerteDefaut &&
          other.creeLe == this.creeLe);
}

class BoutiquesCompanion extends UpdateCompanion<Boutique> {
  final Value<String> id;
  final Value<DateTime> majLe;
  final Value<DateTime?> supprimeLe;
  final Value<bool> synchro;
  final Value<String> appareilId;
  final Value<String> nom;
  final Value<String> telephone;
  final Value<String> ville;
  final Value<String> quartier;
  final Value<String> typeCommerce;
  final Value<int> seuilAlerteDefaut;
  final Value<DateTime> creeLe;
  final Value<int> rowid;
  const BoutiquesCompanion({
    this.id = const Value.absent(),
    this.majLe = const Value.absent(),
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.nom = const Value.absent(),
    this.telephone = const Value.absent(),
    this.ville = const Value.absent(),
    this.quartier = const Value.absent(),
    this.typeCommerce = const Value.absent(),
    this.seuilAlerteDefaut = const Value.absent(),
    this.creeLe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BoutiquesCompanion.insert({
    required String id,
    required DateTime majLe,
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    required String appareilId,
    required String nom,
    required String telephone,
    required String ville,
    required String quartier,
    required String typeCommerce,
    required int seuilAlerteDefaut,
    required DateTime creeLe,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       majLe = Value(majLe),
       appareilId = Value(appareilId),
       nom = Value(nom),
       telephone = Value(telephone),
       ville = Value(ville),
       quartier = Value(quartier),
       typeCommerce = Value(typeCommerce),
       seuilAlerteDefaut = Value(seuilAlerteDefaut),
       creeLe = Value(creeLe);
  static Insertable<Boutique> custom({
    Expression<String>? id,
    Expression<DateTime>? majLe,
    Expression<DateTime>? supprimeLe,
    Expression<bool>? synchro,
    Expression<String>? appareilId,
    Expression<String>? nom,
    Expression<String>? telephone,
    Expression<String>? ville,
    Expression<String>? quartier,
    Expression<String>? typeCommerce,
    Expression<int>? seuilAlerteDefaut,
    Expression<DateTime>? creeLe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (majLe != null) 'maj_le': majLe,
      if (supprimeLe != null) 'supprime_le': supprimeLe,
      if (synchro != null) 'synchro': synchro,
      if (appareilId != null) 'appareil_id': appareilId,
      if (nom != null) 'nom': nom,
      if (telephone != null) 'telephone': telephone,
      if (ville != null) 'ville': ville,
      if (quartier != null) 'quartier': quartier,
      if (typeCommerce != null) 'type_commerce': typeCommerce,
      if (seuilAlerteDefaut != null) 'seuil_alerte_defaut': seuilAlerteDefaut,
      if (creeLe != null) 'cree_le': creeLe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BoutiquesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? majLe,
    Value<DateTime?>? supprimeLe,
    Value<bool>? synchro,
    Value<String>? appareilId,
    Value<String>? nom,
    Value<String>? telephone,
    Value<String>? ville,
    Value<String>? quartier,
    Value<String>? typeCommerce,
    Value<int>? seuilAlerteDefaut,
    Value<DateTime>? creeLe,
    Value<int>? rowid,
  }) {
    return BoutiquesCompanion(
      id: id ?? this.id,
      majLe: majLe ?? this.majLe,
      supprimeLe: supprimeLe ?? this.supprimeLe,
      synchro: synchro ?? this.synchro,
      appareilId: appareilId ?? this.appareilId,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      ville: ville ?? this.ville,
      quartier: quartier ?? this.quartier,
      typeCommerce: typeCommerce ?? this.typeCommerce,
      seuilAlerteDefaut: seuilAlerteDefaut ?? this.seuilAlerteDefaut,
      creeLe: creeLe ?? this.creeLe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    if (supprimeLe.present) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe.value);
    }
    if (synchro.present) {
      map['synchro'] = Variable<bool>(synchro.value);
    }
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (telephone.present) {
      map['telephone'] = Variable<String>(telephone.value);
    }
    if (ville.present) {
      map['ville'] = Variable<String>(ville.value);
    }
    if (quartier.present) {
      map['quartier'] = Variable<String>(quartier.value);
    }
    if (typeCommerce.present) {
      map['type_commerce'] = Variable<String>(typeCommerce.value);
    }
    if (seuilAlerteDefaut.present) {
      map['seuil_alerte_defaut'] = Variable<int>(seuilAlerteDefaut.value);
    }
    if (creeLe.present) {
      map['cree_le'] = Variable<DateTime>(creeLe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoutiquesCompanion(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('nom: $nom, ')
          ..write('telephone: $telephone, ')
          ..write('ville: $ville, ')
          ..write('quartier: $quartier, ')
          ..write('typeCommerce: $typeCommerce, ')
          ..write('seuilAlerteDefaut: $seuilAlerteDefaut, ')
          ..write('creeLe: $creeLe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UtilisateursTable extends Utilisateurs
    with TableInfo<$UtilisateursTable, Utilisateur> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UtilisateursTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supprimeLeMeta = const VerificationMeta(
    'supprimeLe',
  );
  @override
  late final GeneratedColumn<DateTime> supprimeLe = GeneratedColumn<DateTime>(
    'supprime_le',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchroMeta = const VerificationMeta(
    'synchro',
  );
  @override
  late final GeneratedColumn<bool> synchro = GeneratedColumn<bool>(
    'synchro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appareilIdMeta = const VerificationMeta(
    'appareilId',
  );
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
    'appareil_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boutiqueIdMeta = const VerificationMeta(
    'boutiqueId',
  );
  @override
  late final GeneratedColumn<String> boutiqueId = GeneratedColumn<String>(
    'boutique_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES boutiques (id)',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telephoneMeta = const VerificationMeta(
    'telephone',
  );
  @override
  late final GeneratedColumn<String> telephone = GeneratedColumn<String>(
    'telephone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    check: () => role.isIn(Role.tous),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(Role.proprietaire),
  );
  static const VerificationMeta _codePinMeta = const VerificationMeta(
    'codePin',
  );
  @override
  late final GeneratedColumn<String> codePin = GeneratedColumn<String>(
    'code_pin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    boutiqueId,
    nom,
    telephone,
    role,
    codePin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'utilisateurs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Utilisateur> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('maj_le')) {
      context.handle(
        _majLeMeta,
        majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta),
      );
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    if (data.containsKey('supprime_le')) {
      context.handle(
        _supprimeLeMeta,
        supprimeLe.isAcceptableOrUnknown(data['supprime_le']!, _supprimeLeMeta),
      );
    }
    if (data.containsKey('synchro')) {
      context.handle(
        _synchroMeta,
        synchro.isAcceptableOrUnknown(data['synchro']!, _synchroMeta),
      );
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
        _appareilIdMeta,
        appareilId.isAcceptableOrUnknown(data['appareil_id']!, _appareilIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('boutique_id')) {
      context.handle(
        _boutiqueIdMeta,
        boutiqueId.isAcceptableOrUnknown(data['boutique_id']!, _boutiqueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boutiqueIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('telephone')) {
      context.handle(
        _telephoneMeta,
        telephone.isAcceptableOrUnknown(data['telephone']!, _telephoneMeta),
      );
    } else if (isInserting) {
      context.missing(_telephoneMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('code_pin')) {
      context.handle(
        _codePinMeta,
        codePin.isAcceptableOrUnknown(data['code_pin']!, _codePinMeta),
      );
    } else if (isInserting) {
      context.missing(_codePinMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Utilisateur map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Utilisateur(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      majLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maj_le'],
      )!,
      supprimeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}supprime_le'],
      ),
      synchro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchro'],
      )!,
      appareilId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appareil_id'],
      )!,
      boutiqueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boutique_id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      telephone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telephone'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      codePin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_pin'],
      )!,
    );
  }

  @override
  $UtilisateursTable createAlias(String alias) {
    return $UtilisateursTable(attachedDatabase, alias);
  }
}

class Utilisateur extends DataClass implements Insertable<Utilisateur> {
  final String id;
  final DateTime majLe;
  final DateTime? supprimeLe;
  final bool synchro;
  final String appareilId;
  final String boutiqueId;
  final String nom;
  final String telephone;
  final String role;

  /// Code PIN à 4 chiffres, haché (jamais en clair).
  final String codePin;
  const Utilisateur({
    required this.id,
    required this.majLe,
    this.supprimeLe,
    required this.synchro,
    required this.appareilId,
    required this.boutiqueId,
    required this.nom,
    required this.telephone,
    required this.role,
    required this.codePin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maj_le'] = Variable<DateTime>(majLe);
    if (!nullToAbsent || supprimeLe != null) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe);
    }
    map['synchro'] = Variable<bool>(synchro);
    map['appareil_id'] = Variable<String>(appareilId);
    map['boutique_id'] = Variable<String>(boutiqueId);
    map['nom'] = Variable<String>(nom);
    map['telephone'] = Variable<String>(telephone);
    map['role'] = Variable<String>(role);
    map['code_pin'] = Variable<String>(codePin);
    return map;
  }

  UtilisateursCompanion toCompanion(bool nullToAbsent) {
    return UtilisateursCompanion(
      id: Value(id),
      majLe: Value(majLe),
      supprimeLe: supprimeLe == null && nullToAbsent
          ? const Value.absent()
          : Value(supprimeLe),
      synchro: Value(synchro),
      appareilId: Value(appareilId),
      boutiqueId: Value(boutiqueId),
      nom: Value(nom),
      telephone: Value(telephone),
      role: Value(role),
      codePin: Value(codePin),
    );
  }

  factory Utilisateur.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Utilisateur(
      id: serializer.fromJson<String>(json['id']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
      supprimeLe: serializer.fromJson<DateTime?>(json['supprimeLe']),
      synchro: serializer.fromJson<bool>(json['synchro']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      boutiqueId: serializer.fromJson<String>(json['boutiqueId']),
      nom: serializer.fromJson<String>(json['nom']),
      telephone: serializer.fromJson<String>(json['telephone']),
      role: serializer.fromJson<String>(json['role']),
      codePin: serializer.fromJson<String>(json['codePin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'majLe': serializer.toJson<DateTime>(majLe),
      'supprimeLe': serializer.toJson<DateTime?>(supprimeLe),
      'synchro': serializer.toJson<bool>(synchro),
      'appareilId': serializer.toJson<String>(appareilId),
      'boutiqueId': serializer.toJson<String>(boutiqueId),
      'nom': serializer.toJson<String>(nom),
      'telephone': serializer.toJson<String>(telephone),
      'role': serializer.toJson<String>(role),
      'codePin': serializer.toJson<String>(codePin),
    };
  }

  Utilisateur copyWith({
    String? id,
    DateTime? majLe,
    Value<DateTime?> supprimeLe = const Value.absent(),
    bool? synchro,
    String? appareilId,
    String? boutiqueId,
    String? nom,
    String? telephone,
    String? role,
    String? codePin,
  }) => Utilisateur(
    id: id ?? this.id,
    majLe: majLe ?? this.majLe,
    supprimeLe: supprimeLe.present ? supprimeLe.value : this.supprimeLe,
    synchro: synchro ?? this.synchro,
    appareilId: appareilId ?? this.appareilId,
    boutiqueId: boutiqueId ?? this.boutiqueId,
    nom: nom ?? this.nom,
    telephone: telephone ?? this.telephone,
    role: role ?? this.role,
    codePin: codePin ?? this.codePin,
  );
  Utilisateur copyWithCompanion(UtilisateursCompanion data) {
    return Utilisateur(
      id: data.id.present ? data.id.value : this.id,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
      supprimeLe: data.supprimeLe.present
          ? data.supprimeLe.value
          : this.supprimeLe,
      synchro: data.synchro.present ? data.synchro.value : this.synchro,
      appareilId: data.appareilId.present
          ? data.appareilId.value
          : this.appareilId,
      boutiqueId: data.boutiqueId.present
          ? data.boutiqueId.value
          : this.boutiqueId,
      nom: data.nom.present ? data.nom.value : this.nom,
      telephone: data.telephone.present ? data.telephone.value : this.telephone,
      role: data.role.present ? data.role.value : this.role,
      codePin: data.codePin.present ? data.codePin.value : this.codePin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Utilisateur(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('nom: $nom, ')
          ..write('telephone: $telephone, ')
          ..write('role: $role, ')
          ..write('codePin: $codePin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    boutiqueId,
    nom,
    telephone,
    role,
    codePin,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Utilisateur &&
          other.id == this.id &&
          other.majLe == this.majLe &&
          other.supprimeLe == this.supprimeLe &&
          other.synchro == this.synchro &&
          other.appareilId == this.appareilId &&
          other.boutiqueId == this.boutiqueId &&
          other.nom == this.nom &&
          other.telephone == this.telephone &&
          other.role == this.role &&
          other.codePin == this.codePin);
}

class UtilisateursCompanion extends UpdateCompanion<Utilisateur> {
  final Value<String> id;
  final Value<DateTime> majLe;
  final Value<DateTime?> supprimeLe;
  final Value<bool> synchro;
  final Value<String> appareilId;
  final Value<String> boutiqueId;
  final Value<String> nom;
  final Value<String> telephone;
  final Value<String> role;
  final Value<String> codePin;
  final Value<int> rowid;
  const UtilisateursCompanion({
    this.id = const Value.absent(),
    this.majLe = const Value.absent(),
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.boutiqueId = const Value.absent(),
    this.nom = const Value.absent(),
    this.telephone = const Value.absent(),
    this.role = const Value.absent(),
    this.codePin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UtilisateursCompanion.insert({
    required String id,
    required DateTime majLe,
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    required String appareilId,
    required String boutiqueId,
    required String nom,
    required String telephone,
    this.role = const Value.absent(),
    required String codePin,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       majLe = Value(majLe),
       appareilId = Value(appareilId),
       boutiqueId = Value(boutiqueId),
       nom = Value(nom),
       telephone = Value(telephone),
       codePin = Value(codePin);
  static Insertable<Utilisateur> custom({
    Expression<String>? id,
    Expression<DateTime>? majLe,
    Expression<DateTime>? supprimeLe,
    Expression<bool>? synchro,
    Expression<String>? appareilId,
    Expression<String>? boutiqueId,
    Expression<String>? nom,
    Expression<String>? telephone,
    Expression<String>? role,
    Expression<String>? codePin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (majLe != null) 'maj_le': majLe,
      if (supprimeLe != null) 'supprime_le': supprimeLe,
      if (synchro != null) 'synchro': synchro,
      if (appareilId != null) 'appareil_id': appareilId,
      if (boutiqueId != null) 'boutique_id': boutiqueId,
      if (nom != null) 'nom': nom,
      if (telephone != null) 'telephone': telephone,
      if (role != null) 'role': role,
      if (codePin != null) 'code_pin': codePin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UtilisateursCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? majLe,
    Value<DateTime?>? supprimeLe,
    Value<bool>? synchro,
    Value<String>? appareilId,
    Value<String>? boutiqueId,
    Value<String>? nom,
    Value<String>? telephone,
    Value<String>? role,
    Value<String>? codePin,
    Value<int>? rowid,
  }) {
    return UtilisateursCompanion(
      id: id ?? this.id,
      majLe: majLe ?? this.majLe,
      supprimeLe: supprimeLe ?? this.supprimeLe,
      synchro: synchro ?? this.synchro,
      appareilId: appareilId ?? this.appareilId,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      codePin: codePin ?? this.codePin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    if (supprimeLe.present) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe.value);
    }
    if (synchro.present) {
      map['synchro'] = Variable<bool>(synchro.value);
    }
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (boutiqueId.present) {
      map['boutique_id'] = Variable<String>(boutiqueId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (telephone.present) {
      map['telephone'] = Variable<String>(telephone.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (codePin.present) {
      map['code_pin'] = Variable<String>(codePin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UtilisateursCompanion(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('boutiqueId: $boutiqueId, ')
          ..write('nom: $nom, ')
          ..write('telephone: $telephone, ')
          ..write('role: $role, ')
          ..write('codePin: $codePin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Categorie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supprimeLeMeta = const VerificationMeta(
    'supprimeLe',
  );
  @override
  late final GeneratedColumn<DateTime> supprimeLe = GeneratedColumn<DateTime>(
    'supprime_le',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchroMeta = const VerificationMeta(
    'synchro',
  );
  @override
  late final GeneratedColumn<bool> synchro = GeneratedColumn<bool>(
    'synchro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appareilIdMeta = const VerificationMeta(
    'appareilId',
  );
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
    'appareil_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconeMeta = const VerificationMeta('icone');
  @override
  late final GeneratedColumn<String> icone = GeneratedColumn<String>(
    'icone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    nom,
    icone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categorie> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('maj_le')) {
      context.handle(
        _majLeMeta,
        majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta),
      );
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    if (data.containsKey('supprime_le')) {
      context.handle(
        _supprimeLeMeta,
        supprimeLe.isAcceptableOrUnknown(data['supprime_le']!, _supprimeLeMeta),
      );
    }
    if (data.containsKey('synchro')) {
      context.handle(
        _synchroMeta,
        synchro.isAcceptableOrUnknown(data['synchro']!, _synchroMeta),
      );
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
        _appareilIdMeta,
        appareilId.isAcceptableOrUnknown(data['appareil_id']!, _appareilIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('icone')) {
      context.handle(
        _iconeMeta,
        icone.isAcceptableOrUnknown(data['icone']!, _iconeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categorie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categorie(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      majLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maj_le'],
      )!,
      supprimeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}supprime_le'],
      ),
      synchro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchro'],
      )!,
      appareilId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appareil_id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      icone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icone'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Categorie extends DataClass implements Insertable<Categorie> {
  final String id;
  final DateTime majLe;
  final DateTime? supprimeLe;
  final bool synchro;
  final String appareilId;
  final String nom;
  final String icone;
  const Categorie({
    required this.id,
    required this.majLe,
    this.supprimeLe,
    required this.synchro,
    required this.appareilId,
    required this.nom,
    required this.icone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maj_le'] = Variable<DateTime>(majLe);
    if (!nullToAbsent || supprimeLe != null) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe);
    }
    map['synchro'] = Variable<bool>(synchro);
    map['appareil_id'] = Variable<String>(appareilId);
    map['nom'] = Variable<String>(nom);
    map['icone'] = Variable<String>(icone);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      majLe: Value(majLe),
      supprimeLe: supprimeLe == null && nullToAbsent
          ? const Value.absent()
          : Value(supprimeLe),
      synchro: Value(synchro),
      appareilId: Value(appareilId),
      nom: Value(nom),
      icone: Value(icone),
    );
  }

  factory Categorie.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categorie(
      id: serializer.fromJson<String>(json['id']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
      supprimeLe: serializer.fromJson<DateTime?>(json['supprimeLe']),
      synchro: serializer.fromJson<bool>(json['synchro']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      nom: serializer.fromJson<String>(json['nom']),
      icone: serializer.fromJson<String>(json['icone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'majLe': serializer.toJson<DateTime>(majLe),
      'supprimeLe': serializer.toJson<DateTime?>(supprimeLe),
      'synchro': serializer.toJson<bool>(synchro),
      'appareilId': serializer.toJson<String>(appareilId),
      'nom': serializer.toJson<String>(nom),
      'icone': serializer.toJson<String>(icone),
    };
  }

  Categorie copyWith({
    String? id,
    DateTime? majLe,
    Value<DateTime?> supprimeLe = const Value.absent(),
    bool? synchro,
    String? appareilId,
    String? nom,
    String? icone,
  }) => Categorie(
    id: id ?? this.id,
    majLe: majLe ?? this.majLe,
    supprimeLe: supprimeLe.present ? supprimeLe.value : this.supprimeLe,
    synchro: synchro ?? this.synchro,
    appareilId: appareilId ?? this.appareilId,
    nom: nom ?? this.nom,
    icone: icone ?? this.icone,
  );
  Categorie copyWithCompanion(CategoriesCompanion data) {
    return Categorie(
      id: data.id.present ? data.id.value : this.id,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
      supprimeLe: data.supprimeLe.present
          ? data.supprimeLe.value
          : this.supprimeLe,
      synchro: data.synchro.present ? data.synchro.value : this.synchro,
      appareilId: data.appareilId.present
          ? data.appareilId.value
          : this.appareilId,
      nom: data.nom.present ? data.nom.value : this.nom,
      icone: data.icone.present ? data.icone.value : this.icone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categorie(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('nom: $nom, ')
          ..write('icone: $icone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, majLe, supprimeLe, synchro, appareilId, nom, icone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categorie &&
          other.id == this.id &&
          other.majLe == this.majLe &&
          other.supprimeLe == this.supprimeLe &&
          other.synchro == this.synchro &&
          other.appareilId == this.appareilId &&
          other.nom == this.nom &&
          other.icone == this.icone);
}

class CategoriesCompanion extends UpdateCompanion<Categorie> {
  final Value<String> id;
  final Value<DateTime> majLe;
  final Value<DateTime?> supprimeLe;
  final Value<bool> synchro;
  final Value<String> appareilId;
  final Value<String> nom;
  final Value<String> icone;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.majLe = const Value.absent(),
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.nom = const Value.absent(),
    this.icone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required DateTime majLe,
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    required String appareilId,
    required String nom,
    required String icone,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       majLe = Value(majLe),
       appareilId = Value(appareilId),
       nom = Value(nom),
       icone = Value(icone);
  static Insertable<Categorie> custom({
    Expression<String>? id,
    Expression<DateTime>? majLe,
    Expression<DateTime>? supprimeLe,
    Expression<bool>? synchro,
    Expression<String>? appareilId,
    Expression<String>? nom,
    Expression<String>? icone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (majLe != null) 'maj_le': majLe,
      if (supprimeLe != null) 'supprime_le': supprimeLe,
      if (synchro != null) 'synchro': synchro,
      if (appareilId != null) 'appareil_id': appareilId,
      if (nom != null) 'nom': nom,
      if (icone != null) 'icone': icone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? majLe,
    Value<DateTime?>? supprimeLe,
    Value<bool>? synchro,
    Value<String>? appareilId,
    Value<String>? nom,
    Value<String>? icone,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      majLe: majLe ?? this.majLe,
      supprimeLe: supprimeLe ?? this.supprimeLe,
      synchro: synchro ?? this.synchro,
      appareilId: appareilId ?? this.appareilId,
      nom: nom ?? this.nom,
      icone: icone ?? this.icone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    if (supprimeLe.present) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe.value);
    }
    if (synchro.present) {
      map['synchro'] = Variable<bool>(synchro.value);
    }
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (icone.present) {
      map['icone'] = Variable<String>(icone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('nom: $nom, ')
          ..write('icone: $icone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProduitsTable extends Produits with TableInfo<$ProduitsTable, Produit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProduitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supprimeLeMeta = const VerificationMeta(
    'supprimeLe',
  );
  @override
  late final GeneratedColumn<DateTime> supprimeLe = GeneratedColumn<DateTime>(
    'supprime_le',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchroMeta = const VerificationMeta(
    'synchro',
  );
  @override
  late final GeneratedColumn<bool> synchro = GeneratedColumn<bool>(
    'synchro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appareilIdMeta = const VerificationMeta(
    'appareilId',
  );
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
    'appareil_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categorieIdMeta = const VerificationMeta(
    'categorieId',
  );
  @override
  late final GeneratedColumn<String> categorieId = GeneratedColumn<String>(
    'categorie_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prixAchatMeta = const VerificationMeta(
    'prixAchat',
  );
  @override
  late final GeneratedColumn<int> prixAchat = GeneratedColumn<int>(
    'prix_achat',
    aliasedName,
    false,
    check: () => ComparableExpr(prixAchat).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prixVenteMeta = const VerificationMeta(
    'prixVente',
  );
  @override
  late final GeneratedColumn<int> prixVente = GeneratedColumn<int>(
    'prix_vente',
    aliasedName,
    false,
    check: () => ComparableExpr(prixVente).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantiteMeta = const VerificationMeta(
    'quantite',
  );
  @override
  late final GeneratedColumn<double> quantite = GeneratedColumn<double>(
    'quantite',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _uniteMeta = const VerificationMeta('unite');
  @override
  late final GeneratedColumn<String> unite = GeneratedColumn<String>(
    'unite',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seuilAlerteMeta = const VerificationMeta(
    'seuilAlerte',
  );
  @override
  late final GeneratedColumn<double> seuilAlerte = GeneratedColumn<double>(
    'seuil_alerte',
    aliasedName,
    false,
    check: () => ComparableExpr(seuilAlerte).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoLocaleMeta = const VerificationMeta(
    'photoLocale',
  );
  @override
  late final GeneratedColumn<String> photoLocale = GeneratedColumn<String>(
    'photo_locale',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeBarreMeta = const VerificationMeta(
    'codeBarre',
  );
  @override
  late final GeneratedColumn<String> codeBarre = GeneratedColumn<String>(
    'code_barre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    categorieId,
    nom,
    prixAchat,
    prixVente,
    quantite,
    unite,
    seuilAlerte,
    photoLocale,
    codeBarre,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'produits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Produit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('maj_le')) {
      context.handle(
        _majLeMeta,
        majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta),
      );
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    if (data.containsKey('supprime_le')) {
      context.handle(
        _supprimeLeMeta,
        supprimeLe.isAcceptableOrUnknown(data['supprime_le']!, _supprimeLeMeta),
      );
    }
    if (data.containsKey('synchro')) {
      context.handle(
        _synchroMeta,
        synchro.isAcceptableOrUnknown(data['synchro']!, _synchroMeta),
      );
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
        _appareilIdMeta,
        appareilId.isAcceptableOrUnknown(data['appareil_id']!, _appareilIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('categorie_id')) {
      context.handle(
        _categorieIdMeta,
        categorieId.isAcceptableOrUnknown(
          data['categorie_id']!,
          _categorieIdMeta,
        ),
      );
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('prix_achat')) {
      context.handle(
        _prixAchatMeta,
        prixAchat.isAcceptableOrUnknown(data['prix_achat']!, _prixAchatMeta),
      );
    } else if (isInserting) {
      context.missing(_prixAchatMeta);
    }
    if (data.containsKey('prix_vente')) {
      context.handle(
        _prixVenteMeta,
        prixVente.isAcceptableOrUnknown(data['prix_vente']!, _prixVenteMeta),
      );
    } else if (isInserting) {
      context.missing(_prixVenteMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(
        _quantiteMeta,
        quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta),
      );
    }
    if (data.containsKey('unite')) {
      context.handle(
        _uniteMeta,
        unite.isAcceptableOrUnknown(data['unite']!, _uniteMeta),
      );
    } else if (isInserting) {
      context.missing(_uniteMeta);
    }
    if (data.containsKey('seuil_alerte')) {
      context.handle(
        _seuilAlerteMeta,
        seuilAlerte.isAcceptableOrUnknown(
          data['seuil_alerte']!,
          _seuilAlerteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seuilAlerteMeta);
    }
    if (data.containsKey('photo_locale')) {
      context.handle(
        _photoLocaleMeta,
        photoLocale.isAcceptableOrUnknown(
          data['photo_locale']!,
          _photoLocaleMeta,
        ),
      );
    }
    if (data.containsKey('code_barre')) {
      context.handle(
        _codeBarreMeta,
        codeBarre.isAcceptableOrUnknown(data['code_barre']!, _codeBarreMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Produit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Produit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      majLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maj_le'],
      )!,
      supprimeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}supprime_le'],
      ),
      synchro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchro'],
      )!,
      appareilId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appareil_id'],
      )!,
      categorieId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categorie_id'],
      ),
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      prixAchat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prix_achat'],
      )!,
      prixVente: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prix_vente'],
      )!,
      quantite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantite'],
      )!,
      unite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unite'],
      )!,
      seuilAlerte: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}seuil_alerte'],
      )!,
      photoLocale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_locale'],
      ),
      codeBarre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_barre'],
      ),
    );
  }

  @override
  $ProduitsTable createAlias(String alias) {
    return $ProduitsTable(attachedDatabase, alias);
  }
}

class Produit extends DataClass implements Insertable<Produit> {
  final String id;
  final DateTime majLe;
  final DateTime? supprimeLe;
  final bool synchro;
  final String appareilId;
  final String? categorieId;
  final String nom;
  final int prixAchat;
  final int prixVente;

  /// Stock actuel, toujours recalculé depuis `mouvements_stock`.
  final double quantite;
  final String unite;
  final double seuilAlerte;
  final String? photoLocale;
  final String? codeBarre;
  const Produit({
    required this.id,
    required this.majLe,
    this.supprimeLe,
    required this.synchro,
    required this.appareilId,
    this.categorieId,
    required this.nom,
    required this.prixAchat,
    required this.prixVente,
    required this.quantite,
    required this.unite,
    required this.seuilAlerte,
    this.photoLocale,
    this.codeBarre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maj_le'] = Variable<DateTime>(majLe);
    if (!nullToAbsent || supprimeLe != null) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe);
    }
    map['synchro'] = Variable<bool>(synchro);
    map['appareil_id'] = Variable<String>(appareilId);
    if (!nullToAbsent || categorieId != null) {
      map['categorie_id'] = Variable<String>(categorieId);
    }
    map['nom'] = Variable<String>(nom);
    map['prix_achat'] = Variable<int>(prixAchat);
    map['prix_vente'] = Variable<int>(prixVente);
    map['quantite'] = Variable<double>(quantite);
    map['unite'] = Variable<String>(unite);
    map['seuil_alerte'] = Variable<double>(seuilAlerte);
    if (!nullToAbsent || photoLocale != null) {
      map['photo_locale'] = Variable<String>(photoLocale);
    }
    if (!nullToAbsent || codeBarre != null) {
      map['code_barre'] = Variable<String>(codeBarre);
    }
    return map;
  }

  ProduitsCompanion toCompanion(bool nullToAbsent) {
    return ProduitsCompanion(
      id: Value(id),
      majLe: Value(majLe),
      supprimeLe: supprimeLe == null && nullToAbsent
          ? const Value.absent()
          : Value(supprimeLe),
      synchro: Value(synchro),
      appareilId: Value(appareilId),
      categorieId: categorieId == null && nullToAbsent
          ? const Value.absent()
          : Value(categorieId),
      nom: Value(nom),
      prixAchat: Value(prixAchat),
      prixVente: Value(prixVente),
      quantite: Value(quantite),
      unite: Value(unite),
      seuilAlerte: Value(seuilAlerte),
      photoLocale: photoLocale == null && nullToAbsent
          ? const Value.absent()
          : Value(photoLocale),
      codeBarre: codeBarre == null && nullToAbsent
          ? const Value.absent()
          : Value(codeBarre),
    );
  }

  factory Produit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Produit(
      id: serializer.fromJson<String>(json['id']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
      supprimeLe: serializer.fromJson<DateTime?>(json['supprimeLe']),
      synchro: serializer.fromJson<bool>(json['synchro']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      categorieId: serializer.fromJson<String?>(json['categorieId']),
      nom: serializer.fromJson<String>(json['nom']),
      prixAchat: serializer.fromJson<int>(json['prixAchat']),
      prixVente: serializer.fromJson<int>(json['prixVente']),
      quantite: serializer.fromJson<double>(json['quantite']),
      unite: serializer.fromJson<String>(json['unite']),
      seuilAlerte: serializer.fromJson<double>(json['seuilAlerte']),
      photoLocale: serializer.fromJson<String?>(json['photoLocale']),
      codeBarre: serializer.fromJson<String?>(json['codeBarre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'majLe': serializer.toJson<DateTime>(majLe),
      'supprimeLe': serializer.toJson<DateTime?>(supprimeLe),
      'synchro': serializer.toJson<bool>(synchro),
      'appareilId': serializer.toJson<String>(appareilId),
      'categorieId': serializer.toJson<String?>(categorieId),
      'nom': serializer.toJson<String>(nom),
      'prixAchat': serializer.toJson<int>(prixAchat),
      'prixVente': serializer.toJson<int>(prixVente),
      'quantite': serializer.toJson<double>(quantite),
      'unite': serializer.toJson<String>(unite),
      'seuilAlerte': serializer.toJson<double>(seuilAlerte),
      'photoLocale': serializer.toJson<String?>(photoLocale),
      'codeBarre': serializer.toJson<String?>(codeBarre),
    };
  }

  Produit copyWith({
    String? id,
    DateTime? majLe,
    Value<DateTime?> supprimeLe = const Value.absent(),
    bool? synchro,
    String? appareilId,
    Value<String?> categorieId = const Value.absent(),
    String? nom,
    int? prixAchat,
    int? prixVente,
    double? quantite,
    String? unite,
    double? seuilAlerte,
    Value<String?> photoLocale = const Value.absent(),
    Value<String?> codeBarre = const Value.absent(),
  }) => Produit(
    id: id ?? this.id,
    majLe: majLe ?? this.majLe,
    supprimeLe: supprimeLe.present ? supprimeLe.value : this.supprimeLe,
    synchro: synchro ?? this.synchro,
    appareilId: appareilId ?? this.appareilId,
    categorieId: categorieId.present ? categorieId.value : this.categorieId,
    nom: nom ?? this.nom,
    prixAchat: prixAchat ?? this.prixAchat,
    prixVente: prixVente ?? this.prixVente,
    quantite: quantite ?? this.quantite,
    unite: unite ?? this.unite,
    seuilAlerte: seuilAlerte ?? this.seuilAlerte,
    photoLocale: photoLocale.present ? photoLocale.value : this.photoLocale,
    codeBarre: codeBarre.present ? codeBarre.value : this.codeBarre,
  );
  Produit copyWithCompanion(ProduitsCompanion data) {
    return Produit(
      id: data.id.present ? data.id.value : this.id,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
      supprimeLe: data.supprimeLe.present
          ? data.supprimeLe.value
          : this.supprimeLe,
      synchro: data.synchro.present ? data.synchro.value : this.synchro,
      appareilId: data.appareilId.present
          ? data.appareilId.value
          : this.appareilId,
      categorieId: data.categorieId.present
          ? data.categorieId.value
          : this.categorieId,
      nom: data.nom.present ? data.nom.value : this.nom,
      prixAchat: data.prixAchat.present ? data.prixAchat.value : this.prixAchat,
      prixVente: data.prixVente.present ? data.prixVente.value : this.prixVente,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      unite: data.unite.present ? data.unite.value : this.unite,
      seuilAlerte: data.seuilAlerte.present
          ? data.seuilAlerte.value
          : this.seuilAlerte,
      photoLocale: data.photoLocale.present
          ? data.photoLocale.value
          : this.photoLocale,
      codeBarre: data.codeBarre.present ? data.codeBarre.value : this.codeBarre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Produit(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('categorieId: $categorieId, ')
          ..write('nom: $nom, ')
          ..write('prixAchat: $prixAchat, ')
          ..write('prixVente: $prixVente, ')
          ..write('quantite: $quantite, ')
          ..write('unite: $unite, ')
          ..write('seuilAlerte: $seuilAlerte, ')
          ..write('photoLocale: $photoLocale, ')
          ..write('codeBarre: $codeBarre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    categorieId,
    nom,
    prixAchat,
    prixVente,
    quantite,
    unite,
    seuilAlerte,
    photoLocale,
    codeBarre,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Produit &&
          other.id == this.id &&
          other.majLe == this.majLe &&
          other.supprimeLe == this.supprimeLe &&
          other.synchro == this.synchro &&
          other.appareilId == this.appareilId &&
          other.categorieId == this.categorieId &&
          other.nom == this.nom &&
          other.prixAchat == this.prixAchat &&
          other.prixVente == this.prixVente &&
          other.quantite == this.quantite &&
          other.unite == this.unite &&
          other.seuilAlerte == this.seuilAlerte &&
          other.photoLocale == this.photoLocale &&
          other.codeBarre == this.codeBarre);
}

class ProduitsCompanion extends UpdateCompanion<Produit> {
  final Value<String> id;
  final Value<DateTime> majLe;
  final Value<DateTime?> supprimeLe;
  final Value<bool> synchro;
  final Value<String> appareilId;
  final Value<String?> categorieId;
  final Value<String> nom;
  final Value<int> prixAchat;
  final Value<int> prixVente;
  final Value<double> quantite;
  final Value<String> unite;
  final Value<double> seuilAlerte;
  final Value<String?> photoLocale;
  final Value<String?> codeBarre;
  final Value<int> rowid;
  const ProduitsCompanion({
    this.id = const Value.absent(),
    this.majLe = const Value.absent(),
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.categorieId = const Value.absent(),
    this.nom = const Value.absent(),
    this.prixAchat = const Value.absent(),
    this.prixVente = const Value.absent(),
    this.quantite = const Value.absent(),
    this.unite = const Value.absent(),
    this.seuilAlerte = const Value.absent(),
    this.photoLocale = const Value.absent(),
    this.codeBarre = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProduitsCompanion.insert({
    required String id,
    required DateTime majLe,
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    required String appareilId,
    this.categorieId = const Value.absent(),
    required String nom,
    required int prixAchat,
    required int prixVente,
    this.quantite = const Value.absent(),
    required String unite,
    required double seuilAlerte,
    this.photoLocale = const Value.absent(),
    this.codeBarre = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       majLe = Value(majLe),
       appareilId = Value(appareilId),
       nom = Value(nom),
       prixAchat = Value(prixAchat),
       prixVente = Value(prixVente),
       unite = Value(unite),
       seuilAlerte = Value(seuilAlerte);
  static Insertable<Produit> custom({
    Expression<String>? id,
    Expression<DateTime>? majLe,
    Expression<DateTime>? supprimeLe,
    Expression<bool>? synchro,
    Expression<String>? appareilId,
    Expression<String>? categorieId,
    Expression<String>? nom,
    Expression<int>? prixAchat,
    Expression<int>? prixVente,
    Expression<double>? quantite,
    Expression<String>? unite,
    Expression<double>? seuilAlerte,
    Expression<String>? photoLocale,
    Expression<String>? codeBarre,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (majLe != null) 'maj_le': majLe,
      if (supprimeLe != null) 'supprime_le': supprimeLe,
      if (synchro != null) 'synchro': synchro,
      if (appareilId != null) 'appareil_id': appareilId,
      if (categorieId != null) 'categorie_id': categorieId,
      if (nom != null) 'nom': nom,
      if (prixAchat != null) 'prix_achat': prixAchat,
      if (prixVente != null) 'prix_vente': prixVente,
      if (quantite != null) 'quantite': quantite,
      if (unite != null) 'unite': unite,
      if (seuilAlerte != null) 'seuil_alerte': seuilAlerte,
      if (photoLocale != null) 'photo_locale': photoLocale,
      if (codeBarre != null) 'code_barre': codeBarre,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProduitsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? majLe,
    Value<DateTime?>? supprimeLe,
    Value<bool>? synchro,
    Value<String>? appareilId,
    Value<String?>? categorieId,
    Value<String>? nom,
    Value<int>? prixAchat,
    Value<int>? prixVente,
    Value<double>? quantite,
    Value<String>? unite,
    Value<double>? seuilAlerte,
    Value<String?>? photoLocale,
    Value<String?>? codeBarre,
    Value<int>? rowid,
  }) {
    return ProduitsCompanion(
      id: id ?? this.id,
      majLe: majLe ?? this.majLe,
      supprimeLe: supprimeLe ?? this.supprimeLe,
      synchro: synchro ?? this.synchro,
      appareilId: appareilId ?? this.appareilId,
      categorieId: categorieId ?? this.categorieId,
      nom: nom ?? this.nom,
      prixAchat: prixAchat ?? this.prixAchat,
      prixVente: prixVente ?? this.prixVente,
      quantite: quantite ?? this.quantite,
      unite: unite ?? this.unite,
      seuilAlerte: seuilAlerte ?? this.seuilAlerte,
      photoLocale: photoLocale ?? this.photoLocale,
      codeBarre: codeBarre ?? this.codeBarre,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    if (supprimeLe.present) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe.value);
    }
    if (synchro.present) {
      map['synchro'] = Variable<bool>(synchro.value);
    }
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (categorieId.present) {
      map['categorie_id'] = Variable<String>(categorieId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (prixAchat.present) {
      map['prix_achat'] = Variable<int>(prixAchat.value);
    }
    if (prixVente.present) {
      map['prix_vente'] = Variable<int>(prixVente.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<double>(quantite.value);
    }
    if (unite.present) {
      map['unite'] = Variable<String>(unite.value);
    }
    if (seuilAlerte.present) {
      map['seuil_alerte'] = Variable<double>(seuilAlerte.value);
    }
    if (photoLocale.present) {
      map['photo_locale'] = Variable<String>(photoLocale.value);
    }
    if (codeBarre.present) {
      map['code_barre'] = Variable<String>(codeBarre.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProduitsCompanion(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('categorieId: $categorieId, ')
          ..write('nom: $nom, ')
          ..write('prixAchat: $prixAchat, ')
          ..write('prixVente: $prixVente, ')
          ..write('quantite: $quantite, ')
          ..write('unite: $unite, ')
          ..write('seuilAlerte: $seuilAlerte, ')
          ..write('photoLocale: $photoLocale, ')
          ..write('codeBarre: $codeBarre, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supprimeLeMeta = const VerificationMeta(
    'supprimeLe',
  );
  @override
  late final GeneratedColumn<DateTime> supprimeLe = GeneratedColumn<DateTime>(
    'supprime_le',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchroMeta = const VerificationMeta(
    'synchro',
  );
  @override
  late final GeneratedColumn<bool> synchro = GeneratedColumn<bool>(
    'synchro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appareilIdMeta = const VerificationMeta(
    'appareilId',
  );
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
    'appareil_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telephoneMeta = const VerificationMeta(
    'telephone',
  );
  @override
  late final GeneratedColumn<String> telephone = GeneratedColumn<String>(
    'telephone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soldeDetteMeta = const VerificationMeta(
    'soldeDette',
  );
  @override
  late final GeneratedColumn<int> soldeDette = GeneratedColumn<int>(
    'solde_dette',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    nom,
    telephone,
    soldeDette,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Client> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('maj_le')) {
      context.handle(
        _majLeMeta,
        majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta),
      );
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    if (data.containsKey('supprime_le')) {
      context.handle(
        _supprimeLeMeta,
        supprimeLe.isAcceptableOrUnknown(data['supprime_le']!, _supprimeLeMeta),
      );
    }
    if (data.containsKey('synchro')) {
      context.handle(
        _synchroMeta,
        synchro.isAcceptableOrUnknown(data['synchro']!, _synchroMeta),
      );
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
        _appareilIdMeta,
        appareilId.isAcceptableOrUnknown(data['appareil_id']!, _appareilIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('telephone')) {
      context.handle(
        _telephoneMeta,
        telephone.isAcceptableOrUnknown(data['telephone']!, _telephoneMeta),
      );
    }
    if (data.containsKey('solde_dette')) {
      context.handle(
        _soldeDetteMeta,
        soldeDette.isAcceptableOrUnknown(data['solde_dette']!, _soldeDetteMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      majLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maj_le'],
      )!,
      supprimeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}supprime_le'],
      ),
      synchro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchro'],
      )!,
      appareilId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appareil_id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      telephone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telephone'],
      ),
      soldeDette: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}solde_dette'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final String id;
  final DateTime majLe;
  final DateTime? supprimeLe;
  final bool synchro;
  final String appareilId;
  final String nom;
  final String? telephone;

  /// Ce que le client doit encore, toujours recalculé :
  /// ventes à crédit (reste à payer) − versements.
  final int soldeDette;
  final String? note;
  const Client({
    required this.id,
    required this.majLe,
    this.supprimeLe,
    required this.synchro,
    required this.appareilId,
    required this.nom,
    this.telephone,
    required this.soldeDette,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maj_le'] = Variable<DateTime>(majLe);
    if (!nullToAbsent || supprimeLe != null) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe);
    }
    map['synchro'] = Variable<bool>(synchro);
    map['appareil_id'] = Variable<String>(appareilId);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || telephone != null) {
      map['telephone'] = Variable<String>(telephone);
    }
    map['solde_dette'] = Variable<int>(soldeDette);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      majLe: Value(majLe),
      supprimeLe: supprimeLe == null && nullToAbsent
          ? const Value.absent()
          : Value(supprimeLe),
      synchro: Value(synchro),
      appareilId: Value(appareilId),
      nom: Value(nom),
      telephone: telephone == null && nullToAbsent
          ? const Value.absent()
          : Value(telephone),
      soldeDette: Value(soldeDette),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Client.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<String>(json['id']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
      supprimeLe: serializer.fromJson<DateTime?>(json['supprimeLe']),
      synchro: serializer.fromJson<bool>(json['synchro']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      nom: serializer.fromJson<String>(json['nom']),
      telephone: serializer.fromJson<String?>(json['telephone']),
      soldeDette: serializer.fromJson<int>(json['soldeDette']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'majLe': serializer.toJson<DateTime>(majLe),
      'supprimeLe': serializer.toJson<DateTime?>(supprimeLe),
      'synchro': serializer.toJson<bool>(synchro),
      'appareilId': serializer.toJson<String>(appareilId),
      'nom': serializer.toJson<String>(nom),
      'telephone': serializer.toJson<String?>(telephone),
      'soldeDette': serializer.toJson<int>(soldeDette),
      'note': serializer.toJson<String?>(note),
    };
  }

  Client copyWith({
    String? id,
    DateTime? majLe,
    Value<DateTime?> supprimeLe = const Value.absent(),
    bool? synchro,
    String? appareilId,
    String? nom,
    Value<String?> telephone = const Value.absent(),
    int? soldeDette,
    Value<String?> note = const Value.absent(),
  }) => Client(
    id: id ?? this.id,
    majLe: majLe ?? this.majLe,
    supprimeLe: supprimeLe.present ? supprimeLe.value : this.supprimeLe,
    synchro: synchro ?? this.synchro,
    appareilId: appareilId ?? this.appareilId,
    nom: nom ?? this.nom,
    telephone: telephone.present ? telephone.value : this.telephone,
    soldeDette: soldeDette ?? this.soldeDette,
    note: note.present ? note.value : this.note,
  );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
      supprimeLe: data.supprimeLe.present
          ? data.supprimeLe.value
          : this.supprimeLe,
      synchro: data.synchro.present ? data.synchro.value : this.synchro,
      appareilId: data.appareilId.present
          ? data.appareilId.value
          : this.appareilId,
      nom: data.nom.present ? data.nom.value : this.nom,
      telephone: data.telephone.present ? data.telephone.value : this.telephone,
      soldeDette: data.soldeDette.present
          ? data.soldeDette.value
          : this.soldeDette,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('nom: $nom, ')
          ..write('telephone: $telephone, ')
          ..write('soldeDette: $soldeDette, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    nom,
    telephone,
    soldeDette,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.majLe == this.majLe &&
          other.supprimeLe == this.supprimeLe &&
          other.synchro == this.synchro &&
          other.appareilId == this.appareilId &&
          other.nom == this.nom &&
          other.telephone == this.telephone &&
          other.soldeDette == this.soldeDette &&
          other.note == this.note);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<String> id;
  final Value<DateTime> majLe;
  final Value<DateTime?> supprimeLe;
  final Value<bool> synchro;
  final Value<String> appareilId;
  final Value<String> nom;
  final Value<String?> telephone;
  final Value<int> soldeDette;
  final Value<String?> note;
  final Value<int> rowid;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.majLe = const Value.absent(),
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.nom = const Value.absent(),
    this.telephone = const Value.absent(),
    this.soldeDette = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsCompanion.insert({
    required String id,
    required DateTime majLe,
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    required String appareilId,
    required String nom,
    this.telephone = const Value.absent(),
    this.soldeDette = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       majLe = Value(majLe),
       appareilId = Value(appareilId),
       nom = Value(nom);
  static Insertable<Client> custom({
    Expression<String>? id,
    Expression<DateTime>? majLe,
    Expression<DateTime>? supprimeLe,
    Expression<bool>? synchro,
    Expression<String>? appareilId,
    Expression<String>? nom,
    Expression<String>? telephone,
    Expression<int>? soldeDette,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (majLe != null) 'maj_le': majLe,
      if (supprimeLe != null) 'supprime_le': supprimeLe,
      if (synchro != null) 'synchro': synchro,
      if (appareilId != null) 'appareil_id': appareilId,
      if (nom != null) 'nom': nom,
      if (telephone != null) 'telephone': telephone,
      if (soldeDette != null) 'solde_dette': soldeDette,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? majLe,
    Value<DateTime?>? supprimeLe,
    Value<bool>? synchro,
    Value<String>? appareilId,
    Value<String>? nom,
    Value<String?>? telephone,
    Value<int>? soldeDette,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      majLe: majLe ?? this.majLe,
      supprimeLe: supprimeLe ?? this.supprimeLe,
      synchro: synchro ?? this.synchro,
      appareilId: appareilId ?? this.appareilId,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      soldeDette: soldeDette ?? this.soldeDette,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    if (supprimeLe.present) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe.value);
    }
    if (synchro.present) {
      map['synchro'] = Variable<bool>(synchro.value);
    }
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (telephone.present) {
      map['telephone'] = Variable<String>(telephone.value);
    }
    if (soldeDette.present) {
      map['solde_dette'] = Variable<int>(soldeDette.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('nom: $nom, ')
          ..write('telephone: $telephone, ')
          ..write('soldeDette: $soldeDette, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VentesTable extends Ventes with TableInfo<$VentesTable, Vente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supprimeLeMeta = const VerificationMeta(
    'supprimeLe',
  );
  @override
  late final GeneratedColumn<DateTime> supprimeLe = GeneratedColumn<DateTime>(
    'supprime_le',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchroMeta = const VerificationMeta(
    'synchro',
  );
  @override
  late final GeneratedColumn<bool> synchro = GeneratedColumn<bool>(
    'synchro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appareilIdMeta = const VerificationMeta(
    'appareilId',
  );
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
    'appareil_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<int> numero = GeneratedColumn<int>(
    'numero',
    aliasedName,
    false,
    check: () => ComparableExpr(numero).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _utilisateurIdMeta = const VerificationMeta(
    'utilisateurId',
  );
  @override
  late final GeneratedColumn<String> utilisateurId = GeneratedColumn<String>(
    'utilisateur_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES utilisateurs (id)',
    ),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    check: () => ComparableExpr(total).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montantPayeMeta = const VerificationMeta(
    'montantPaye',
  );
  @override
  late final GeneratedColumn<int> montantPaye = GeneratedColumn<int>(
    'montant_paye',
    aliasedName,
    false,
    check: () => ComparableExpr(montantPaye).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resteAPayerMeta = const VerificationMeta(
    'resteAPayer',
  );
  @override
  late final GeneratedColumn<int> resteAPayer = GeneratedColumn<int>(
    'reste_a_payer',
    aliasedName,
    false,
    check: () => ComparableExpr(resteAPayer).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modePaiementMeta = const VerificationMeta(
    'modePaiement',
  );
  @override
  late final GeneratedColumn<String> modePaiement = GeneratedColumn<String>(
    'mode_paiement',
    aliasedName,
    false,
    check: () => modePaiement.isIn(ModePaiement.pourVente),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beneficeMeta = const VerificationMeta(
    'benefice',
  );
  @override
  late final GeneratedColumn<int> benefice = GeneratedColumn<int>(
    'benefice',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateVenteMeta = const VerificationMeta(
    'dateVente',
  );
  @override
  late final GeneratedColumn<DateTime> dateVente = GeneratedColumn<DateTime>(
    'date_vente',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annuleeMeta = const VerificationMeta(
    'annulee',
  );
  @override
  late final GeneratedColumn<bool> annulee = GeneratedColumn<bool>(
    'annulee',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("annulee" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    numero,
    clientId,
    utilisateurId,
    total,
    montantPaye,
    resteAPayer,
    modePaiement,
    benefice,
    dateVente,
    annulee,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('maj_le')) {
      context.handle(
        _majLeMeta,
        majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta),
      );
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    if (data.containsKey('supprime_le')) {
      context.handle(
        _supprimeLeMeta,
        supprimeLe.isAcceptableOrUnknown(data['supprime_le']!, _supprimeLeMeta),
      );
    }
    if (data.containsKey('synchro')) {
      context.handle(
        _synchroMeta,
        synchro.isAcceptableOrUnknown(data['synchro']!, _synchroMeta),
      );
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
        _appareilIdMeta,
        appareilId.isAcceptableOrUnknown(data['appareil_id']!, _appareilIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('utilisateur_id')) {
      context.handle(
        _utilisateurIdMeta,
        utilisateurId.isAcceptableOrUnknown(
          data['utilisateur_id']!,
          _utilisateurIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utilisateurIdMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('montant_paye')) {
      context.handle(
        _montantPayeMeta,
        montantPaye.isAcceptableOrUnknown(
          data['montant_paye']!,
          _montantPayeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montantPayeMeta);
    }
    if (data.containsKey('reste_a_payer')) {
      context.handle(
        _resteAPayerMeta,
        resteAPayer.isAcceptableOrUnknown(
          data['reste_a_payer']!,
          _resteAPayerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resteAPayerMeta);
    }
    if (data.containsKey('mode_paiement')) {
      context.handle(
        _modePaiementMeta,
        modePaiement.isAcceptableOrUnknown(
          data['mode_paiement']!,
          _modePaiementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modePaiementMeta);
    }
    if (data.containsKey('benefice')) {
      context.handle(
        _beneficeMeta,
        benefice.isAcceptableOrUnknown(data['benefice']!, _beneficeMeta),
      );
    } else if (isInserting) {
      context.missing(_beneficeMeta);
    }
    if (data.containsKey('date_vente')) {
      context.handle(
        _dateVenteMeta,
        dateVente.isAcceptableOrUnknown(data['date_vente']!, _dateVenteMeta),
      );
    } else if (isInserting) {
      context.missing(_dateVenteMeta);
    }
    if (data.containsKey('annulee')) {
      context.handle(
        _annuleeMeta,
        annulee.isAcceptableOrUnknown(data['annulee']!, _annuleeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      majLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maj_le'],
      )!,
      supprimeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}supprime_le'],
      ),
      synchro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchro'],
      )!,
      appareilId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appareil_id'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      utilisateurId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utilisateur_id'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      montantPaye: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}montant_paye'],
      )!,
      resteAPayer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reste_a_payer'],
      )!,
      modePaiement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode_paiement'],
      )!,
      benefice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}benefice'],
      )!,
      dateVente: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_vente'],
      )!,
      annulee: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}annulee'],
      )!,
    );
  }

  @override
  $VentesTable createAlias(String alias) {
    return $VentesTable(attachedDatabase, alias);
  }
}

class Vente extends DataClass implements Insertable<Vente> {
  final String id;
  final DateTime majLe;
  final DateTime? supprimeLe;
  final bool synchro;
  final String appareilId;

  /// Numéro lisible : n° de la vente dans la journée.
  final int numero;
  final String? clientId;
  final String utilisateurId;
  final int total;
  final int montantPaye;
  final int resteAPayer;
  final String modePaiement;
  final int benefice;
  final DateTime dateVente;
  final bool annulee;
  const Vente({
    required this.id,
    required this.majLe,
    this.supprimeLe,
    required this.synchro,
    required this.appareilId,
    required this.numero,
    this.clientId,
    required this.utilisateurId,
    required this.total,
    required this.montantPaye,
    required this.resteAPayer,
    required this.modePaiement,
    required this.benefice,
    required this.dateVente,
    required this.annulee,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maj_le'] = Variable<DateTime>(majLe);
    if (!nullToAbsent || supprimeLe != null) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe);
    }
    map['synchro'] = Variable<bool>(synchro);
    map['appareil_id'] = Variable<String>(appareilId);
    map['numero'] = Variable<int>(numero);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['utilisateur_id'] = Variable<String>(utilisateurId);
    map['total'] = Variable<int>(total);
    map['montant_paye'] = Variable<int>(montantPaye);
    map['reste_a_payer'] = Variable<int>(resteAPayer);
    map['mode_paiement'] = Variable<String>(modePaiement);
    map['benefice'] = Variable<int>(benefice);
    map['date_vente'] = Variable<DateTime>(dateVente);
    map['annulee'] = Variable<bool>(annulee);
    return map;
  }

  VentesCompanion toCompanion(bool nullToAbsent) {
    return VentesCompanion(
      id: Value(id),
      majLe: Value(majLe),
      supprimeLe: supprimeLe == null && nullToAbsent
          ? const Value.absent()
          : Value(supprimeLe),
      synchro: Value(synchro),
      appareilId: Value(appareilId),
      numero: Value(numero),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      utilisateurId: Value(utilisateurId),
      total: Value(total),
      montantPaye: Value(montantPaye),
      resteAPayer: Value(resteAPayer),
      modePaiement: Value(modePaiement),
      benefice: Value(benefice),
      dateVente: Value(dateVente),
      annulee: Value(annulee),
    );
  }

  factory Vente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vente(
      id: serializer.fromJson<String>(json['id']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
      supprimeLe: serializer.fromJson<DateTime?>(json['supprimeLe']),
      synchro: serializer.fromJson<bool>(json['synchro']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      numero: serializer.fromJson<int>(json['numero']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      utilisateurId: serializer.fromJson<String>(json['utilisateurId']),
      total: serializer.fromJson<int>(json['total']),
      montantPaye: serializer.fromJson<int>(json['montantPaye']),
      resteAPayer: serializer.fromJson<int>(json['resteAPayer']),
      modePaiement: serializer.fromJson<String>(json['modePaiement']),
      benefice: serializer.fromJson<int>(json['benefice']),
      dateVente: serializer.fromJson<DateTime>(json['dateVente']),
      annulee: serializer.fromJson<bool>(json['annulee']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'majLe': serializer.toJson<DateTime>(majLe),
      'supprimeLe': serializer.toJson<DateTime?>(supprimeLe),
      'synchro': serializer.toJson<bool>(synchro),
      'appareilId': serializer.toJson<String>(appareilId),
      'numero': serializer.toJson<int>(numero),
      'clientId': serializer.toJson<String?>(clientId),
      'utilisateurId': serializer.toJson<String>(utilisateurId),
      'total': serializer.toJson<int>(total),
      'montantPaye': serializer.toJson<int>(montantPaye),
      'resteAPayer': serializer.toJson<int>(resteAPayer),
      'modePaiement': serializer.toJson<String>(modePaiement),
      'benefice': serializer.toJson<int>(benefice),
      'dateVente': serializer.toJson<DateTime>(dateVente),
      'annulee': serializer.toJson<bool>(annulee),
    };
  }

  Vente copyWith({
    String? id,
    DateTime? majLe,
    Value<DateTime?> supprimeLe = const Value.absent(),
    bool? synchro,
    String? appareilId,
    int? numero,
    Value<String?> clientId = const Value.absent(),
    String? utilisateurId,
    int? total,
    int? montantPaye,
    int? resteAPayer,
    String? modePaiement,
    int? benefice,
    DateTime? dateVente,
    bool? annulee,
  }) => Vente(
    id: id ?? this.id,
    majLe: majLe ?? this.majLe,
    supprimeLe: supprimeLe.present ? supprimeLe.value : this.supprimeLe,
    synchro: synchro ?? this.synchro,
    appareilId: appareilId ?? this.appareilId,
    numero: numero ?? this.numero,
    clientId: clientId.present ? clientId.value : this.clientId,
    utilisateurId: utilisateurId ?? this.utilisateurId,
    total: total ?? this.total,
    montantPaye: montantPaye ?? this.montantPaye,
    resteAPayer: resteAPayer ?? this.resteAPayer,
    modePaiement: modePaiement ?? this.modePaiement,
    benefice: benefice ?? this.benefice,
    dateVente: dateVente ?? this.dateVente,
    annulee: annulee ?? this.annulee,
  );
  Vente copyWithCompanion(VentesCompanion data) {
    return Vente(
      id: data.id.present ? data.id.value : this.id,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
      supprimeLe: data.supprimeLe.present
          ? data.supprimeLe.value
          : this.supprimeLe,
      synchro: data.synchro.present ? data.synchro.value : this.synchro,
      appareilId: data.appareilId.present
          ? data.appareilId.value
          : this.appareilId,
      numero: data.numero.present ? data.numero.value : this.numero,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      utilisateurId: data.utilisateurId.present
          ? data.utilisateurId.value
          : this.utilisateurId,
      total: data.total.present ? data.total.value : this.total,
      montantPaye: data.montantPaye.present
          ? data.montantPaye.value
          : this.montantPaye,
      resteAPayer: data.resteAPayer.present
          ? data.resteAPayer.value
          : this.resteAPayer,
      modePaiement: data.modePaiement.present
          ? data.modePaiement.value
          : this.modePaiement,
      benefice: data.benefice.present ? data.benefice.value : this.benefice,
      dateVente: data.dateVente.present ? data.dateVente.value : this.dateVente,
      annulee: data.annulee.present ? data.annulee.value : this.annulee,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vente(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('numero: $numero, ')
          ..write('clientId: $clientId, ')
          ..write('utilisateurId: $utilisateurId, ')
          ..write('total: $total, ')
          ..write('montantPaye: $montantPaye, ')
          ..write('resteAPayer: $resteAPayer, ')
          ..write('modePaiement: $modePaiement, ')
          ..write('benefice: $benefice, ')
          ..write('dateVente: $dateVente, ')
          ..write('annulee: $annulee')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    numero,
    clientId,
    utilisateurId,
    total,
    montantPaye,
    resteAPayer,
    modePaiement,
    benefice,
    dateVente,
    annulee,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vente &&
          other.id == this.id &&
          other.majLe == this.majLe &&
          other.supprimeLe == this.supprimeLe &&
          other.synchro == this.synchro &&
          other.appareilId == this.appareilId &&
          other.numero == this.numero &&
          other.clientId == this.clientId &&
          other.utilisateurId == this.utilisateurId &&
          other.total == this.total &&
          other.montantPaye == this.montantPaye &&
          other.resteAPayer == this.resteAPayer &&
          other.modePaiement == this.modePaiement &&
          other.benefice == this.benefice &&
          other.dateVente == this.dateVente &&
          other.annulee == this.annulee);
}

class VentesCompanion extends UpdateCompanion<Vente> {
  final Value<String> id;
  final Value<DateTime> majLe;
  final Value<DateTime?> supprimeLe;
  final Value<bool> synchro;
  final Value<String> appareilId;
  final Value<int> numero;
  final Value<String?> clientId;
  final Value<String> utilisateurId;
  final Value<int> total;
  final Value<int> montantPaye;
  final Value<int> resteAPayer;
  final Value<String> modePaiement;
  final Value<int> benefice;
  final Value<DateTime> dateVente;
  final Value<bool> annulee;
  final Value<int> rowid;
  const VentesCompanion({
    this.id = const Value.absent(),
    this.majLe = const Value.absent(),
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.numero = const Value.absent(),
    this.clientId = const Value.absent(),
    this.utilisateurId = const Value.absent(),
    this.total = const Value.absent(),
    this.montantPaye = const Value.absent(),
    this.resteAPayer = const Value.absent(),
    this.modePaiement = const Value.absent(),
    this.benefice = const Value.absent(),
    this.dateVente = const Value.absent(),
    this.annulee = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VentesCompanion.insert({
    required String id,
    required DateTime majLe,
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    required String appareilId,
    required int numero,
    this.clientId = const Value.absent(),
    required String utilisateurId,
    required int total,
    required int montantPaye,
    required int resteAPayer,
    required String modePaiement,
    required int benefice,
    required DateTime dateVente,
    this.annulee = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       majLe = Value(majLe),
       appareilId = Value(appareilId),
       numero = Value(numero),
       utilisateurId = Value(utilisateurId),
       total = Value(total),
       montantPaye = Value(montantPaye),
       resteAPayer = Value(resteAPayer),
       modePaiement = Value(modePaiement),
       benefice = Value(benefice),
       dateVente = Value(dateVente);
  static Insertable<Vente> custom({
    Expression<String>? id,
    Expression<DateTime>? majLe,
    Expression<DateTime>? supprimeLe,
    Expression<bool>? synchro,
    Expression<String>? appareilId,
    Expression<int>? numero,
    Expression<String>? clientId,
    Expression<String>? utilisateurId,
    Expression<int>? total,
    Expression<int>? montantPaye,
    Expression<int>? resteAPayer,
    Expression<String>? modePaiement,
    Expression<int>? benefice,
    Expression<DateTime>? dateVente,
    Expression<bool>? annulee,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (majLe != null) 'maj_le': majLe,
      if (supprimeLe != null) 'supprime_le': supprimeLe,
      if (synchro != null) 'synchro': synchro,
      if (appareilId != null) 'appareil_id': appareilId,
      if (numero != null) 'numero': numero,
      if (clientId != null) 'client_id': clientId,
      if (utilisateurId != null) 'utilisateur_id': utilisateurId,
      if (total != null) 'total': total,
      if (montantPaye != null) 'montant_paye': montantPaye,
      if (resteAPayer != null) 'reste_a_payer': resteAPayer,
      if (modePaiement != null) 'mode_paiement': modePaiement,
      if (benefice != null) 'benefice': benefice,
      if (dateVente != null) 'date_vente': dateVente,
      if (annulee != null) 'annulee': annulee,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VentesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? majLe,
    Value<DateTime?>? supprimeLe,
    Value<bool>? synchro,
    Value<String>? appareilId,
    Value<int>? numero,
    Value<String?>? clientId,
    Value<String>? utilisateurId,
    Value<int>? total,
    Value<int>? montantPaye,
    Value<int>? resteAPayer,
    Value<String>? modePaiement,
    Value<int>? benefice,
    Value<DateTime>? dateVente,
    Value<bool>? annulee,
    Value<int>? rowid,
  }) {
    return VentesCompanion(
      id: id ?? this.id,
      majLe: majLe ?? this.majLe,
      supprimeLe: supprimeLe ?? this.supprimeLe,
      synchro: synchro ?? this.synchro,
      appareilId: appareilId ?? this.appareilId,
      numero: numero ?? this.numero,
      clientId: clientId ?? this.clientId,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      total: total ?? this.total,
      montantPaye: montantPaye ?? this.montantPaye,
      resteAPayer: resteAPayer ?? this.resteAPayer,
      modePaiement: modePaiement ?? this.modePaiement,
      benefice: benefice ?? this.benefice,
      dateVente: dateVente ?? this.dateVente,
      annulee: annulee ?? this.annulee,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    if (supprimeLe.present) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe.value);
    }
    if (synchro.present) {
      map['synchro'] = Variable<bool>(synchro.value);
    }
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (numero.present) {
      map['numero'] = Variable<int>(numero.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (utilisateurId.present) {
      map['utilisateur_id'] = Variable<String>(utilisateurId.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (montantPaye.present) {
      map['montant_paye'] = Variable<int>(montantPaye.value);
    }
    if (resteAPayer.present) {
      map['reste_a_payer'] = Variable<int>(resteAPayer.value);
    }
    if (modePaiement.present) {
      map['mode_paiement'] = Variable<String>(modePaiement.value);
    }
    if (benefice.present) {
      map['benefice'] = Variable<int>(benefice.value);
    }
    if (dateVente.present) {
      map['date_vente'] = Variable<DateTime>(dateVente.value);
    }
    if (annulee.present) {
      map['annulee'] = Variable<bool>(annulee.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentesCompanion(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('numero: $numero, ')
          ..write('clientId: $clientId, ')
          ..write('utilisateurId: $utilisateurId, ')
          ..write('total: $total, ')
          ..write('montantPaye: $montantPaye, ')
          ..write('resteAPayer: $resteAPayer, ')
          ..write('modePaiement: $modePaiement, ')
          ..write('benefice: $benefice, ')
          ..write('dateVente: $dateVente, ')
          ..write('annulee: $annulee, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LignesVenteTable extends LignesVente
    with TableInfo<$LignesVenteTable, LigneVente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LignesVenteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supprimeLeMeta = const VerificationMeta(
    'supprimeLe',
  );
  @override
  late final GeneratedColumn<DateTime> supprimeLe = GeneratedColumn<DateTime>(
    'supprime_le',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchroMeta = const VerificationMeta(
    'synchro',
  );
  @override
  late final GeneratedColumn<bool> synchro = GeneratedColumn<bool>(
    'synchro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appareilIdMeta = const VerificationMeta(
    'appareilId',
  );
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
    'appareil_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _venteIdMeta = const VerificationMeta(
    'venteId',
  );
  @override
  late final GeneratedColumn<String> venteId = GeneratedColumn<String>(
    'vente_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ventes (id)',
    ),
  );
  static const VerificationMeta _produitIdMeta = const VerificationMeta(
    'produitId',
  );
  @override
  late final GeneratedColumn<String> produitId = GeneratedColumn<String>(
    'produit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produits (id)',
    ),
  );
  static const VerificationMeta _nomProduitMeta = const VerificationMeta(
    'nomProduit',
  );
  @override
  late final GeneratedColumn<String> nomProduit = GeneratedColumn<String>(
    'nom_produit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantiteMeta = const VerificationMeta(
    'quantite',
  );
  @override
  late final GeneratedColumn<double> quantite = GeneratedColumn<double>(
    'quantite',
    aliasedName,
    false,
    check: () => ComparableExpr(quantite).isBiggerThanValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prixUnitaireMeta = const VerificationMeta(
    'prixUnitaire',
  );
  @override
  late final GeneratedColumn<int> prixUnitaire = GeneratedColumn<int>(
    'prix_unitaire',
    aliasedName,
    false,
    check: () => ComparableExpr(prixUnitaire).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prixAchatUnitaireMeta = const VerificationMeta(
    'prixAchatUnitaire',
  );
  @override
  late final GeneratedColumn<int> prixAchatUnitaire = GeneratedColumn<int>(
    'prix_achat_unitaire',
    aliasedName,
    false,
    check: () => ComparableExpr(prixAchatUnitaire).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    venteId,
    produitId,
    nomProduit,
    quantite,
    prixUnitaire,
    prixAchatUnitaire,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lignes_vente';
  @override
  VerificationContext validateIntegrity(
    Insertable<LigneVente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('maj_le')) {
      context.handle(
        _majLeMeta,
        majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta),
      );
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    if (data.containsKey('supprime_le')) {
      context.handle(
        _supprimeLeMeta,
        supprimeLe.isAcceptableOrUnknown(data['supprime_le']!, _supprimeLeMeta),
      );
    }
    if (data.containsKey('synchro')) {
      context.handle(
        _synchroMeta,
        synchro.isAcceptableOrUnknown(data['synchro']!, _synchroMeta),
      );
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
        _appareilIdMeta,
        appareilId.isAcceptableOrUnknown(data['appareil_id']!, _appareilIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('vente_id')) {
      context.handle(
        _venteIdMeta,
        venteId.isAcceptableOrUnknown(data['vente_id']!, _venteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_venteIdMeta);
    }
    if (data.containsKey('produit_id')) {
      context.handle(
        _produitIdMeta,
        produitId.isAcceptableOrUnknown(data['produit_id']!, _produitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_produitIdMeta);
    }
    if (data.containsKey('nom_produit')) {
      context.handle(
        _nomProduitMeta,
        nomProduit.isAcceptableOrUnknown(data['nom_produit']!, _nomProduitMeta),
      );
    } else if (isInserting) {
      context.missing(_nomProduitMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(
        _quantiteMeta,
        quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta),
      );
    } else if (isInserting) {
      context.missing(_quantiteMeta);
    }
    if (data.containsKey('prix_unitaire')) {
      context.handle(
        _prixUnitaireMeta,
        prixUnitaire.isAcceptableOrUnknown(
          data['prix_unitaire']!,
          _prixUnitaireMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prixUnitaireMeta);
    }
    if (data.containsKey('prix_achat_unitaire')) {
      context.handle(
        _prixAchatUnitaireMeta,
        prixAchatUnitaire.isAcceptableOrUnknown(
          data['prix_achat_unitaire']!,
          _prixAchatUnitaireMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prixAchatUnitaireMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LigneVente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LigneVente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      majLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maj_le'],
      )!,
      supprimeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}supprime_le'],
      ),
      synchro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchro'],
      )!,
      appareilId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appareil_id'],
      )!,
      venteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vente_id'],
      )!,
      produitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}produit_id'],
      )!,
      nomProduit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom_produit'],
      )!,
      quantite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantite'],
      )!,
      prixUnitaire: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prix_unitaire'],
      )!,
      prixAchatUnitaire: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prix_achat_unitaire'],
      )!,
    );
  }

  @override
  $LignesVenteTable createAlias(String alias) {
    return $LignesVenteTable(attachedDatabase, alias);
  }
}

class LigneVente extends DataClass implements Insertable<LigneVente> {
  final String id;
  final DateTime majLe;
  final DateTime? supprimeLe;
  final bool synchro;
  final String appareilId;
  final String venteId;
  final String produitId;

  /// Copie du nom au moment de la vente.
  final String nomProduit;
  final double quantite;

  /// Copie du prix de vente appliqué.
  final int prixUnitaire;

  /// Copie du coût d'achat, pour le bénéfice.
  final int prixAchatUnitaire;
  const LigneVente({
    required this.id,
    required this.majLe,
    this.supprimeLe,
    required this.synchro,
    required this.appareilId,
    required this.venteId,
    required this.produitId,
    required this.nomProduit,
    required this.quantite,
    required this.prixUnitaire,
    required this.prixAchatUnitaire,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maj_le'] = Variable<DateTime>(majLe);
    if (!nullToAbsent || supprimeLe != null) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe);
    }
    map['synchro'] = Variable<bool>(synchro);
    map['appareil_id'] = Variable<String>(appareilId);
    map['vente_id'] = Variable<String>(venteId);
    map['produit_id'] = Variable<String>(produitId);
    map['nom_produit'] = Variable<String>(nomProduit);
    map['quantite'] = Variable<double>(quantite);
    map['prix_unitaire'] = Variable<int>(prixUnitaire);
    map['prix_achat_unitaire'] = Variable<int>(prixAchatUnitaire);
    return map;
  }

  LignesVenteCompanion toCompanion(bool nullToAbsent) {
    return LignesVenteCompanion(
      id: Value(id),
      majLe: Value(majLe),
      supprimeLe: supprimeLe == null && nullToAbsent
          ? const Value.absent()
          : Value(supprimeLe),
      synchro: Value(synchro),
      appareilId: Value(appareilId),
      venteId: Value(venteId),
      produitId: Value(produitId),
      nomProduit: Value(nomProduit),
      quantite: Value(quantite),
      prixUnitaire: Value(prixUnitaire),
      prixAchatUnitaire: Value(prixAchatUnitaire),
    );
  }

  factory LigneVente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LigneVente(
      id: serializer.fromJson<String>(json['id']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
      supprimeLe: serializer.fromJson<DateTime?>(json['supprimeLe']),
      synchro: serializer.fromJson<bool>(json['synchro']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      venteId: serializer.fromJson<String>(json['venteId']),
      produitId: serializer.fromJson<String>(json['produitId']),
      nomProduit: serializer.fromJson<String>(json['nomProduit']),
      quantite: serializer.fromJson<double>(json['quantite']),
      prixUnitaire: serializer.fromJson<int>(json['prixUnitaire']),
      prixAchatUnitaire: serializer.fromJson<int>(json['prixAchatUnitaire']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'majLe': serializer.toJson<DateTime>(majLe),
      'supprimeLe': serializer.toJson<DateTime?>(supprimeLe),
      'synchro': serializer.toJson<bool>(synchro),
      'appareilId': serializer.toJson<String>(appareilId),
      'venteId': serializer.toJson<String>(venteId),
      'produitId': serializer.toJson<String>(produitId),
      'nomProduit': serializer.toJson<String>(nomProduit),
      'quantite': serializer.toJson<double>(quantite),
      'prixUnitaire': serializer.toJson<int>(prixUnitaire),
      'prixAchatUnitaire': serializer.toJson<int>(prixAchatUnitaire),
    };
  }

  LigneVente copyWith({
    String? id,
    DateTime? majLe,
    Value<DateTime?> supprimeLe = const Value.absent(),
    bool? synchro,
    String? appareilId,
    String? venteId,
    String? produitId,
    String? nomProduit,
    double? quantite,
    int? prixUnitaire,
    int? prixAchatUnitaire,
  }) => LigneVente(
    id: id ?? this.id,
    majLe: majLe ?? this.majLe,
    supprimeLe: supprimeLe.present ? supprimeLe.value : this.supprimeLe,
    synchro: synchro ?? this.synchro,
    appareilId: appareilId ?? this.appareilId,
    venteId: venteId ?? this.venteId,
    produitId: produitId ?? this.produitId,
    nomProduit: nomProduit ?? this.nomProduit,
    quantite: quantite ?? this.quantite,
    prixUnitaire: prixUnitaire ?? this.prixUnitaire,
    prixAchatUnitaire: prixAchatUnitaire ?? this.prixAchatUnitaire,
  );
  LigneVente copyWithCompanion(LignesVenteCompanion data) {
    return LigneVente(
      id: data.id.present ? data.id.value : this.id,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
      supprimeLe: data.supprimeLe.present
          ? data.supprimeLe.value
          : this.supprimeLe,
      synchro: data.synchro.present ? data.synchro.value : this.synchro,
      appareilId: data.appareilId.present
          ? data.appareilId.value
          : this.appareilId,
      venteId: data.venteId.present ? data.venteId.value : this.venteId,
      produitId: data.produitId.present ? data.produitId.value : this.produitId,
      nomProduit: data.nomProduit.present
          ? data.nomProduit.value
          : this.nomProduit,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      prixUnitaire: data.prixUnitaire.present
          ? data.prixUnitaire.value
          : this.prixUnitaire,
      prixAchatUnitaire: data.prixAchatUnitaire.present
          ? data.prixAchatUnitaire.value
          : this.prixAchatUnitaire,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LigneVente(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('venteId: $venteId, ')
          ..write('produitId: $produitId, ')
          ..write('nomProduit: $nomProduit, ')
          ..write('quantite: $quantite, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('prixAchatUnitaire: $prixAchatUnitaire')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    venteId,
    produitId,
    nomProduit,
    quantite,
    prixUnitaire,
    prixAchatUnitaire,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LigneVente &&
          other.id == this.id &&
          other.majLe == this.majLe &&
          other.supprimeLe == this.supprimeLe &&
          other.synchro == this.synchro &&
          other.appareilId == this.appareilId &&
          other.venteId == this.venteId &&
          other.produitId == this.produitId &&
          other.nomProduit == this.nomProduit &&
          other.quantite == this.quantite &&
          other.prixUnitaire == this.prixUnitaire &&
          other.prixAchatUnitaire == this.prixAchatUnitaire);
}

class LignesVenteCompanion extends UpdateCompanion<LigneVente> {
  final Value<String> id;
  final Value<DateTime> majLe;
  final Value<DateTime?> supprimeLe;
  final Value<bool> synchro;
  final Value<String> appareilId;
  final Value<String> venteId;
  final Value<String> produitId;
  final Value<String> nomProduit;
  final Value<double> quantite;
  final Value<int> prixUnitaire;
  final Value<int> prixAchatUnitaire;
  final Value<int> rowid;
  const LignesVenteCompanion({
    this.id = const Value.absent(),
    this.majLe = const Value.absent(),
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.venteId = const Value.absent(),
    this.produitId = const Value.absent(),
    this.nomProduit = const Value.absent(),
    this.quantite = const Value.absent(),
    this.prixUnitaire = const Value.absent(),
    this.prixAchatUnitaire = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LignesVenteCompanion.insert({
    required String id,
    required DateTime majLe,
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    required String appareilId,
    required String venteId,
    required String produitId,
    required String nomProduit,
    required double quantite,
    required int prixUnitaire,
    required int prixAchatUnitaire,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       majLe = Value(majLe),
       appareilId = Value(appareilId),
       venteId = Value(venteId),
       produitId = Value(produitId),
       nomProduit = Value(nomProduit),
       quantite = Value(quantite),
       prixUnitaire = Value(prixUnitaire),
       prixAchatUnitaire = Value(prixAchatUnitaire);
  static Insertable<LigneVente> custom({
    Expression<String>? id,
    Expression<DateTime>? majLe,
    Expression<DateTime>? supprimeLe,
    Expression<bool>? synchro,
    Expression<String>? appareilId,
    Expression<String>? venteId,
    Expression<String>? produitId,
    Expression<String>? nomProduit,
    Expression<double>? quantite,
    Expression<int>? prixUnitaire,
    Expression<int>? prixAchatUnitaire,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (majLe != null) 'maj_le': majLe,
      if (supprimeLe != null) 'supprime_le': supprimeLe,
      if (synchro != null) 'synchro': synchro,
      if (appareilId != null) 'appareil_id': appareilId,
      if (venteId != null) 'vente_id': venteId,
      if (produitId != null) 'produit_id': produitId,
      if (nomProduit != null) 'nom_produit': nomProduit,
      if (quantite != null) 'quantite': quantite,
      if (prixUnitaire != null) 'prix_unitaire': prixUnitaire,
      if (prixAchatUnitaire != null) 'prix_achat_unitaire': prixAchatUnitaire,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LignesVenteCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? majLe,
    Value<DateTime?>? supprimeLe,
    Value<bool>? synchro,
    Value<String>? appareilId,
    Value<String>? venteId,
    Value<String>? produitId,
    Value<String>? nomProduit,
    Value<double>? quantite,
    Value<int>? prixUnitaire,
    Value<int>? prixAchatUnitaire,
    Value<int>? rowid,
  }) {
    return LignesVenteCompanion(
      id: id ?? this.id,
      majLe: majLe ?? this.majLe,
      supprimeLe: supprimeLe ?? this.supprimeLe,
      synchro: synchro ?? this.synchro,
      appareilId: appareilId ?? this.appareilId,
      venteId: venteId ?? this.venteId,
      produitId: produitId ?? this.produitId,
      nomProduit: nomProduit ?? this.nomProduit,
      quantite: quantite ?? this.quantite,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      prixAchatUnitaire: prixAchatUnitaire ?? this.prixAchatUnitaire,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    if (supprimeLe.present) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe.value);
    }
    if (synchro.present) {
      map['synchro'] = Variable<bool>(synchro.value);
    }
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (venteId.present) {
      map['vente_id'] = Variable<String>(venteId.value);
    }
    if (produitId.present) {
      map['produit_id'] = Variable<String>(produitId.value);
    }
    if (nomProduit.present) {
      map['nom_produit'] = Variable<String>(nomProduit.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<double>(quantite.value);
    }
    if (prixUnitaire.present) {
      map['prix_unitaire'] = Variable<int>(prixUnitaire.value);
    }
    if (prixAchatUnitaire.present) {
      map['prix_achat_unitaire'] = Variable<int>(prixAchatUnitaire.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LignesVenteCompanion(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('venteId: $venteId, ')
          ..write('produitId: $produitId, ')
          ..write('nomProduit: $nomProduit, ')
          ..write('quantite: $quantite, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('prixAchatUnitaire: $prixAchatUnitaire, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VersementsDetteTable extends VersementsDette
    with TableInfo<$VersementsDetteTable, VersementDette> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersementsDetteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supprimeLeMeta = const VerificationMeta(
    'supprimeLe',
  );
  @override
  late final GeneratedColumn<DateTime> supprimeLe = GeneratedColumn<DateTime>(
    'supprime_le',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchroMeta = const VerificationMeta(
    'synchro',
  );
  @override
  late final GeneratedColumn<bool> synchro = GeneratedColumn<bool>(
    'synchro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appareilIdMeta = const VerificationMeta(
    'appareilId',
  );
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
    'appareil_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _montantMeta = const VerificationMeta(
    'montant',
  );
  @override
  late final GeneratedColumn<int> montant = GeneratedColumn<int>(
    'montant',
    aliasedName,
    false,
    check: () => ComparableExpr(montant).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modePaiementMeta = const VerificationMeta(
    'modePaiement',
  );
  @override
  late final GeneratedColumn<String> modePaiement = GeneratedColumn<String>(
    'mode_paiement',
    aliasedName,
    false,
    check: () => modePaiement.isIn(ModePaiement.pourVersement),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateVersementMeta = const VerificationMeta(
    'dateVersement',
  );
  @override
  late final GeneratedColumn<DateTime> dateVersement =
      GeneratedColumn<DateTime>(
        'date_versement',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    clientId,
    montant,
    modePaiement,
    dateVersement,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'versements_dette';
  @override
  VerificationContext validateIntegrity(
    Insertable<VersementDette> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('maj_le')) {
      context.handle(
        _majLeMeta,
        majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta),
      );
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    if (data.containsKey('supprime_le')) {
      context.handle(
        _supprimeLeMeta,
        supprimeLe.isAcceptableOrUnknown(data['supprime_le']!, _supprimeLeMeta),
      );
    }
    if (data.containsKey('synchro')) {
      context.handle(
        _synchroMeta,
        synchro.isAcceptableOrUnknown(data['synchro']!, _synchroMeta),
      );
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
        _appareilIdMeta,
        appareilId.isAcceptableOrUnknown(data['appareil_id']!, _appareilIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('montant')) {
      context.handle(
        _montantMeta,
        montant.isAcceptableOrUnknown(data['montant']!, _montantMeta),
      );
    } else if (isInserting) {
      context.missing(_montantMeta);
    }
    if (data.containsKey('mode_paiement')) {
      context.handle(
        _modePaiementMeta,
        modePaiement.isAcceptableOrUnknown(
          data['mode_paiement']!,
          _modePaiementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modePaiementMeta);
    }
    if (data.containsKey('date_versement')) {
      context.handle(
        _dateVersementMeta,
        dateVersement.isAcceptableOrUnknown(
          data['date_versement']!,
          _dateVersementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateVersementMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VersementDette map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VersementDette(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      majLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maj_le'],
      )!,
      supprimeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}supprime_le'],
      ),
      synchro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchro'],
      )!,
      appareilId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appareil_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      montant: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}montant'],
      )!,
      modePaiement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode_paiement'],
      )!,
      dateVersement: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_versement'],
      )!,
    );
  }

  @override
  $VersementsDetteTable createAlias(String alias) {
    return $VersementsDetteTable(attachedDatabase, alias);
  }
}

class VersementDette extends DataClass implements Insertable<VersementDette> {
  final String id;
  final DateTime majLe;
  final DateTime? supprimeLe;
  final bool synchro;
  final String appareilId;
  final String clientId;
  final int montant;
  final String modePaiement;
  final DateTime dateVersement;
  const VersementDette({
    required this.id,
    required this.majLe,
    this.supprimeLe,
    required this.synchro,
    required this.appareilId,
    required this.clientId,
    required this.montant,
    required this.modePaiement,
    required this.dateVersement,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maj_le'] = Variable<DateTime>(majLe);
    if (!nullToAbsent || supprimeLe != null) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe);
    }
    map['synchro'] = Variable<bool>(synchro);
    map['appareil_id'] = Variable<String>(appareilId);
    map['client_id'] = Variable<String>(clientId);
    map['montant'] = Variable<int>(montant);
    map['mode_paiement'] = Variable<String>(modePaiement);
    map['date_versement'] = Variable<DateTime>(dateVersement);
    return map;
  }

  VersementsDetteCompanion toCompanion(bool nullToAbsent) {
    return VersementsDetteCompanion(
      id: Value(id),
      majLe: Value(majLe),
      supprimeLe: supprimeLe == null && nullToAbsent
          ? const Value.absent()
          : Value(supprimeLe),
      synchro: Value(synchro),
      appareilId: Value(appareilId),
      clientId: Value(clientId),
      montant: Value(montant),
      modePaiement: Value(modePaiement),
      dateVersement: Value(dateVersement),
    );
  }

  factory VersementDette.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VersementDette(
      id: serializer.fromJson<String>(json['id']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
      supprimeLe: serializer.fromJson<DateTime?>(json['supprimeLe']),
      synchro: serializer.fromJson<bool>(json['synchro']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      montant: serializer.fromJson<int>(json['montant']),
      modePaiement: serializer.fromJson<String>(json['modePaiement']),
      dateVersement: serializer.fromJson<DateTime>(json['dateVersement']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'majLe': serializer.toJson<DateTime>(majLe),
      'supprimeLe': serializer.toJson<DateTime?>(supprimeLe),
      'synchro': serializer.toJson<bool>(synchro),
      'appareilId': serializer.toJson<String>(appareilId),
      'clientId': serializer.toJson<String>(clientId),
      'montant': serializer.toJson<int>(montant),
      'modePaiement': serializer.toJson<String>(modePaiement),
      'dateVersement': serializer.toJson<DateTime>(dateVersement),
    };
  }

  VersementDette copyWith({
    String? id,
    DateTime? majLe,
    Value<DateTime?> supprimeLe = const Value.absent(),
    bool? synchro,
    String? appareilId,
    String? clientId,
    int? montant,
    String? modePaiement,
    DateTime? dateVersement,
  }) => VersementDette(
    id: id ?? this.id,
    majLe: majLe ?? this.majLe,
    supprimeLe: supprimeLe.present ? supprimeLe.value : this.supprimeLe,
    synchro: synchro ?? this.synchro,
    appareilId: appareilId ?? this.appareilId,
    clientId: clientId ?? this.clientId,
    montant: montant ?? this.montant,
    modePaiement: modePaiement ?? this.modePaiement,
    dateVersement: dateVersement ?? this.dateVersement,
  );
  VersementDette copyWithCompanion(VersementsDetteCompanion data) {
    return VersementDette(
      id: data.id.present ? data.id.value : this.id,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
      supprimeLe: data.supprimeLe.present
          ? data.supprimeLe.value
          : this.supprimeLe,
      synchro: data.synchro.present ? data.synchro.value : this.synchro,
      appareilId: data.appareilId.present
          ? data.appareilId.value
          : this.appareilId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      montant: data.montant.present ? data.montant.value : this.montant,
      modePaiement: data.modePaiement.present
          ? data.modePaiement.value
          : this.modePaiement,
      dateVersement: data.dateVersement.present
          ? data.dateVersement.value
          : this.dateVersement,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VersementDette(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('clientId: $clientId, ')
          ..write('montant: $montant, ')
          ..write('modePaiement: $modePaiement, ')
          ..write('dateVersement: $dateVersement')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    clientId,
    montant,
    modePaiement,
    dateVersement,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VersementDette &&
          other.id == this.id &&
          other.majLe == this.majLe &&
          other.supprimeLe == this.supprimeLe &&
          other.synchro == this.synchro &&
          other.appareilId == this.appareilId &&
          other.clientId == this.clientId &&
          other.montant == this.montant &&
          other.modePaiement == this.modePaiement &&
          other.dateVersement == this.dateVersement);
}

class VersementsDetteCompanion extends UpdateCompanion<VersementDette> {
  final Value<String> id;
  final Value<DateTime> majLe;
  final Value<DateTime?> supprimeLe;
  final Value<bool> synchro;
  final Value<String> appareilId;
  final Value<String> clientId;
  final Value<int> montant;
  final Value<String> modePaiement;
  final Value<DateTime> dateVersement;
  final Value<int> rowid;
  const VersementsDetteCompanion({
    this.id = const Value.absent(),
    this.majLe = const Value.absent(),
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.montant = const Value.absent(),
    this.modePaiement = const Value.absent(),
    this.dateVersement = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VersementsDetteCompanion.insert({
    required String id,
    required DateTime majLe,
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    required String appareilId,
    required String clientId,
    required int montant,
    required String modePaiement,
    required DateTime dateVersement,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       majLe = Value(majLe),
       appareilId = Value(appareilId),
       clientId = Value(clientId),
       montant = Value(montant),
       modePaiement = Value(modePaiement),
       dateVersement = Value(dateVersement);
  static Insertable<VersementDette> custom({
    Expression<String>? id,
    Expression<DateTime>? majLe,
    Expression<DateTime>? supprimeLe,
    Expression<bool>? synchro,
    Expression<String>? appareilId,
    Expression<String>? clientId,
    Expression<int>? montant,
    Expression<String>? modePaiement,
    Expression<DateTime>? dateVersement,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (majLe != null) 'maj_le': majLe,
      if (supprimeLe != null) 'supprime_le': supprimeLe,
      if (synchro != null) 'synchro': synchro,
      if (appareilId != null) 'appareil_id': appareilId,
      if (clientId != null) 'client_id': clientId,
      if (montant != null) 'montant': montant,
      if (modePaiement != null) 'mode_paiement': modePaiement,
      if (dateVersement != null) 'date_versement': dateVersement,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VersementsDetteCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? majLe,
    Value<DateTime?>? supprimeLe,
    Value<bool>? synchro,
    Value<String>? appareilId,
    Value<String>? clientId,
    Value<int>? montant,
    Value<String>? modePaiement,
    Value<DateTime>? dateVersement,
    Value<int>? rowid,
  }) {
    return VersementsDetteCompanion(
      id: id ?? this.id,
      majLe: majLe ?? this.majLe,
      supprimeLe: supprimeLe ?? this.supprimeLe,
      synchro: synchro ?? this.synchro,
      appareilId: appareilId ?? this.appareilId,
      clientId: clientId ?? this.clientId,
      montant: montant ?? this.montant,
      modePaiement: modePaiement ?? this.modePaiement,
      dateVersement: dateVersement ?? this.dateVersement,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    if (supprimeLe.present) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe.value);
    }
    if (synchro.present) {
      map['synchro'] = Variable<bool>(synchro.value);
    }
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (montant.present) {
      map['montant'] = Variable<int>(montant.value);
    }
    if (modePaiement.present) {
      map['mode_paiement'] = Variable<String>(modePaiement.value);
    }
    if (dateVersement.present) {
      map['date_versement'] = Variable<DateTime>(dateVersement.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersementsDetteCompanion(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('clientId: $clientId, ')
          ..write('montant: $montant, ')
          ..write('modePaiement: $modePaiement, ')
          ..write('dateVersement: $dateVersement, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MouvementsStockTable extends MouvementsStock
    with TableInfo<$MouvementsStockTable, MouvementStock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MouvementsStockTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supprimeLeMeta = const VerificationMeta(
    'supprimeLe',
  );
  @override
  late final GeneratedColumn<DateTime> supprimeLe = GeneratedColumn<DateTime>(
    'supprime_le',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchroMeta = const VerificationMeta(
    'synchro',
  );
  @override
  late final GeneratedColumn<bool> synchro = GeneratedColumn<bool>(
    'synchro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appareilIdMeta = const VerificationMeta(
    'appareilId',
  );
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
    'appareil_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _produitIdMeta = const VerificationMeta(
    'produitId',
  );
  @override
  late final GeneratedColumn<String> produitId = GeneratedColumn<String>(
    'produit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produits (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => type.isIn(TypeMouvement.tous),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantiteMeta = const VerificationMeta(
    'quantite',
  );
  @override
  late final GeneratedColumn<double> quantite = GeneratedColumn<double>(
    'quantite',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prixAchatUnitaireMeta = const VerificationMeta(
    'prixAchatUnitaire',
  );
  @override
  late final GeneratedColumn<int> prixAchatUnitaire = GeneratedColumn<int>(
    'prix_achat_unitaire',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMouvementMeta = const VerificationMeta(
    'dateMouvement',
  );
  @override
  late final GeneratedColumn<DateTime> dateMouvement =
      GeneratedColumn<DateTime>(
        'date_mouvement',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    produitId,
    type,
    quantite,
    prixAchatUnitaire,
    referenceId,
    dateMouvement,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mouvements_stock';
  @override
  VerificationContext validateIntegrity(
    Insertable<MouvementStock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('maj_le')) {
      context.handle(
        _majLeMeta,
        majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta),
      );
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    if (data.containsKey('supprime_le')) {
      context.handle(
        _supprimeLeMeta,
        supprimeLe.isAcceptableOrUnknown(data['supprime_le']!, _supprimeLeMeta),
      );
    }
    if (data.containsKey('synchro')) {
      context.handle(
        _synchroMeta,
        synchro.isAcceptableOrUnknown(data['synchro']!, _synchroMeta),
      );
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
        _appareilIdMeta,
        appareilId.isAcceptableOrUnknown(data['appareil_id']!, _appareilIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('produit_id')) {
      context.handle(
        _produitIdMeta,
        produitId.isAcceptableOrUnknown(data['produit_id']!, _produitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_produitIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(
        _quantiteMeta,
        quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta),
      );
    } else if (isInserting) {
      context.missing(_quantiteMeta);
    }
    if (data.containsKey('prix_achat_unitaire')) {
      context.handle(
        _prixAchatUnitaireMeta,
        prixAchatUnitaire.isAcceptableOrUnknown(
          data['prix_achat_unitaire']!,
          _prixAchatUnitaireMeta,
        ),
      );
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('date_mouvement')) {
      context.handle(
        _dateMouvementMeta,
        dateMouvement.isAcceptableOrUnknown(
          data['date_mouvement']!,
          _dateMouvementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateMouvementMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MouvementStock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MouvementStock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      majLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maj_le'],
      )!,
      supprimeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}supprime_le'],
      ),
      synchro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchro'],
      )!,
      appareilId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appareil_id'],
      )!,
      produitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}produit_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      quantite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantite'],
      )!,
      prixAchatUnitaire: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prix_achat_unitaire'],
      ),
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      dateMouvement: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_mouvement'],
      )!,
    );
  }

  @override
  $MouvementsStockTable createAlias(String alias) {
    return $MouvementsStockTable(attachedDatabase, alias);
  }
}

class MouvementStock extends DataClass implements Insertable<MouvementStock> {
  final String id;
  final DateTime majLe;
  final DateTime? supprimeLe;
  final bool synchro;
  final String appareilId;
  final String produitId;
  final String type;

  /// Positive pour une entrée, négative pour une sortie.
  final double quantite;

  /// Pour les entrées : nouveau coût d'achat.
  final int? prixAchatUnitaire;

  /// Vente liée (mouvements « vente » et « annulation »).
  final String? referenceId;
  final DateTime dateMouvement;
  const MouvementStock({
    required this.id,
    required this.majLe,
    this.supprimeLe,
    required this.synchro,
    required this.appareilId,
    required this.produitId,
    required this.type,
    required this.quantite,
    this.prixAchatUnitaire,
    this.referenceId,
    required this.dateMouvement,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maj_le'] = Variable<DateTime>(majLe);
    if (!nullToAbsent || supprimeLe != null) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe);
    }
    map['synchro'] = Variable<bool>(synchro);
    map['appareil_id'] = Variable<String>(appareilId);
    map['produit_id'] = Variable<String>(produitId);
    map['type'] = Variable<String>(type);
    map['quantite'] = Variable<double>(quantite);
    if (!nullToAbsent || prixAchatUnitaire != null) {
      map['prix_achat_unitaire'] = Variable<int>(prixAchatUnitaire);
    }
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    map['date_mouvement'] = Variable<DateTime>(dateMouvement);
    return map;
  }

  MouvementsStockCompanion toCompanion(bool nullToAbsent) {
    return MouvementsStockCompanion(
      id: Value(id),
      majLe: Value(majLe),
      supprimeLe: supprimeLe == null && nullToAbsent
          ? const Value.absent()
          : Value(supprimeLe),
      synchro: Value(synchro),
      appareilId: Value(appareilId),
      produitId: Value(produitId),
      type: Value(type),
      quantite: Value(quantite),
      prixAchatUnitaire: prixAchatUnitaire == null && nullToAbsent
          ? const Value.absent()
          : Value(prixAchatUnitaire),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      dateMouvement: Value(dateMouvement),
    );
  }

  factory MouvementStock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MouvementStock(
      id: serializer.fromJson<String>(json['id']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
      supprimeLe: serializer.fromJson<DateTime?>(json['supprimeLe']),
      synchro: serializer.fromJson<bool>(json['synchro']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      produitId: serializer.fromJson<String>(json['produitId']),
      type: serializer.fromJson<String>(json['type']),
      quantite: serializer.fromJson<double>(json['quantite']),
      prixAchatUnitaire: serializer.fromJson<int?>(json['prixAchatUnitaire']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      dateMouvement: serializer.fromJson<DateTime>(json['dateMouvement']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'majLe': serializer.toJson<DateTime>(majLe),
      'supprimeLe': serializer.toJson<DateTime?>(supprimeLe),
      'synchro': serializer.toJson<bool>(synchro),
      'appareilId': serializer.toJson<String>(appareilId),
      'produitId': serializer.toJson<String>(produitId),
      'type': serializer.toJson<String>(type),
      'quantite': serializer.toJson<double>(quantite),
      'prixAchatUnitaire': serializer.toJson<int?>(prixAchatUnitaire),
      'referenceId': serializer.toJson<String?>(referenceId),
      'dateMouvement': serializer.toJson<DateTime>(dateMouvement),
    };
  }

  MouvementStock copyWith({
    String? id,
    DateTime? majLe,
    Value<DateTime?> supprimeLe = const Value.absent(),
    bool? synchro,
    String? appareilId,
    String? produitId,
    String? type,
    double? quantite,
    Value<int?> prixAchatUnitaire = const Value.absent(),
    Value<String?> referenceId = const Value.absent(),
    DateTime? dateMouvement,
  }) => MouvementStock(
    id: id ?? this.id,
    majLe: majLe ?? this.majLe,
    supprimeLe: supprimeLe.present ? supprimeLe.value : this.supprimeLe,
    synchro: synchro ?? this.synchro,
    appareilId: appareilId ?? this.appareilId,
    produitId: produitId ?? this.produitId,
    type: type ?? this.type,
    quantite: quantite ?? this.quantite,
    prixAchatUnitaire: prixAchatUnitaire.present
        ? prixAchatUnitaire.value
        : this.prixAchatUnitaire,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    dateMouvement: dateMouvement ?? this.dateMouvement,
  );
  MouvementStock copyWithCompanion(MouvementsStockCompanion data) {
    return MouvementStock(
      id: data.id.present ? data.id.value : this.id,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
      supprimeLe: data.supprimeLe.present
          ? data.supprimeLe.value
          : this.supprimeLe,
      synchro: data.synchro.present ? data.synchro.value : this.synchro,
      appareilId: data.appareilId.present
          ? data.appareilId.value
          : this.appareilId,
      produitId: data.produitId.present ? data.produitId.value : this.produitId,
      type: data.type.present ? data.type.value : this.type,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      prixAchatUnitaire: data.prixAchatUnitaire.present
          ? data.prixAchatUnitaire.value
          : this.prixAchatUnitaire,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      dateMouvement: data.dateMouvement.present
          ? data.dateMouvement.value
          : this.dateMouvement,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MouvementStock(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('produitId: $produitId, ')
          ..write('type: $type, ')
          ..write('quantite: $quantite, ')
          ..write('prixAchatUnitaire: $prixAchatUnitaire, ')
          ..write('referenceId: $referenceId, ')
          ..write('dateMouvement: $dateMouvement')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    majLe,
    supprimeLe,
    synchro,
    appareilId,
    produitId,
    type,
    quantite,
    prixAchatUnitaire,
    referenceId,
    dateMouvement,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MouvementStock &&
          other.id == this.id &&
          other.majLe == this.majLe &&
          other.supprimeLe == this.supprimeLe &&
          other.synchro == this.synchro &&
          other.appareilId == this.appareilId &&
          other.produitId == this.produitId &&
          other.type == this.type &&
          other.quantite == this.quantite &&
          other.prixAchatUnitaire == this.prixAchatUnitaire &&
          other.referenceId == this.referenceId &&
          other.dateMouvement == this.dateMouvement);
}

class MouvementsStockCompanion extends UpdateCompanion<MouvementStock> {
  final Value<String> id;
  final Value<DateTime> majLe;
  final Value<DateTime?> supprimeLe;
  final Value<bool> synchro;
  final Value<String> appareilId;
  final Value<String> produitId;
  final Value<String> type;
  final Value<double> quantite;
  final Value<int?> prixAchatUnitaire;
  final Value<String?> referenceId;
  final Value<DateTime> dateMouvement;
  final Value<int> rowid;
  const MouvementsStockCompanion({
    this.id = const Value.absent(),
    this.majLe = const Value.absent(),
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.produitId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantite = const Value.absent(),
    this.prixAchatUnitaire = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.dateMouvement = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MouvementsStockCompanion.insert({
    required String id,
    required DateTime majLe,
    this.supprimeLe = const Value.absent(),
    this.synchro = const Value.absent(),
    required String appareilId,
    required String produitId,
    required String type,
    required double quantite,
    this.prixAchatUnitaire = const Value.absent(),
    this.referenceId = const Value.absent(),
    required DateTime dateMouvement,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       majLe = Value(majLe),
       appareilId = Value(appareilId),
       produitId = Value(produitId),
       type = Value(type),
       quantite = Value(quantite),
       dateMouvement = Value(dateMouvement);
  static Insertable<MouvementStock> custom({
    Expression<String>? id,
    Expression<DateTime>? majLe,
    Expression<DateTime>? supprimeLe,
    Expression<bool>? synchro,
    Expression<String>? appareilId,
    Expression<String>? produitId,
    Expression<String>? type,
    Expression<double>? quantite,
    Expression<int>? prixAchatUnitaire,
    Expression<String>? referenceId,
    Expression<DateTime>? dateMouvement,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (majLe != null) 'maj_le': majLe,
      if (supprimeLe != null) 'supprime_le': supprimeLe,
      if (synchro != null) 'synchro': synchro,
      if (appareilId != null) 'appareil_id': appareilId,
      if (produitId != null) 'produit_id': produitId,
      if (type != null) 'type': type,
      if (quantite != null) 'quantite': quantite,
      if (prixAchatUnitaire != null) 'prix_achat_unitaire': prixAchatUnitaire,
      if (referenceId != null) 'reference_id': referenceId,
      if (dateMouvement != null) 'date_mouvement': dateMouvement,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MouvementsStockCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? majLe,
    Value<DateTime?>? supprimeLe,
    Value<bool>? synchro,
    Value<String>? appareilId,
    Value<String>? produitId,
    Value<String>? type,
    Value<double>? quantite,
    Value<int?>? prixAchatUnitaire,
    Value<String?>? referenceId,
    Value<DateTime>? dateMouvement,
    Value<int>? rowid,
  }) {
    return MouvementsStockCompanion(
      id: id ?? this.id,
      majLe: majLe ?? this.majLe,
      supprimeLe: supprimeLe ?? this.supprimeLe,
      synchro: synchro ?? this.synchro,
      appareilId: appareilId ?? this.appareilId,
      produitId: produitId ?? this.produitId,
      type: type ?? this.type,
      quantite: quantite ?? this.quantite,
      prixAchatUnitaire: prixAchatUnitaire ?? this.prixAchatUnitaire,
      referenceId: referenceId ?? this.referenceId,
      dateMouvement: dateMouvement ?? this.dateMouvement,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    if (supprimeLe.present) {
      map['supprime_le'] = Variable<DateTime>(supprimeLe.value);
    }
    if (synchro.present) {
      map['synchro'] = Variable<bool>(synchro.value);
    }
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (produitId.present) {
      map['produit_id'] = Variable<String>(produitId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<double>(quantite.value);
    }
    if (prixAchatUnitaire.present) {
      map['prix_achat_unitaire'] = Variable<int>(prixAchatUnitaire.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (dateMouvement.present) {
      map['date_mouvement'] = Variable<DateTime>(dateMouvement.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MouvementsStockCompanion(')
          ..write('id: $id, ')
          ..write('majLe: $majLe, ')
          ..write('supprimeLe: $supprimeLe, ')
          ..write('synchro: $synchro, ')
          ..write('appareilId: $appareilId, ')
          ..write('produitId: $produitId, ')
          ..write('type: $type, ')
          ..write('quantite: $quantite, ')
          ..write('prixAchatUnitaire: $prixAchatUnitaire, ')
          ..write('referenceId: $referenceId, ')
          ..write('dateMouvement: $dateMouvement, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$KassaDatabase extends GeneratedDatabase {
  _$KassaDatabase(QueryExecutor e) : super(e);
  $KassaDatabaseManager get managers => $KassaDatabaseManager(this);
  late final $BoutiquesTable boutiques = $BoutiquesTable(this);
  late final $UtilisateursTable utilisateurs = $UtilisateursTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProduitsTable produits = $ProduitsTable(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $VentesTable ventes = $VentesTable(this);
  late final $LignesVenteTable lignesVente = $LignesVenteTable(this);
  late final $VersementsDetteTable versementsDette = $VersementsDetteTable(
    this,
  );
  late final $MouvementsStockTable mouvementsStock = $MouvementsStockTable(
    this,
  );
  late final Index produitsCategorieId = Index(
    'produits_categorie_id',
    'CREATE INDEX produits_categorie_id ON produits (categorie_id)',
  );
  late final Index ventesClientId = Index(
    'ventes_client_id',
    'CREATE INDEX ventes_client_id ON ventes (client_id)',
  );
  late final Index ventesDateVente = Index(
    'ventes_date_vente',
    'CREATE INDEX ventes_date_vente ON ventes (date_vente)',
  );
  late final Index lignesVenteVenteId = Index(
    'lignes_vente_vente_id',
    'CREATE INDEX lignes_vente_vente_id ON lignes_vente (vente_id)',
  );
  late final Index lignesVenteProduitId = Index(
    'lignes_vente_produit_id',
    'CREATE INDEX lignes_vente_produit_id ON lignes_vente (produit_id)',
  );
  late final Index versementsDetteClientId = Index(
    'versements_dette_client_id',
    'CREATE INDEX versements_dette_client_id ON versements_dette (client_id)',
  );
  late final Index mouvementsStockProduitId = Index(
    'mouvements_stock_produit_id',
    'CREATE INDEX mouvements_stock_produit_id ON mouvements_stock (produit_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    boutiques,
    utilisateurs,
    categories,
    produits,
    clients,
    ventes,
    lignesVente,
    versementsDette,
    mouvementsStock,
    produitsCategorieId,
    ventesClientId,
    ventesDateVente,
    lignesVenteVenteId,
    lignesVenteProduitId,
    versementsDetteClientId,
    mouvementsStockProduitId,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$BoutiquesTableCreateCompanionBuilder = BoutiquesCompanion Function({
  required String id,
  required DateTime majLe,
  Value<DateTime?> supprimeLe,
  Value<bool> synchro,
  required String appareilId,
  required String nom,
  required String telephone,
  required String ville,
  required String quartier,
  required String typeCommerce,
  required int seuilAlerteDefaut,
  required DateTime creeLe,
  Value<int> rowid,
});
typedef $$BoutiquesTableUpdateCompanionBuilder = BoutiquesCompanion Function({
  Value<String> id,
  Value<DateTime> majLe,
  Value<DateTime?> supprimeLe,
  Value<bool> synchro,
  Value<String> appareilId,
  Value<String> nom,
  Value<String> telephone,
  Value<String> ville,
  Value<String> quartier,
  Value<String> typeCommerce,
  Value<int> seuilAlerteDefaut,
  Value<DateTime> creeLe,
  Value<int> rowid,
});

final class $$BoutiquesTableReferences
    extends BaseReferences<_$KassaDatabase, $BoutiquesTable, Boutique> {
  $$BoutiquesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UtilisateursTable, List<Utilisateur>>
  _utilisateursRefsTable(_$KassaDatabase db) => MultiTypedResultKey.fromTable(
    db.utilisateurs,
    aliasName: 'boutiques__id__utilisateurs__boutique_id',
  );

  $$UtilisateursTableProcessedTableManager get utilisateursRefs {
    final manager = $$UtilisateursTableTableManager(
      $_db,
      $_db.utilisateurs,
    ).filter((f) => f.boutiqueId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_utilisateursRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BoutiquesTableFilterComposer
    extends Composer<_$KassaDatabase, $BoutiquesTable> {
  $$BoutiquesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ville => $composableBuilder(
    column: $table.ville,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quartier => $composableBuilder(
    column: $table.quartier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeCommerce => $composableBuilder(
    column: $table.typeCommerce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seuilAlerteDefaut => $composableBuilder(
    column: $table.seuilAlerteDefaut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> utilisateursRefs(
    Expression<bool> Function($$UtilisateursTableFilterComposer f) f,
  ) {
    final $$UtilisateursTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.utilisateurs,
      getReferencedColumn: (t) => t.boutiqueId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtilisateursTableFilterComposer(
            $db: $db,
            $table: $db.utilisateurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BoutiquesTableOrderingComposer
    extends Composer<_$KassaDatabase, $BoutiquesTable> {
  $$BoutiquesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ville => $composableBuilder(
    column: $table.ville,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quartier => $composableBuilder(
    column: $table.quartier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeCommerce => $composableBuilder(
    column: $table.typeCommerce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seuilAlerteDefaut => $composableBuilder(
    column: $table.seuilAlerteDefaut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoutiquesTableAnnotationComposer
    extends Composer<_$KassaDatabase, $BoutiquesTable> {
  $$BoutiquesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => column);

  GeneratedColumn<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synchro =>
      $composableBuilder(column: $table.synchro, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get telephone =>
      $composableBuilder(column: $table.telephone, builder: (column) => column);

  GeneratedColumn<String> get ville =>
      $composableBuilder(column: $table.ville, builder: (column) => column);

  GeneratedColumn<String> get quartier =>
      $composableBuilder(column: $table.quartier, builder: (column) => column);

  GeneratedColumn<String> get typeCommerce => $composableBuilder(
    column: $table.typeCommerce,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seuilAlerteDefaut => $composableBuilder(
    column: $table.seuilAlerteDefaut,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creeLe =>
      $composableBuilder(column: $table.creeLe, builder: (column) => column);

  Expression<T> utilisateursRefs<T extends Object>(
    Expression<T> Function($$UtilisateursTableAnnotationComposer a) f,
  ) {
    final $$UtilisateursTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.utilisateurs,
      getReferencedColumn: (t) => t.boutiqueId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtilisateursTableAnnotationComposer(
            $db: $db,
            $table: $db.utilisateurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BoutiquesTableTableManager
    extends
        RootTableManager<
          _$KassaDatabase,
          $BoutiquesTable,
          Boutique,
          $$BoutiquesTableFilterComposer,
          $$BoutiquesTableOrderingComposer,
          $$BoutiquesTableAnnotationComposer,
          $$BoutiquesTableCreateCompanionBuilder,
          $$BoutiquesTableUpdateCompanionBuilder,
          (Boutique, $$BoutiquesTableReferences),
          Boutique,
          PrefetchHooks Function({bool utilisateursRefs})
        > {
  $$BoutiquesTableTableManager(_$KassaDatabase db, $BoutiquesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoutiquesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoutiquesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoutiquesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                Value<String> appareilId = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<String> telephone = const Value.absent(),
                Value<String> ville = const Value.absent(),
                Value<String> quartier = const Value.absent(),
                Value<String> typeCommerce = const Value.absent(),
                Value<int> seuilAlerteDefaut = const Value.absent(),
                Value<DateTime> creeLe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BoutiquesCompanion(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                nom: nom,
                telephone: telephone,
                ville: ville,
                quartier: quartier,
                typeCommerce: typeCommerce,
                seuilAlerteDefaut: seuilAlerteDefaut,
                creeLe: creeLe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime majLe,
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                required String appareilId,
                required String nom,
                required String telephone,
                required String ville,
                required String quartier,
                required String typeCommerce,
                required int seuilAlerteDefaut,
                required DateTime creeLe,
                Value<int> rowid = const Value.absent(),
              }) => BoutiquesCompanion.insert(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                nom: nom,
                telephone: telephone,
                ville: ville,
                quartier: quartier,
                typeCommerce: typeCommerce,
                seuilAlerteDefaut: seuilAlerteDefaut,
                creeLe: creeLe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BoutiquesTable, Boutique>(table),
                  $$BoutiquesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({utilisateursRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (utilisateursRefs) db.utilisateurs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (utilisateursRefs)
                    await $_getPrefetchedData<
                      Boutique,
                      $BoutiquesTable,
                      Utilisateur
                    >(
                      currentTable: table,
                      referencedTable: $$BoutiquesTableReferences
                          ._utilisateursRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BoutiquesTableReferences(
                            db,
                            table,
                            p0,
                          ).utilisateursRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.boutiqueId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BoutiquesTableProcessedTableManager =
    ProcessedTableManager<
      _$KassaDatabase,
      $BoutiquesTable,
      Boutique,
      $$BoutiquesTableFilterComposer,
      $$BoutiquesTableOrderingComposer,
      $$BoutiquesTableAnnotationComposer,
      $$BoutiquesTableCreateCompanionBuilder,
      $$BoutiquesTableUpdateCompanionBuilder,
      (Boutique, $$BoutiquesTableReferences),
      Boutique,
      PrefetchHooks Function({bool utilisateursRefs})
    >;
typedef $$UtilisateursTableCreateCompanionBuilder =
    UtilisateursCompanion Function({
      required String id,
      required DateTime majLe,
      Value<DateTime?> supprimeLe,
      Value<bool> synchro,
      required String appareilId,
      required String boutiqueId,
      required String nom,
      required String telephone,
      Value<String> role,
      required String codePin,
      Value<int> rowid,
    });
typedef $$UtilisateursTableUpdateCompanionBuilder =
    UtilisateursCompanion Function({
      Value<String> id,
      Value<DateTime> majLe,
      Value<DateTime?> supprimeLe,
      Value<bool> synchro,
      Value<String> appareilId,
      Value<String> boutiqueId,
      Value<String> nom,
      Value<String> telephone,
      Value<String> role,
      Value<String> codePin,
      Value<int> rowid,
    });

final class $$UtilisateursTableReferences
    extends BaseReferences<_$KassaDatabase, $UtilisateursTable, Utilisateur> {
  $$UtilisateursTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BoutiquesTable _boutiqueIdTable(_$KassaDatabase db) =>
      db.boutiques.createAlias('utilisateurs__boutique_id__boutiques__id');

  $$BoutiquesTableProcessedTableManager get boutiqueId {
    final $_column = $_itemColumn<String>('boutique_id')!;

    final manager = $$BoutiquesTableTableManager(
      $_db,
      $_db.boutiques,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_boutiqueIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$VentesTable, List<Vente>> _ventesRefsTable(
    _$KassaDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ventes,
    aliasName: 'utilisateurs__id__ventes__utilisateur_id',
  );

  $$VentesTableProcessedTableManager get ventesRefs {
    final manager = $$VentesTableTableManager(
      $_db,
      $_db.ventes,
    ).filter((f) => f.utilisateurId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ventesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UtilisateursTableFilterComposer
    extends Composer<_$KassaDatabase, $UtilisateursTable> {
  $$UtilisateursTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codePin => $composableBuilder(
    column: $table.codePin,
    builder: (column) => ColumnFilters(column),
  );

  $$BoutiquesTableFilterComposer get boutiqueId {
    final $$BoutiquesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boutiqueId,
      referencedTable: $db.boutiques,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoutiquesTableFilterComposer(
            $db: $db,
            $table: $db.boutiques,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ventesRefs(
    Expression<bool> Function($$VentesTableFilterComposer f) f,
  ) {
    final $$VentesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventes,
      getReferencedColumn: (t) => t.utilisateurId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentesTableFilterComposer(
            $db: $db,
            $table: $db.ventes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UtilisateursTableOrderingComposer
    extends Composer<_$KassaDatabase, $UtilisateursTable> {
  $$UtilisateursTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codePin => $composableBuilder(
    column: $table.codePin,
    builder: (column) => ColumnOrderings(column),
  );

  $$BoutiquesTableOrderingComposer get boutiqueId {
    final $$BoutiquesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boutiqueId,
      referencedTable: $db.boutiques,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoutiquesTableOrderingComposer(
            $db: $db,
            $table: $db.boutiques,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UtilisateursTableAnnotationComposer
    extends Composer<_$KassaDatabase, $UtilisateursTable> {
  $$UtilisateursTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => column);

  GeneratedColumn<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synchro =>
      $composableBuilder(column: $table.synchro, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get telephone =>
      $composableBuilder(column: $table.telephone, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get codePin =>
      $composableBuilder(column: $table.codePin, builder: (column) => column);

  $$BoutiquesTableAnnotationComposer get boutiqueId {
    final $$BoutiquesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boutiqueId,
      referencedTable: $db.boutiques,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoutiquesTableAnnotationComposer(
            $db: $db,
            $table: $db.boutiques,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ventesRefs<T extends Object>(
    Expression<T> Function($$VentesTableAnnotationComposer a) f,
  ) {
    final $$VentesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventes,
      getReferencedColumn: (t) => t.utilisateurId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentesTableAnnotationComposer(
            $db: $db,
            $table: $db.ventes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UtilisateursTableTableManager
    extends
        RootTableManager<
          _$KassaDatabase,
          $UtilisateursTable,
          Utilisateur,
          $$UtilisateursTableFilterComposer,
          $$UtilisateursTableOrderingComposer,
          $$UtilisateursTableAnnotationComposer,
          $$UtilisateursTableCreateCompanionBuilder,
          $$UtilisateursTableUpdateCompanionBuilder,
          (Utilisateur, $$UtilisateursTableReferences),
          Utilisateur,
          PrefetchHooks Function({bool boutiqueId, bool ventesRefs})
        > {
  $$UtilisateursTableTableManager(_$KassaDatabase db, $UtilisateursTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UtilisateursTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UtilisateursTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UtilisateursTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                Value<String> appareilId = const Value.absent(),
                Value<String> boutiqueId = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<String> telephone = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> codePin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UtilisateursCompanion(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                boutiqueId: boutiqueId,
                nom: nom,
                telephone: telephone,
                role: role,
                codePin: codePin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime majLe,
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                required String appareilId,
                required String boutiqueId,
                required String nom,
                required String telephone,
                Value<String> role = const Value.absent(),
                required String codePin,
                Value<int> rowid = const Value.absent(),
              }) => UtilisateursCompanion.insert(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                boutiqueId: boutiqueId,
                nom: nom,
                telephone: telephone,
                role: role,
                codePin: codePin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UtilisateursTable, Utilisateur>(table),
                  $$UtilisateursTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({boutiqueId = false, ventesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ventesRefs) db.ventes],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (boutiqueId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.boutiqueId,
                        referencedTable: $$UtilisateursTableReferences
                            ._boutiqueIdTable(db),
                        referencedColumn: $$UtilisateursTableReferences
                            ._boutiqueIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ventesRefs)
                    await $_getPrefetchedData<
                      Utilisateur,
                      $UtilisateursTable,
                      Vente
                    >(
                      currentTable: table,
                      referencedTable: $$UtilisateursTableReferences
                          ._ventesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UtilisateursTableReferences(
                            db,
                            table,
                            p0,
                          ).ventesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.utilisateurId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UtilisateursTableProcessedTableManager =
    ProcessedTableManager<
      _$KassaDatabase,
      $UtilisateursTable,
      Utilisateur,
      $$UtilisateursTableFilterComposer,
      $$UtilisateursTableOrderingComposer,
      $$UtilisateursTableAnnotationComposer,
      $$UtilisateursTableCreateCompanionBuilder,
      $$UtilisateursTableUpdateCompanionBuilder,
      (Utilisateur, $$UtilisateursTableReferences),
      Utilisateur,
      PrefetchHooks Function({bool boutiqueId, bool ventesRefs})
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required DateTime majLe,
  Value<DateTime?> supprimeLe,
  Value<bool> synchro,
  required String appareilId,
  required String nom,
  required String icone,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<DateTime> majLe,
  Value<DateTime?> supprimeLe,
  Value<bool> synchro,
  Value<String> appareilId,
  Value<String> nom,
  Value<String> icone,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$KassaDatabase, $CategoriesTable, Categorie> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProduitsTable, List<Produit>> _produitsRefsTable(
    _$KassaDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.produits,
    aliasName: 'categories__id__produits__categorie_id',
  );

  $$ProduitsTableProcessedTableManager get produitsRefs {
    final manager = $$ProduitsTableTableManager(
      $_db,
      $_db.produits,
    ).filter((f) => f.categorieId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_produitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$KassaDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icone => $composableBuilder(
    column: $table.icone,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> produitsRefs(
    Expression<bool> Function($$ProduitsTableFilterComposer f) f,
  ) {
    final $$ProduitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.categorieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableFilterComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$KassaDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icone => $composableBuilder(
    column: $table.icone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$KassaDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => column);

  GeneratedColumn<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synchro =>
      $composableBuilder(column: $table.synchro, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get icone =>
      $composableBuilder(column: $table.icone, builder: (column) => column);

  Expression<T> produitsRefs<T extends Object>(
    Expression<T> Function($$ProduitsTableAnnotationComposer a) f,
  ) {
    final $$ProduitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.categorieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableAnnotationComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$KassaDatabase,
          $CategoriesTable,
          Categorie,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Categorie, $$CategoriesTableReferences),
          Categorie,
          PrefetchHooks Function({bool produitsRefs})
        > {
  $$CategoriesTableTableManager(_$KassaDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                Value<String> appareilId = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<String> icone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                nom: nom,
                icone: icone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime majLe,
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                required String appareilId,
                required String nom,
                required String icone,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                nom: nom,
                icone: icone,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Categorie>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({produitsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (produitsRefs) db.produits],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (produitsRefs)
                    await $_getPrefetchedData<
                      Categorie,
                      $CategoriesTable,
                      Produit
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._produitsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).produitsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.categorieId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$KassaDatabase,
      $CategoriesTable,
      Categorie,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Categorie, $$CategoriesTableReferences),
      Categorie,
      PrefetchHooks Function({bool produitsRefs})
    >;
typedef $$ProduitsTableCreateCompanionBuilder = ProduitsCompanion Function({
  required String id,
  required DateTime majLe,
  Value<DateTime?> supprimeLe,
  Value<bool> synchro,
  required String appareilId,
  Value<String?> categorieId,
  required String nom,
  required int prixAchat,
  required int prixVente,
  Value<double> quantite,
  required String unite,
  required double seuilAlerte,
  Value<String?> photoLocale,
  Value<String?> codeBarre,
  Value<int> rowid,
});
typedef $$ProduitsTableUpdateCompanionBuilder = ProduitsCompanion Function({
  Value<String> id,
  Value<DateTime> majLe,
  Value<DateTime?> supprimeLe,
  Value<bool> synchro,
  Value<String> appareilId,
  Value<String?> categorieId,
  Value<String> nom,
  Value<int> prixAchat,
  Value<int> prixVente,
  Value<double> quantite,
  Value<String> unite,
  Value<double> seuilAlerte,
  Value<String?> photoLocale,
  Value<String?> codeBarre,
  Value<int> rowid,
});

final class $$ProduitsTableReferences
    extends BaseReferences<_$KassaDatabase, $ProduitsTable, Produit> {
  $$ProduitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categorieIdTable(_$KassaDatabase db) =>
      db.categories.createAlias('produits__categorie_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categorieId {
    final $_column = $_itemColumn<String>('categorie_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categorieIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LignesVenteTable, List<LigneVente>>
  _lignesVenteRefsTable(_$KassaDatabase db) => MultiTypedResultKey.fromTable(
    db.lignesVente,
    aliasName: 'produits__id__lignes_vente__produit_id',
  );

  $$LignesVenteTableProcessedTableManager get lignesVenteRefs {
    final manager = $$LignesVenteTableTableManager(
      $_db,
      $_db.lignesVente,
    ).filter((f) => f.produitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lignesVenteRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MouvementsStockTable, List<MouvementStock>>
  _mouvementsStockRefsTable(_$KassaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mouvementsStock,
        aliasName: 'produits__id__mouvements_stock__produit_id',
      );

  $$MouvementsStockTableProcessedTableManager get mouvementsStockRefs {
    final manager = $$MouvementsStockTableTableManager(
      $_db,
      $_db.mouvementsStock,
    ).filter((f) => f.produitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mouvementsStockRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProduitsTableFilterComposer
    extends Composer<_$KassaDatabase, $ProduitsTable> {
  $$ProduitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prixAchat => $composableBuilder(
    column: $table.prixAchat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prixVente => $composableBuilder(
    column: $table.prixVente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unite => $composableBuilder(
    column: $table.unite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get seuilAlerte => $composableBuilder(
    column: $table.seuilAlerte,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoLocale => $composableBuilder(
    column: $table.photoLocale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeBarre => $composableBuilder(
    column: $table.codeBarre,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categorieId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categorieId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lignesVenteRefs(
    Expression<bool> Function($$LignesVenteTableFilterComposer f) f,
  ) {
    final $$LignesVenteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lignesVente,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LignesVenteTableFilterComposer(
            $db: $db,
            $table: $db.lignesVente,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mouvementsStockRefs(
    Expression<bool> Function($$MouvementsStockTableFilterComposer f) f,
  ) {
    final $$MouvementsStockTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mouvementsStock,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MouvementsStockTableFilterComposer(
            $db: $db,
            $table: $db.mouvementsStock,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProduitsTableOrderingComposer
    extends Composer<_$KassaDatabase, $ProduitsTable> {
  $$ProduitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prixAchat => $composableBuilder(
    column: $table.prixAchat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prixVente => $composableBuilder(
    column: $table.prixVente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unite => $composableBuilder(
    column: $table.unite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get seuilAlerte => $composableBuilder(
    column: $table.seuilAlerte,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoLocale => $composableBuilder(
    column: $table.photoLocale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeBarre => $composableBuilder(
    column: $table.codeBarre,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categorieId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categorieId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduitsTableAnnotationComposer
    extends Composer<_$KassaDatabase, $ProduitsTable> {
  $$ProduitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => column);

  GeneratedColumn<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synchro =>
      $composableBuilder(column: $table.synchro, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<int> get prixAchat =>
      $composableBuilder(column: $table.prixAchat, builder: (column) => column);

  GeneratedColumn<int> get prixVente =>
      $composableBuilder(column: $table.prixVente, builder: (column) => column);

  GeneratedColumn<double> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<String> get unite =>
      $composableBuilder(column: $table.unite, builder: (column) => column);

  GeneratedColumn<double> get seuilAlerte => $composableBuilder(
    column: $table.seuilAlerte,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoLocale => $composableBuilder(
    column: $table.photoLocale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codeBarre =>
      $composableBuilder(column: $table.codeBarre, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categorieId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categorieId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lignesVenteRefs<T extends Object>(
    Expression<T> Function($$LignesVenteTableAnnotationComposer a) f,
  ) {
    final $$LignesVenteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lignesVente,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LignesVenteTableAnnotationComposer(
            $db: $db,
            $table: $db.lignesVente,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mouvementsStockRefs<T extends Object>(
    Expression<T> Function($$MouvementsStockTableAnnotationComposer a) f,
  ) {
    final $$MouvementsStockTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mouvementsStock,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MouvementsStockTableAnnotationComposer(
            $db: $db,
            $table: $db.mouvementsStock,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProduitsTableTableManager
    extends
        RootTableManager<
          _$KassaDatabase,
          $ProduitsTable,
          Produit,
          $$ProduitsTableFilterComposer,
          $$ProduitsTableOrderingComposer,
          $$ProduitsTableAnnotationComposer,
          $$ProduitsTableCreateCompanionBuilder,
          $$ProduitsTableUpdateCompanionBuilder,
          (Produit, $$ProduitsTableReferences),
          Produit,
          PrefetchHooks Function({
            bool categorieId,
            bool lignesVenteRefs,
            bool mouvementsStockRefs,
          })
        > {
  $$ProduitsTableTableManager(_$KassaDatabase db, $ProduitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProduitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProduitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProduitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                Value<String> appareilId = const Value.absent(),
                Value<String?> categorieId = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<int> prixAchat = const Value.absent(),
                Value<int> prixVente = const Value.absent(),
                Value<double> quantite = const Value.absent(),
                Value<String> unite = const Value.absent(),
                Value<double> seuilAlerte = const Value.absent(),
                Value<String?> photoLocale = const Value.absent(),
                Value<String?> codeBarre = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProduitsCompanion(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                categorieId: categorieId,
                nom: nom,
                prixAchat: prixAchat,
                prixVente: prixVente,
                quantite: quantite,
                unite: unite,
                seuilAlerte: seuilAlerte,
                photoLocale: photoLocale,
                codeBarre: codeBarre,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime majLe,
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                required String appareilId,
                Value<String?> categorieId = const Value.absent(),
                required String nom,
                required int prixAchat,
                required int prixVente,
                Value<double> quantite = const Value.absent(),
                required String unite,
                required double seuilAlerte,
                Value<String?> photoLocale = const Value.absent(),
                Value<String?> codeBarre = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProduitsCompanion.insert(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                categorieId: categorieId,
                nom: nom,
                prixAchat: prixAchat,
                prixVente: prixVente,
                quantite: quantite,
                unite: unite,
                seuilAlerte: seuilAlerte,
                photoLocale: photoLocale,
                codeBarre: codeBarre,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProduitsTable, Produit>(table),
                  $$ProduitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categorieId = false,
                lignesVenteRefs = false,
                mouvementsStockRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lignesVenteRefs) db.lignesVente,
                    if (mouvementsStockRefs) db.mouvementsStock,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categorieId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categorieId,
                            referencedTable: $$ProduitsTableReferences
                                ._categorieIdTable(db),
                            referencedColumn: $$ProduitsTableReferences
                                ._categorieIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lignesVenteRefs)
                        await $_getPrefetchedData<
                          Produit,
                          $ProduitsTable,
                          LigneVente
                        >(
                          currentTable: table,
                          referencedTable: $$ProduitsTableReferences
                              ._lignesVenteRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProduitsTableReferences(
                                db,
                                table,
                                p0,
                              ).lignesVenteRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.produitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mouvementsStockRefs)
                        await $_getPrefetchedData<
                          Produit,
                          $ProduitsTable,
                          MouvementStock
                        >(
                          currentTable: table,
                          referencedTable: $$ProduitsTableReferences
                              ._mouvementsStockRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProduitsTableReferences(
                                db,
                                table,
                                p0,
                              ).mouvementsStockRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.produitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProduitsTableProcessedTableManager =
    ProcessedTableManager<
      _$KassaDatabase,
      $ProduitsTable,
      Produit,
      $$ProduitsTableFilterComposer,
      $$ProduitsTableOrderingComposer,
      $$ProduitsTableAnnotationComposer,
      $$ProduitsTableCreateCompanionBuilder,
      $$ProduitsTableUpdateCompanionBuilder,
      (Produit, $$ProduitsTableReferences),
      Produit,
      PrefetchHooks Function({
        bool categorieId,
        bool lignesVenteRefs,
        bool mouvementsStockRefs,
      })
    >;
typedef $$ClientsTableCreateCompanionBuilder = ClientsCompanion Function({
  required String id,
  required DateTime majLe,
  Value<DateTime?> supprimeLe,
  Value<bool> synchro,
  required String appareilId,
  required String nom,
  Value<String?> telephone,
  Value<int> soldeDette,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$ClientsTableUpdateCompanionBuilder = ClientsCompanion Function({
  Value<String> id,
  Value<DateTime> majLe,
  Value<DateTime?> supprimeLe,
  Value<bool> synchro,
  Value<String> appareilId,
  Value<String> nom,
  Value<String?> telephone,
  Value<int> soldeDette,
  Value<String?> note,
  Value<int> rowid,
});

final class $$ClientsTableReferences
    extends BaseReferences<_$KassaDatabase, $ClientsTable, Client> {
  $$ClientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VentesTable, List<Vente>> _ventesRefsTable(
    _$KassaDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ventes,
    aliasName: 'clients__id__ventes__client_id',
  );

  $$VentesTableProcessedTableManager get ventesRefs {
    final manager = $$VentesTableTableManager(
      $_db,
      $_db.ventes,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ventesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VersementsDetteTable, List<VersementDette>>
  _versementsDetteRefsTable(_$KassaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.versementsDette,
        aliasName: 'clients__id__versements_dette__client_id',
      );

  $$VersementsDetteTableProcessedTableManager get versementsDetteRefs {
    final manager = $$VersementsDetteTableTableManager(
      $_db,
      $_db.versementsDette,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _versementsDetteRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientsTableFilterComposer
    extends Composer<_$KassaDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get soldeDette => $composableBuilder(
    column: $table.soldeDette,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ventesRefs(
    Expression<bool> Function($$VentesTableFilterComposer f) f,
  ) {
    final $$VentesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventes,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentesTableFilterComposer(
            $db: $db,
            $table: $db.ventes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> versementsDetteRefs(
    Expression<bool> Function($$VersementsDetteTableFilterComposer f) f,
  ) {
    final $$VersementsDetteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.versementsDette,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersementsDetteTableFilterComposer(
            $db: $db,
            $table: $db.versementsDette,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableOrderingComposer
    extends Composer<_$KassaDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telephone => $composableBuilder(
    column: $table.telephone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get soldeDette => $composableBuilder(
    column: $table.soldeDette,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$KassaDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => column);

  GeneratedColumn<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synchro =>
      $composableBuilder(column: $table.synchro, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get telephone =>
      $composableBuilder(column: $table.telephone, builder: (column) => column);

  GeneratedColumn<int> get soldeDette => $composableBuilder(
    column: $table.soldeDette,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  Expression<T> ventesRefs<T extends Object>(
    Expression<T> Function($$VentesTableAnnotationComposer a) f,
  ) {
    final $$VentesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventes,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentesTableAnnotationComposer(
            $db: $db,
            $table: $db.ventes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> versementsDetteRefs<T extends Object>(
    Expression<T> Function($$VersementsDetteTableAnnotationComposer a) f,
  ) {
    final $$VersementsDetteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.versementsDette,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersementsDetteTableAnnotationComposer(
            $db: $db,
            $table: $db.versementsDette,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableTableManager
    extends
        RootTableManager<
          _$KassaDatabase,
          $ClientsTable,
          Client,
          $$ClientsTableFilterComposer,
          $$ClientsTableOrderingComposer,
          $$ClientsTableAnnotationComposer,
          $$ClientsTableCreateCompanionBuilder,
          $$ClientsTableUpdateCompanionBuilder,
          (Client, $$ClientsTableReferences),
          Client,
          PrefetchHooks Function({bool ventesRefs, bool versementsDetteRefs})
        > {
  $$ClientsTableTableManager(_$KassaDatabase db, $ClientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                Value<String> appareilId = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<String?> telephone = const Value.absent(),
                Value<int> soldeDette = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                nom: nom,
                telephone: telephone,
                soldeDette: soldeDette,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime majLe,
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                required String appareilId,
                required String nom,
                Value<String?> telephone = const Value.absent(),
                Value<int> soldeDette = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion.insert(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                nom: nom,
                telephone: telephone,
                soldeDette: soldeDette,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClientsTable, Client>(table),
                  $$ClientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ventesRefs = false, versementsDetteRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ventesRefs) db.ventes,
                    if (versementsDetteRefs) db.versementsDette,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ventesRefs)
                        await $_getPrefetchedData<Client, $ClientsTable, Vente>(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._ventesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).ventesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (versementsDetteRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          VersementDette
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._versementsDetteRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).versementsDetteRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClientsTableProcessedTableManager =
    ProcessedTableManager<
      _$KassaDatabase,
      $ClientsTable,
      Client,
      $$ClientsTableFilterComposer,
      $$ClientsTableOrderingComposer,
      $$ClientsTableAnnotationComposer,
      $$ClientsTableCreateCompanionBuilder,
      $$ClientsTableUpdateCompanionBuilder,
      (Client, $$ClientsTableReferences),
      Client,
      PrefetchHooks Function({bool ventesRefs, bool versementsDetteRefs})
    >;
typedef $$VentesTableCreateCompanionBuilder = VentesCompanion Function({
  required String id,
  required DateTime majLe,
  Value<DateTime?> supprimeLe,
  Value<bool> synchro,
  required String appareilId,
  required int numero,
  Value<String?> clientId,
  required String utilisateurId,
  required int total,
  required int montantPaye,
  required int resteAPayer,
  required String modePaiement,
  required int benefice,
  required DateTime dateVente,
  Value<bool> annulee,
  Value<int> rowid,
});
typedef $$VentesTableUpdateCompanionBuilder = VentesCompanion Function({
  Value<String> id,
  Value<DateTime> majLe,
  Value<DateTime?> supprimeLe,
  Value<bool> synchro,
  Value<String> appareilId,
  Value<int> numero,
  Value<String?> clientId,
  Value<String> utilisateurId,
  Value<int> total,
  Value<int> montantPaye,
  Value<int> resteAPayer,
  Value<String> modePaiement,
  Value<int> benefice,
  Value<DateTime> dateVente,
  Value<bool> annulee,
  Value<int> rowid,
});

final class $$VentesTableReferences
    extends BaseReferences<_$KassaDatabase, $VentesTable, Vente> {
  $$VentesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$KassaDatabase db) =>
      db.clients.createAlias('ventes__client_id__clients__id');

  $$ClientsTableProcessedTableManager? get clientId {
    final $_column = $_itemColumn<String>('client_id');
    if ($_column == null) return null;
    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UtilisateursTable _utilisateurIdTable(_$KassaDatabase db) =>
      db.utilisateurs.createAlias('ventes__utilisateur_id__utilisateurs__id');

  $$UtilisateursTableProcessedTableManager get utilisateurId {
    final $_column = $_itemColumn<String>('utilisateur_id')!;

    final manager = $$UtilisateursTableTableManager(
      $_db,
      $_db.utilisateurs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_utilisateurIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LignesVenteTable, List<LigneVente>>
  _lignesVenteRefsTable(_$KassaDatabase db) => MultiTypedResultKey.fromTable(
    db.lignesVente,
    aliasName: 'ventes__id__lignes_vente__vente_id',
  );

  $$LignesVenteTableProcessedTableManager get lignesVenteRefs {
    final manager = $$LignesVenteTableTableManager(
      $_db,
      $_db.lignesVente,
    ).filter((f) => f.venteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lignesVenteRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VentesTableFilterComposer
    extends Composer<_$KassaDatabase, $VentesTable> {
  $$VentesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montantPaye => $composableBuilder(
    column: $table.montantPaye,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resteAPayer => $composableBuilder(
    column: $table.resteAPayer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modePaiement => $composableBuilder(
    column: $table.modePaiement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get benefice => $composableBuilder(
    column: $table.benefice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateVente => $composableBuilder(
    column: $table.dateVente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get annulee => $composableBuilder(
    column: $table.annulee,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UtilisateursTableFilterComposer get utilisateurId {
    final $$UtilisateursTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utilisateurId,
      referencedTable: $db.utilisateurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtilisateursTableFilterComposer(
            $db: $db,
            $table: $db.utilisateurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lignesVenteRefs(
    Expression<bool> Function($$LignesVenteTableFilterComposer f) f,
  ) {
    final $$LignesVenteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lignesVente,
      getReferencedColumn: (t) => t.venteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LignesVenteTableFilterComposer(
            $db: $db,
            $table: $db.lignesVente,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VentesTableOrderingComposer
    extends Composer<_$KassaDatabase, $VentesTable> {
  $$VentesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montantPaye => $composableBuilder(
    column: $table.montantPaye,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resteAPayer => $composableBuilder(
    column: $table.resteAPayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modePaiement => $composableBuilder(
    column: $table.modePaiement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get benefice => $composableBuilder(
    column: $table.benefice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateVente => $composableBuilder(
    column: $table.dateVente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get annulee => $composableBuilder(
    column: $table.annulee,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UtilisateursTableOrderingComposer get utilisateurId {
    final $$UtilisateursTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utilisateurId,
      referencedTable: $db.utilisateurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtilisateursTableOrderingComposer(
            $db: $db,
            $table: $db.utilisateurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VentesTableAnnotationComposer
    extends Composer<_$KassaDatabase, $VentesTable> {
  $$VentesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => column);

  GeneratedColumn<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synchro =>
      $composableBuilder(column: $table.synchro, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get montantPaye => $composableBuilder(
    column: $table.montantPaye,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resteAPayer => $composableBuilder(
    column: $table.resteAPayer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modePaiement => $composableBuilder(
    column: $table.modePaiement,
    builder: (column) => column,
  );

  GeneratedColumn<int> get benefice =>
      $composableBuilder(column: $table.benefice, builder: (column) => column);

  GeneratedColumn<DateTime> get dateVente =>
      $composableBuilder(column: $table.dateVente, builder: (column) => column);

  GeneratedColumn<bool> get annulee =>
      $composableBuilder(column: $table.annulee, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UtilisateursTableAnnotationComposer get utilisateurId {
    final $$UtilisateursTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.utilisateurId,
      referencedTable: $db.utilisateurs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtilisateursTableAnnotationComposer(
            $db: $db,
            $table: $db.utilisateurs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lignesVenteRefs<T extends Object>(
    Expression<T> Function($$LignesVenteTableAnnotationComposer a) f,
  ) {
    final $$LignesVenteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lignesVente,
      getReferencedColumn: (t) => t.venteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LignesVenteTableAnnotationComposer(
            $db: $db,
            $table: $db.lignesVente,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VentesTableTableManager
    extends
        RootTableManager<
          _$KassaDatabase,
          $VentesTable,
          Vente,
          $$VentesTableFilterComposer,
          $$VentesTableOrderingComposer,
          $$VentesTableAnnotationComposer,
          $$VentesTableCreateCompanionBuilder,
          $$VentesTableUpdateCompanionBuilder,
          (Vente, $$VentesTableReferences),
          Vente,
          PrefetchHooks Function({
            bool clientId,
            bool utilisateurId,
            bool lignesVenteRefs,
          })
        > {
  $$VentesTableTableManager(_$KassaDatabase db, $VentesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                Value<String> appareilId = const Value.absent(),
                Value<int> numero = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<String> utilisateurId = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> montantPaye = const Value.absent(),
                Value<int> resteAPayer = const Value.absent(),
                Value<String> modePaiement = const Value.absent(),
                Value<int> benefice = const Value.absent(),
                Value<DateTime> dateVente = const Value.absent(),
                Value<bool> annulee = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentesCompanion(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                numero: numero,
                clientId: clientId,
                utilisateurId: utilisateurId,
                total: total,
                montantPaye: montantPaye,
                resteAPayer: resteAPayer,
                modePaiement: modePaiement,
                benefice: benefice,
                dateVente: dateVente,
                annulee: annulee,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime majLe,
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                required String appareilId,
                required int numero,
                Value<String?> clientId = const Value.absent(),
                required String utilisateurId,
                required int total,
                required int montantPaye,
                required int resteAPayer,
                required String modePaiement,
                required int benefice,
                required DateTime dateVente,
                Value<bool> annulee = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentesCompanion.insert(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                numero: numero,
                clientId: clientId,
                utilisateurId: utilisateurId,
                total: total,
                montantPaye: montantPaye,
                resteAPayer: resteAPayer,
                modePaiement: modePaiement,
                benefice: benefice,
                dateVente: dateVente,
                annulee: annulee,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VentesTable, Vente>(table),
                  $$VentesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clientId = false,
                utilisateurId = false,
                lignesVenteRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lignesVenteRefs) db.lignesVente,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clientId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.clientId,
                            referencedTable: $$VentesTableReferences
                                ._clientIdTable(db),
                            referencedColumn: $$VentesTableReferences
                                ._clientIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (utilisateurId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.utilisateurId,
                            referencedTable: $$VentesTableReferences
                                ._utilisateurIdTable(db),
                            referencedColumn: $$VentesTableReferences
                                ._utilisateurIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lignesVenteRefs)
                        await $_getPrefetchedData<
                          Vente,
                          $VentesTable,
                          LigneVente
                        >(
                          currentTable: table,
                          referencedTable: $$VentesTableReferences
                              ._lignesVenteRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VentesTableReferences(
                                db,
                                table,
                                p0,
                              ).lignesVenteRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.venteId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VentesTableProcessedTableManager =
    ProcessedTableManager<
      _$KassaDatabase,
      $VentesTable,
      Vente,
      $$VentesTableFilterComposer,
      $$VentesTableOrderingComposer,
      $$VentesTableAnnotationComposer,
      $$VentesTableCreateCompanionBuilder,
      $$VentesTableUpdateCompanionBuilder,
      (Vente, $$VentesTableReferences),
      Vente,
      PrefetchHooks Function({
        bool clientId,
        bool utilisateurId,
        bool lignesVenteRefs,
      })
    >;
typedef $$LignesVenteTableCreateCompanionBuilder =
    LignesVenteCompanion Function({
      required String id,
      required DateTime majLe,
      Value<DateTime?> supprimeLe,
      Value<bool> synchro,
      required String appareilId,
      required String venteId,
      required String produitId,
      required String nomProduit,
      required double quantite,
      required int prixUnitaire,
      required int prixAchatUnitaire,
      Value<int> rowid,
    });
typedef $$LignesVenteTableUpdateCompanionBuilder =
    LignesVenteCompanion Function({
      Value<String> id,
      Value<DateTime> majLe,
      Value<DateTime?> supprimeLe,
      Value<bool> synchro,
      Value<String> appareilId,
      Value<String> venteId,
      Value<String> produitId,
      Value<String> nomProduit,
      Value<double> quantite,
      Value<int> prixUnitaire,
      Value<int> prixAchatUnitaire,
      Value<int> rowid,
    });

final class $$LignesVenteTableReferences
    extends BaseReferences<_$KassaDatabase, $LignesVenteTable, LigneVente> {
  $$LignesVenteTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VentesTable _venteIdTable(_$KassaDatabase db) =>
      db.ventes.createAlias('lignes_vente__vente_id__ventes__id');

  $$VentesTableProcessedTableManager get venteId {
    final $_column = $_itemColumn<String>('vente_id')!;

    final manager = $$VentesTableTableManager(
      $_db,
      $_db.ventes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_venteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProduitsTable _produitIdTable(_$KassaDatabase db) =>
      db.produits.createAlias('lignes_vente__produit_id__produits__id');

  $$ProduitsTableProcessedTableManager get produitId {
    final $_column = $_itemColumn<String>('produit_id')!;

    final manager = $$ProduitsTableTableManager(
      $_db,
      $_db.produits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LignesVenteTableFilterComposer
    extends Composer<_$KassaDatabase, $LignesVenteTable> {
  $$LignesVenteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomProduit => $composableBuilder(
    column: $table.nomProduit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prixUnitaire => $composableBuilder(
    column: $table.prixUnitaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prixAchatUnitaire => $composableBuilder(
    column: $table.prixAchatUnitaire,
    builder: (column) => ColumnFilters(column),
  );

  $$VentesTableFilterComposer get venteId {
    final $$VentesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.venteId,
      referencedTable: $db.ventes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentesTableFilterComposer(
            $db: $db,
            $table: $db.ventes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableFilterComposer get produitId {
    final $$ProduitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableFilterComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LignesVenteTableOrderingComposer
    extends Composer<_$KassaDatabase, $LignesVenteTable> {
  $$LignesVenteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomProduit => $composableBuilder(
    column: $table.nomProduit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prixUnitaire => $composableBuilder(
    column: $table.prixUnitaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prixAchatUnitaire => $composableBuilder(
    column: $table.prixAchatUnitaire,
    builder: (column) => ColumnOrderings(column),
  );

  $$VentesTableOrderingComposer get venteId {
    final $$VentesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.venteId,
      referencedTable: $db.ventes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentesTableOrderingComposer(
            $db: $db,
            $table: $db.ventes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableOrderingComposer get produitId {
    final $$ProduitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableOrderingComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LignesVenteTableAnnotationComposer
    extends Composer<_$KassaDatabase, $LignesVenteTable> {
  $$LignesVenteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => column);

  GeneratedColumn<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synchro =>
      $composableBuilder(column: $table.synchro, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nomProduit => $composableBuilder(
    column: $table.nomProduit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<int> get prixUnitaire => $composableBuilder(
    column: $table.prixUnitaire,
    builder: (column) => column,
  );

  GeneratedColumn<int> get prixAchatUnitaire => $composableBuilder(
    column: $table.prixAchatUnitaire,
    builder: (column) => column,
  );

  $$VentesTableAnnotationComposer get venteId {
    final $$VentesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.venteId,
      referencedTable: $db.ventes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentesTableAnnotationComposer(
            $db: $db,
            $table: $db.ventes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableAnnotationComposer get produitId {
    final $$ProduitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableAnnotationComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LignesVenteTableTableManager
    extends
        RootTableManager<
          _$KassaDatabase,
          $LignesVenteTable,
          LigneVente,
          $$LignesVenteTableFilterComposer,
          $$LignesVenteTableOrderingComposer,
          $$LignesVenteTableAnnotationComposer,
          $$LignesVenteTableCreateCompanionBuilder,
          $$LignesVenteTableUpdateCompanionBuilder,
          (LigneVente, $$LignesVenteTableReferences),
          LigneVente,
          PrefetchHooks Function({bool venteId, bool produitId})
        > {
  $$LignesVenteTableTableManager(_$KassaDatabase db, $LignesVenteTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LignesVenteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LignesVenteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LignesVenteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                Value<String> appareilId = const Value.absent(),
                Value<String> venteId = const Value.absent(),
                Value<String> produitId = const Value.absent(),
                Value<String> nomProduit = const Value.absent(),
                Value<double> quantite = const Value.absent(),
                Value<int> prixUnitaire = const Value.absent(),
                Value<int> prixAchatUnitaire = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LignesVenteCompanion(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                venteId: venteId,
                produitId: produitId,
                nomProduit: nomProduit,
                quantite: quantite,
                prixUnitaire: prixUnitaire,
                prixAchatUnitaire: prixAchatUnitaire,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime majLe,
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                required String appareilId,
                required String venteId,
                required String produitId,
                required String nomProduit,
                required double quantite,
                required int prixUnitaire,
                required int prixAchatUnitaire,
                Value<int> rowid = const Value.absent(),
              }) => LignesVenteCompanion.insert(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                venteId: venteId,
                produitId: produitId,
                nomProduit: nomProduit,
                quantite: quantite,
                prixUnitaire: prixUnitaire,
                prixAchatUnitaire: prixAchatUnitaire,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LignesVenteTable, LigneVente>(table),
                  $$LignesVenteTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({venteId = false, produitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (venteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.venteId,
                        referencedTable: $$LignesVenteTableReferences
                            ._venteIdTable(db),
                        referencedColumn: $$LignesVenteTableReferences
                            ._venteIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (produitId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.produitId,
                        referencedTable: $$LignesVenteTableReferences
                            ._produitIdTable(db),
                        referencedColumn: $$LignesVenteTableReferences
                            ._produitIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LignesVenteTableProcessedTableManager =
    ProcessedTableManager<
      _$KassaDatabase,
      $LignesVenteTable,
      LigneVente,
      $$LignesVenteTableFilterComposer,
      $$LignesVenteTableOrderingComposer,
      $$LignesVenteTableAnnotationComposer,
      $$LignesVenteTableCreateCompanionBuilder,
      $$LignesVenteTableUpdateCompanionBuilder,
      (LigneVente, $$LignesVenteTableReferences),
      LigneVente,
      PrefetchHooks Function({bool venteId, bool produitId})
    >;
typedef $$VersementsDetteTableCreateCompanionBuilder =
    VersementsDetteCompanion Function({
      required String id,
      required DateTime majLe,
      Value<DateTime?> supprimeLe,
      Value<bool> synchro,
      required String appareilId,
      required String clientId,
      required int montant,
      required String modePaiement,
      required DateTime dateVersement,
      Value<int> rowid,
    });
typedef $$VersementsDetteTableUpdateCompanionBuilder =
    VersementsDetteCompanion Function({
      Value<String> id,
      Value<DateTime> majLe,
      Value<DateTime?> supprimeLe,
      Value<bool> synchro,
      Value<String> appareilId,
      Value<String> clientId,
      Value<int> montant,
      Value<String> modePaiement,
      Value<DateTime> dateVersement,
      Value<int> rowid,
    });

final class $$VersementsDetteTableReferences
    extends
        BaseReferences<_$KassaDatabase, $VersementsDetteTable, VersementDette> {
  $$VersementsDetteTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClientsTable _clientIdTable(_$KassaDatabase db) =>
      db.clients.createAlias('versements_dette__client_id__clients__id');

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VersementsDetteTableFilterComposer
    extends Composer<_$KassaDatabase, $VersementsDetteTable> {
  $$VersementsDetteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montant => $composableBuilder(
    column: $table.montant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modePaiement => $composableBuilder(
    column: $table.modePaiement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateVersement => $composableBuilder(
    column: $table.dateVersement,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VersementsDetteTableOrderingComposer
    extends Composer<_$KassaDatabase, $VersementsDetteTable> {
  $$VersementsDetteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montant => $composableBuilder(
    column: $table.montant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modePaiement => $composableBuilder(
    column: $table.modePaiement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateVersement => $composableBuilder(
    column: $table.dateVersement,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VersementsDetteTableAnnotationComposer
    extends Composer<_$KassaDatabase, $VersementsDetteTable> {
  $$VersementsDetteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => column);

  GeneratedColumn<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synchro =>
      $composableBuilder(column: $table.synchro, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get montant =>
      $composableBuilder(column: $table.montant, builder: (column) => column);

  GeneratedColumn<String> get modePaiement => $composableBuilder(
    column: $table.modePaiement,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateVersement => $composableBuilder(
    column: $table.dateVersement,
    builder: (column) => column,
  );

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VersementsDetteTableTableManager
    extends
        RootTableManager<
          _$KassaDatabase,
          $VersementsDetteTable,
          VersementDette,
          $$VersementsDetteTableFilterComposer,
          $$VersementsDetteTableOrderingComposer,
          $$VersementsDetteTableAnnotationComposer,
          $$VersementsDetteTableCreateCompanionBuilder,
          $$VersementsDetteTableUpdateCompanionBuilder,
          (VersementDette, $$VersementsDetteTableReferences),
          VersementDette,
          PrefetchHooks Function({bool clientId})
        > {
  $$VersementsDetteTableTableManager(
    _$KassaDatabase db,
    $VersementsDetteTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersementsDetteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersementsDetteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersementsDetteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                Value<String> appareilId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<int> montant = const Value.absent(),
                Value<String> modePaiement = const Value.absent(),
                Value<DateTime> dateVersement = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VersementsDetteCompanion(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                clientId: clientId,
                montant: montant,
                modePaiement: modePaiement,
                dateVersement: dateVersement,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime majLe,
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                required String appareilId,
                required String clientId,
                required int montant,
                required String modePaiement,
                required DateTime dateVersement,
                Value<int> rowid = const Value.absent(),
              }) => VersementsDetteCompanion.insert(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                clientId: clientId,
                montant: montant,
                modePaiement: modePaiement,
                dateVersement: dateVersement,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VersementsDetteTable, VersementDette>(table),
                  $$VersementsDetteTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.clientId,
                        referencedTable: $$VersementsDetteTableReferences
                            ._clientIdTable(db),
                        referencedColumn: $$VersementsDetteTableReferences
                            ._clientIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VersementsDetteTableProcessedTableManager =
    ProcessedTableManager<
      _$KassaDatabase,
      $VersementsDetteTable,
      VersementDette,
      $$VersementsDetteTableFilterComposer,
      $$VersementsDetteTableOrderingComposer,
      $$VersementsDetteTableAnnotationComposer,
      $$VersementsDetteTableCreateCompanionBuilder,
      $$VersementsDetteTableUpdateCompanionBuilder,
      (VersementDette, $$VersementsDetteTableReferences),
      VersementDette,
      PrefetchHooks Function({bool clientId})
    >;
typedef $$MouvementsStockTableCreateCompanionBuilder =
    MouvementsStockCompanion Function({
      required String id,
      required DateTime majLe,
      Value<DateTime?> supprimeLe,
      Value<bool> synchro,
      required String appareilId,
      required String produitId,
      required String type,
      required double quantite,
      Value<int?> prixAchatUnitaire,
      Value<String?> referenceId,
      required DateTime dateMouvement,
      Value<int> rowid,
    });
typedef $$MouvementsStockTableUpdateCompanionBuilder =
    MouvementsStockCompanion Function({
      Value<String> id,
      Value<DateTime> majLe,
      Value<DateTime?> supprimeLe,
      Value<bool> synchro,
      Value<String> appareilId,
      Value<String> produitId,
      Value<String> type,
      Value<double> quantite,
      Value<int?> prixAchatUnitaire,
      Value<String?> referenceId,
      Value<DateTime> dateMouvement,
      Value<int> rowid,
    });

final class $$MouvementsStockTableReferences
    extends
        BaseReferences<_$KassaDatabase, $MouvementsStockTable, MouvementStock> {
  $$MouvementsStockTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProduitsTable _produitIdTable(_$KassaDatabase db) =>
      db.produits.createAlias('mouvements_stock__produit_id__produits__id');

  $$ProduitsTableProcessedTableManager get produitId {
    final $_column = $_itemColumn<String>('produit_id')!;

    final manager = $$ProduitsTableTableManager(
      $_db,
      $_db.produits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MouvementsStockTableFilterComposer
    extends Composer<_$KassaDatabase, $MouvementsStockTable> {
  $$MouvementsStockTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prixAchatUnitaire => $composableBuilder(
    column: $table.prixAchatUnitaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateMouvement => $composableBuilder(
    column: $table.dateMouvement,
    builder: (column) => ColumnFilters(column),
  );

  $$ProduitsTableFilterComposer get produitId {
    final $$ProduitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableFilterComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MouvementsStockTableOrderingComposer
    extends Composer<_$KassaDatabase, $MouvementsStockTable> {
  $$MouvementsStockTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchro => $composableBuilder(
    column: $table.synchro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prixAchatUnitaire => $composableBuilder(
    column: $table.prixAchatUnitaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateMouvement => $composableBuilder(
    column: $table.dateMouvement,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProduitsTableOrderingComposer get produitId {
    final $$ProduitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableOrderingComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MouvementsStockTableAnnotationComposer
    extends Composer<_$KassaDatabase, $MouvementsStockTable> {
  $$MouvementsStockTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => column);

  GeneratedColumn<DateTime> get supprimeLe => $composableBuilder(
    column: $table.supprimeLe,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synchro =>
      $composableBuilder(column: $table.synchro, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
    column: $table.appareilId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<int> get prixAchatUnitaire => $composableBuilder(
    column: $table.prixAchatUnitaire,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateMouvement => $composableBuilder(
    column: $table.dateMouvement,
    builder: (column) => column,
  );

  $$ProduitsTableAnnotationComposer get produitId {
    final $$ProduitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableAnnotationComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MouvementsStockTableTableManager
    extends
        RootTableManager<
          _$KassaDatabase,
          $MouvementsStockTable,
          MouvementStock,
          $$MouvementsStockTableFilterComposer,
          $$MouvementsStockTableOrderingComposer,
          $$MouvementsStockTableAnnotationComposer,
          $$MouvementsStockTableCreateCompanionBuilder,
          $$MouvementsStockTableUpdateCompanionBuilder,
          (MouvementStock, $$MouvementsStockTableReferences),
          MouvementStock,
          PrefetchHooks Function({bool produitId})
        > {
  $$MouvementsStockTableTableManager(
    _$KassaDatabase db,
    $MouvementsStockTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MouvementsStockTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MouvementsStockTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MouvementsStockTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                Value<String> appareilId = const Value.absent(),
                Value<String> produitId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> quantite = const Value.absent(),
                Value<int?> prixAchatUnitaire = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<DateTime> dateMouvement = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MouvementsStockCompanion(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                produitId: produitId,
                type: type,
                quantite: quantite,
                prixAchatUnitaire: prixAchatUnitaire,
                referenceId: referenceId,
                dateMouvement: dateMouvement,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime majLe,
                Value<DateTime?> supprimeLe = const Value.absent(),
                Value<bool> synchro = const Value.absent(),
                required String appareilId,
                required String produitId,
                required String type,
                required double quantite,
                Value<int?> prixAchatUnitaire = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                required DateTime dateMouvement,
                Value<int> rowid = const Value.absent(),
              }) => MouvementsStockCompanion.insert(
                id: id,
                majLe: majLe,
                supprimeLe: supprimeLe,
                synchro: synchro,
                appareilId: appareilId,
                produitId: produitId,
                type: type,
                quantite: quantite,
                prixAchatUnitaire: prixAchatUnitaire,
                referenceId: referenceId,
                dateMouvement: dateMouvement,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MouvementsStockTable, MouvementStock>(table),
                  $$MouvementsStockTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({produitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (produitId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.produitId,
                        referencedTable: $$MouvementsStockTableReferences
                            ._produitIdTable(db),
                        referencedColumn: $$MouvementsStockTableReferences
                            ._produitIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MouvementsStockTableProcessedTableManager =
    ProcessedTableManager<
      _$KassaDatabase,
      $MouvementsStockTable,
      MouvementStock,
      $$MouvementsStockTableFilterComposer,
      $$MouvementsStockTableOrderingComposer,
      $$MouvementsStockTableAnnotationComposer,
      $$MouvementsStockTableCreateCompanionBuilder,
      $$MouvementsStockTableUpdateCompanionBuilder,
      (MouvementStock, $$MouvementsStockTableReferences),
      MouvementStock,
      PrefetchHooks Function({bool produitId})
    >;

class $KassaDatabaseManager {
  final _$KassaDatabase _db;
  $KassaDatabaseManager(this._db);
  $$BoutiquesTableTableManager get boutiques =>
      $$BoutiquesTableTableManager(_db, _db.boutiques);
  $$UtilisateursTableTableManager get utilisateurs =>
      $$UtilisateursTableTableManager(_db, _db.utilisateurs);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProduitsTableTableManager get produits =>
      $$ProduitsTableTableManager(_db, _db.produits);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$VentesTableTableManager get ventes =>
      $$VentesTableTableManager(_db, _db.ventes);
  $$LignesVenteTableTableManager get lignesVente =>
      $$LignesVenteTableTableManager(_db, _db.lignesVente);
  $$VersementsDetteTableTableManager get versementsDette =>
      $$VersementsDetteTableTableManager(_db, _db.versementsDette);
  $$MouvementsStockTableTableManager get mouvementsStock =>
      $$MouvementsStockTableTableManager(_db, _db.mouvementsStock);
}
