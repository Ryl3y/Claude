import '../../l10n/generated/app_localizations.dart';

/// Types de commerce proposés (code enregistré, libellé traduit).
abstract final class TypesCommerce {
  static const alimentation = 'alimentation';
  static const tous = [
    alimentation,
    'quartier',
    'quincaillerie',
    'cosmetiques',
    'vetements',
    'telephones',
    'autre',
  ];

  static String libelle(AppLocalizations l, String code) => switch (code) {
    'alimentation' => l.typeFood,
    'quartier' => l.typeNeighborhood,
    'quincaillerie' => l.typeHardware,
    'cosmetiques' => l.typeBeauty,
    'vetements' => l.typeClothes,
    'telephones' => l.typePhones,
    _ => l.typeOther,
  };
}
