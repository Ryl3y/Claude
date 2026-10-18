import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../data/db/kassa_database.dart';
import '../../../data/lieux/service_lieux.dart';
import '../../../domain/lieux.dart';
import '../../../domain/boutique_saisie.dart';
import '../../../data/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../state/lieux.dart';
import '../../state/session.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/choix_lieu.dart';
import '../../widgets/widgets.dart';
import '../inscription/boutique_screen.dart';

/// Modifier la boutique depuis Réglages : nom, type, lieu guidé (comme à
/// la création) et alerte de stock bas proposée aux nouveaux produits.
class BoutiqueModifScreen extends ConsumerStatefulWidget {
  const BoutiqueModifScreen({super.key});

  @override
  ConsumerState<BoutiqueModifScreen> createState() =>
      _BoutiqueModifScreenState();
}

enum _Champ { nom, seuil }

bool _seuilValide(String texte) {
  final n = int.tryParse(texte.trim());
  return n != null && n >= 0 && n <= seuilAlerteDefautMax;
}

class _BoutiqueModifScreenState extends ConsumerState<BoutiqueModifScreen> {
  final _nom = TextEditingController();
  final _seuil = TextEditingController();
  var _type = TypesCommerce.alimentation;
  String? _boutiqueId;
  Map<_Champ, String> _erreurs = const {};
  Map<ChampLieu, String> _erreursLieu = const {};

  /// Lieu affiché ; [_ancien] : ville et quartier d'une boutique créée
  /// avant le lieu guidé, gardés tant qu'on ne choisit pas de région.
  var _lieu = const LieuChoisi();
  (String, String)? _ancien;
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
    // Sans découpage (lecture impossible), la fiche s'ouvre quand même avec
    // l'adresse écrite.
    Decoupage? decoupage;
    try {
      decoupage = await ref.read(decoupageProvider.future);
    } on Object {
      decoupage = null;
    }
    if (b == null || !mounted) return;
    setState(() => _remplir(b, decoupage));
  }

  void _remplir(Boutique b, Decoupage? decoupage) {
    _boutiqueId = b.id;
    _nom.text = b.nom;
    final arr = decoupage?.arrondissement(b.arrondissement);
    final dep = decoupage?.departement(arr?.departement);
    if (arr != null && dep != null) {
      _lieu = LieuChoisi(
        region: dep.region,
        departement: dep.code,
        arrondissement: arr.code,
        localite: Lieu(b.localiteId, b.ville),
        quartier: Lieu(b.quartierId, b.quartier),
      );
    } else {
      _ancien = (b.ville, b.quartier);
    }
    _seuil.text = '${b.seuilAlerteDefaut}';
    // Un type inconnu de cette version est gardé tel quel (pas écrasé).
    _type = b.typeCommerce;
  }

  @override
  void dispose() {
    for (final c in [_nom, _seuil]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<_Champ, String> _verifier(AppLocalizations l) => {
    if (_nom.text.trim().isEmpty) _Champ.nom: l.errShopName,
    if (!_seuilValide(_seuil.text)) _Champ.seuil: l.errThreshold,
  };

  Future<void> _enregistrer() async {
    final l = AppLocalizations.of(context);
    final id = _boutiqueId;
    if (_enCours || id == null) return;
    final erreurs = _verifier(l);
    // Ancienne boutique sans lieu guidé : son adresse reste valable tant
    // qu'on ne choisit pas une région.
    final garderAncien = _ancien != null && _lieu.region == null;
    final erreursLieu = garderAncien
        ? const <ChampLieu, String>{}
        : verifierLieu(l, _lieu);
    setState(() {
      _erreurs = erreurs;
      _erreursLieu = erreursLieu;
    });
    if (erreurs.isNotEmpty || erreursLieu.isNotEmpty) return;
    setState(() => _enCours = true);
    final messager = ScaffoldMessenger.of(context);
    final navigateur = Navigator.of(context);
    LieuChoisi? lieu;
    if (!garderAncien) {
      try {
        lieu = await enregistrerLieu(ref.read(serviceLieuxProvider), _lieu);
      } on LieuRefuse catch (e) {
        if (!mounted) return;
        setState(() {
          _enCours = false;
          _erreursLieu = {
            e.surQuartier
                ? ChampLieu.quartier
                : ChampLieu.localite: e.raison == RefusLieu.tropDAjouts
                ? l.errLieuTrop
                : l.errLieuNom,
          };
        });
        return;
      }
    }
    try {
      await ref
          .read(boutiqueRepositoryProvider)
          .modifierBoutique(
            id,
            saisie: lieu == null
                ? BoutiqueSaisie(
                    nom: _nom.text,
                    typeCommerce: _type,
                    ville: _ancien!.$1,
                    quartier: _ancien!.$2,
                  )
                : BoutiqueSaisie(
                    nom: _nom.text,
                    typeCommerce: _type,
                    ville: nomLieu(lieu.localite!.nom),
                    quartier: nomLieu(lieu.quartier!.nom),
                    arrondissement: lieu.arrondissement,
                    localiteId: lieu.localite!.id,
                    quartierId: lieu.quartier!.id,
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
              if (_ancien != null && _lieu.region == null) ...[
                // Adresse d'avant le lieu guidé, tant qu'on n'en choisit pas.
                Text.rich(
                  TextSpan(
                    text: l.lieuActuel('${_ancien!.$2}, ${_ancien!.$1}'),
                    style: context.kassa.label,
                    children: [
                      TextSpan(
                        text: '\n${l.lieuPreciser}',
                        style: context.kassa.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KassaSpace.s4),
              ],
              ChoixLieu(
                lieu: _lieu,
                erreurs: _erreursLieu,
                onChanged: (lieu) => setState(() {
                  _lieu = lieu;
                  _erreursLieu = const {};
                }),
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
