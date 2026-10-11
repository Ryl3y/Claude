import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../data/repositories/compte_repository.dart';
import '../../../data/lieux/service_lieux.dart';
import '../../../domain/code_pin.dart';
import '../../../domain/lieux.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/lieux.dart';
import '../../state/session.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/choix_lieu.dart';
import '../../widgets/types_commerce.dart';
import '../../widgets/widgets.dart';

export '../../widgets/types_commerce.dart';

/// Écran 3 : création de la boutique (nom, type, lieu guidé : région,
/// département, arrondissement, ville ou village, quartier) et du code PIN
/// à 4 chiffres.
class BoutiqueScreen extends ConsumerStatefulWidget {
  const BoutiqueScreen({super.key});

  @override
  ConsumerState<BoutiqueScreen> createState() => _BoutiqueScreenState();
}

enum _Champ { nom, pin, confirmation }

class _BoutiqueScreenState extends ConsumerState<BoutiqueScreen> {
  final _nom = TextEditingController();
  final _pin = TextEditingController();
  final _confirmation = TextEditingController();
  var _type = TypesCommerce.alimentation;
  var _lieu = const LieuChoisi();
  Map<_Champ, String> _erreurs = const {};
  Map<ChampLieu, String> _erreursLieu = const {};
  var _enCours = false;

  @override
  void dispose() {
    for (final c in [_nom, _pin, _confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<_Champ, String> _verifier(AppLocalizations l) => {
    if (_nom.text.trim().isEmpty) _Champ.nom: l.errShopName,
    if (!CodePin.estValide(_pin.text)) _Champ.pin: l.errPinFormat,
    if (CodePin.estValide(_pin.text) && _confirmation.text != _pin.text)
      _Champ.confirmation: l.errPinMismatch,
  };

  Future<void> _creer() async {
    final l = AppLocalizations.of(context);
    if (_enCours) return;
    final erreurs = _verifier(l);
    final erreursLieu = verifierLieu(l, _lieu);
    setState(() {
      _erreurs = erreurs;
      _erreursLieu = erreursLieu;
    });
    if (erreurs.isNotEmpty || erreursLieu.isNotEmpty) {
      if (erreurs.containsKey(_Champ.confirmation)) {
        _pin.clear();
        _confirmation.clear();
      }
      return;
    }
    final inscription = ref.read(inscriptionProvider);
    if (inscription == null) return;
    setState(() => _enCours = true);
    // Un village ou un quartier nouveau rejoint d'abord la liste partagée.
    final LieuChoisi lieu;
    try {
      lieu = await enregistrerLieu(ref.read(serviceLieuxProvider), _lieu);
    } on LieuRefuse catch (e) {
      if (!mounted) return;
      final message = e.raison == RefusLieu.tropDAjouts
          ? l.errLieuTrop
          : l.errLieuNom;
      setState(() {
        _enCours = false;
        _erreursLieu = {
          e.surQuartier ? ChampLieu.quartier : ChampLieu.localite: message,
        };
      });
      return;
    }
    try {
      final compte = await inscription.creerBoutique(
        BoutiqueSaisie(
          nom: _nom.text,
          typeCommerce: _type,
          ville: nomLieu(lieu.localite!.nom),
          quartier: nomLieu(lieu.quartier!.nom),
          arrondissement: lieu.arrondissement,
          localiteId: lieu.localite!.id,
          quartierId: lieu.quartier!.id,
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
              ChoixLieu(
                lieu: _lieu,
                erreurs: _erreursLieu,
                onChanged: (lieu) => setState(() {
                  _lieu = lieu;
                  _erreursLieu = const {};
                }),
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
