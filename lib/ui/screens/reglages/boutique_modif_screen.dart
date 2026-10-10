import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../data/db/kassa_database.dart';
import '../../../domain/boutique_saisie.dart';
import '../../../data/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../state/session.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/widgets.dart';
import '../inscription/boutique_screen.dart';

/// Modifier la boutique depuis Réglages : nom, type, ville, quartier et
/// alerte de stock bas proposée aux nouveaux produits.
class BoutiqueModifScreen extends ConsumerStatefulWidget {
  const BoutiqueModifScreen({super.key});

  @override
  ConsumerState<BoutiqueModifScreen> createState() =>
      _BoutiqueModifScreenState();
}

enum _Champ { nom, ville, quartier, seuil }

bool _seuilValide(String texte) {
  final n = int.tryParse(texte.trim());
  return n != null && n >= 0 && n <= seuilAlerteDefautMax;
}

class _BoutiqueModifScreenState extends ConsumerState<BoutiqueModifScreen> {
  final _nom = TextEditingController();
  final _ville = TextEditingController();
  final _quartier = TextEditingController();
  final _seuil = TextEditingController();
  var _type = TypesCommerce.alimentation;
  String? _boutiqueId;
  Map<_Champ, String> _erreurs = const {};
  var _enCours = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final s = ref.read(sessionProvider);
    if (s is! SessionOuverte) return;
    final b = await ref
        .read(boutiqueRepositoryProvider)
        .surveillerBoutique(s.compte.boutiqueId)
        .first;
    if (b == null || !mounted) return;
    setState(() => _remplir(b));
  }

  void _remplir(Boutique b) {
    _boutiqueId = b.id;
    _nom.text = b.nom;
    _ville.text = b.ville;
    _quartier.text = b.quartier;
    _seuil.text = '${b.seuilAlerteDefaut}';
    // Un type inconnu de cette version est gardé tel quel (pas écrasé).
    _type = b.typeCommerce;
  }

  @override
  void dispose() {
    for (final c in [_nom, _ville, _quartier, _seuil]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<_Champ, String> _verifier(AppLocalizations l) => {
    if (_nom.text.trim().isEmpty) _Champ.nom: l.errShopName,
    if (_ville.text.trim().isEmpty) _Champ.ville: l.errCity,
    if (_quartier.text.trim().isEmpty) _Champ.quartier: l.errDistrict,
    if (!_seuilValide(_seuil.text)) _Champ.seuil: l.errThreshold,
  };

  Future<void> _enregistrer() async {
    final l = AppLocalizations.of(context);
    final id = _boutiqueId;
    if (_enCours || id == null) return;
    final erreurs = _verifier(l);
    setState(() => _erreurs = erreurs);
    if (erreurs.isNotEmpty) return;
    setState(() => _enCours = true);
    final messager = ScaffoldMessenger.of(context);
    final navigateur = Navigator.of(context);
    try {
      await ref
          .read(boutiqueRepositoryProvider)
          .modifierBoutique(
            id,
            saisie: BoutiqueSaisie(
              nom: _nom.text,
              typeCommerce: _type,
              ville: _ville.text,
              quartier: _quartier.text,
            ),
            seuilAlerteDefaut: int.parse(_seuil.text.trim()),
          );
      messager.showSnackBar(SnackBar(content: Text(l.shopSaved)));
      if (!await navigateur.maybePop() && mounted) {
        setState(() => _enCours = false);
      }
    } on Object {
      if (!mounted) return;
      setState(() => _enCours = false);
      messager.showSnackBar(SnackBar(content: Text(l.saveError)));
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
  }) {
    final nombre = champ == _Champ.seuil;
    return TextField(
      controller: controleur,
      keyboardType: nombre ? TextInputType.number : TextInputType.text,
      textCapitalization: nombre
          ? TextCapitalization.none
          : TextCapitalization.words,
      inputFormatters: nombre ? [FilteringTextInputFormatter.digitsOnly] : null,
      textInputAction: nombre ? TextInputAction.done : TextInputAction.next,
      onChanged: (_) => _effacerErreur(champ),
      onSubmitted: nombre ? (_) => _enregistrer() : null,
      decoration: InputDecoration(
        labelText: libelle,
        hintText: exemple,
        helperText: aide,
        helperMaxLines: 3,
        errorText: _erreurs[champ],
        errorMaxLines: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.shopEditTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: ListView(
            padding: const EdgeInsets.all(KassaSpace.s4),
            children: [
              _champ(
                champ: _Champ.nom,
                controleur: _nom,
                libelle: l.shopName,
                exemple: l.shopNameHint,
              ),
              const SizedBox(height: KassaSpace.s4),
              DropdownButtonFormField<String>(
                key: ValueKey(_boutiqueId),
                initialValue: _type,
                isExpanded: true,
                icon: const Icon(Symbols.expand_more_rounded),
                decoration: InputDecoration(labelText: l.shopType),
                items: [
                  for (final code in {...TypesCommerce.tous, _type})
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
              const SizedBox(height: KassaSpace.s4),
              _champ(
                champ: _Champ.seuil,
                controleur: _seuil,
                libelle: l.shopThreshold,
                aide: l.shopThresholdHelp,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: KassaButton(
          label: l.save,
          icon: Symbols.check_rounded,
          size: KassaButtonSize.main,
          fullWidth: true,
          onPressed: _enCours || _boutiqueId == null ? null : _enregistrer,
        ),
      ),
    );
  }
}
