import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../data/repositories/compte_repository.dart';
import '../../../domain/code_pin.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/session.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/widgets.dart';

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

/// Écran 3 : création de la boutique (nom, type, ville, quartier) et du
/// code PIN à 4 chiffres.
class BoutiqueScreen extends ConsumerStatefulWidget {
  const BoutiqueScreen({super.key});

  @override
  ConsumerState<BoutiqueScreen> createState() => _BoutiqueScreenState();
}

enum _Champ { nom, ville, quartier, pin, confirmation }

class _BoutiqueScreenState extends ConsumerState<BoutiqueScreen> {
  final _nom = TextEditingController();
  final _ville = TextEditingController();
  final _quartier = TextEditingController();
  final _pin = TextEditingController();
  final _confirmation = TextEditingController();
  var _type = TypesCommerce.alimentation;
  Map<_Champ, String> _erreurs = const {};
  var _enCours = false;

  @override
  void dispose() {
    for (final c in [_nom, _ville, _quartier, _pin, _confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<_Champ, String> _verifier(AppLocalizations l) => {
    if (_nom.text.trim().isEmpty) _Champ.nom: l.errShopName,
    if (_ville.text.trim().isEmpty) _Champ.ville: l.errCity,
    if (_quartier.text.trim().isEmpty) _Champ.quartier: l.errDistrict,
    if (!CodePin.estValide(_pin.text)) _Champ.pin: l.errPinFormat,
    if (CodePin.estValide(_pin.text) && _confirmation.text != _pin.text)
      _Champ.confirmation: l.errPinMismatch,
  };

  Future<void> _creer() async {
    final l = AppLocalizations.of(context);
    if (_enCours) return;
    final erreurs = _verifier(l);
    setState(() => _erreurs = erreurs);
    if (erreurs.isNotEmpty) {
      if (erreurs.containsKey(_Champ.confirmation)) {
        _pin.clear();
        _confirmation.clear();
      }
      return;
    }
    final inscription = ref.read(inscriptionProvider);
    if (inscription == null) return;
    setState(() => _enCours = true);
    try {
      final compte = await inscription.creerBoutique(
        BoutiqueSaisie(
          nom: _nom.text,
          typeCommerce: _type,
          ville: _ville.text,
          quartier: _quartier.text,
        ),
        _pin.text,
      );
      if (!mounted) return;
      ref.read(sessionProvider.notifier).ouvrir(compte);
      context.go(Chemins.accueil);
    } on Object {
      if (!mounted) return;
      setState(() => _enCours = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.saveError)));
    }
  }

  void _effacerErreur(_Champ c) {
    if (_erreurs.containsKey(c)) {
      setState(() => _erreurs = {..._erreurs}..remove(c));
    }
  }

  Widget _champ({
    required _Champ champ,
    required TextEditingController controleur,
    required String libelle,
    String? exemple,
    String? aide,
    bool pin = false,
    bool premier = false,
  }) => TextField(
    controller: controleur,
    autofocus: premier,
    obscureText: pin,
    keyboardType: pin ? TextInputType.number : TextInputType.text,
    textCapitalization: pin
        ? TextCapitalization.none
        : TextCapitalization.words,
    textInputAction: champ == _Champ.confirmation
        ? TextInputAction.done
        : TextInputAction.next,
    maxLength: pin ? CodePin.longueur : null,
    inputFormatters: pin ? [FilteringTextInputFormatter.digitsOnly] : null,
    onChanged: (_) => _effacerErreur(champ),
    onSubmitted: champ == _Champ.confirmation ? (_) => _creer() : null,
    decoration: InputDecoration(
      labelText: libelle,
      hintText: exemple,
      helperText: aide,
      helperMaxLines: 3,
      errorText: _erreurs[champ],
      errorMaxLines: 3,
      counterText: '',
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;

    return Scaffold(
      appBar: AppBar(title: Text(l.shopTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: ListView(
            padding: const EdgeInsets.all(KassaSpace.s4),
            children: [
              Text(l.shopBody, style: t.body.copyWith(color: t.inkMuted)),
              const SizedBox(height: KassaSpace.s6),
              _champ(
                champ: _Champ.nom,
                controleur: _nom,
                libelle: l.shopName,
                exemple: l.shopNameHint,
                premier: true,
              ),
              const SizedBox(height: KassaSpace.s4),
              DropdownButtonFormField<String>(
                initialValue: _type,
                isExpanded: true,
                icon: const Icon(Symbols.expand_more_rounded),
                decoration: InputDecoration(labelText: l.shopType),
                items: [
                  for (final code in TypesCommerce.tous)
                    DropdownMenuItem(
                      value: code,
                      child: Text(TypesCommerce.libelle(l, code)),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
              ),
              const SizedBox(height: KassaSpace.s4),
              _champ(
                champ: _Champ.ville,
                controleur: _ville,
                libelle: l.city,
                exemple: l.cityHint,
              ),
              const SizedBox(height: KassaSpace.s4),
              _champ(
                champ: _Champ.quartier,
                controleur: _quartier,
                libelle: l.district,
                exemple: l.districtHint,
              ),
              const SizedBox(height: KassaSpace.s6),
              _champ(
                champ: _Champ.pin,
                controleur: _pin,
                libelle: l.pinChoose,
                aide: l.pinChooseHint,
                pin: true,
              ),
              const SizedBox(height: KassaSpace.s4),
              _champ(
                champ: _Champ.confirmation,
                controleur: _confirmation,
                libelle: l.pinConfirm,
                pin: true,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: KassaButton(
          label: l.createShop,
          icon: Symbols.storefront_rounded,
          size: KassaButtonSize.main,
          fullWidth: true,
          onPressed: _enCours ? null : _creer,
        ),
      ),
    );
  }
}
