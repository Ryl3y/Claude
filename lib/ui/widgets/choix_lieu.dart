import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/lieux.dart';
import '../../l10n/generated/app_localizations.dart';
import '../state/lieux.dart';
import '../theme/kassa_tokens.dart';
import 'contexte.dart';

/// Les cinq étapes du lieu, pour signaler une erreur sur la bonne.
enum ChampLieu { region, departement, arrondissement, localite, quartier }

/// Erreurs de saisie du lieu (vide si tout est rempli).
Map<ChampLieu, String> verifierLieu(AppLocalizations l, LieuChoisi lieu) => {
  if (lieu.region == null) ChampLieu.region: l.errRegion,
  if (lieu.region != null && lieu.departement == null)
    ChampLieu.departement: l.errDepartement,
  if (lieu.departement != null && lieu.arrondissement == null)
    ChampLieu.arrondissement: l.errArrondissement,
  if (lieu.arrondissement != null && cleLieu(lieu.localite?.nom ?? '').isEmpty)
    ChampLieu.localite: l.errLocalite,
  if (cleLieu(lieu.localite?.nom ?? '').isNotEmpty &&
      cleLieu(lieu.quartier?.nom ?? '').isEmpty)
    ChampLieu.quartier: l.errDistrict,
};

/// Choix guidé du lieu de la boutique : Région → Département →
/// Arrondissement (listes officielles, sans internet) → Ville ou village →
/// Quartier (listes partagées : on choisit un nom proposé, ou on tape un
/// nom nouveau qui sera ajouté pour les suivants).
class ChoixLieu extends ConsumerStatefulWidget {
  const ChoixLieu({
    super.key,
    required this.lieu,
    required this.onChanged,
    this.erreurs = const {},
  });

  final LieuChoisi lieu;
  final ValueChanged<LieuChoisi> onChanged;
  final Map<ChampLieu, String> erreurs;

  @override
  ConsumerState<ChoixLieu> createState() => _ChoixLieuState();
}

class _ChoixLieuState extends ConsumerState<ChoixLieu> {
  final _localite = TextEditingController();
  final _quartier = TextEditingController();
  final _focusLocalite = FocusNode();
  final _focusQuartier = FocusNode();

  /// Listes chargées : null pendant le chargement ou sans liste (hors ligne,
  /// sans serveur, village nouveau).
  List<Lieu>? _localites;
  List<Lieu>? _quartiers;
  bool _horsLigne = false;
  String? _arrondissementCharge;
  String? _localiteChargee;

  @override
  void initState() {
    super.initState();
    _localite.text = widget.lieu.localite?.nom ?? '';
    _quartier.text = widget.lieu.quartier?.nom ?? '';
    _focusLocalite.addListener(() => setState(() {}));
    _focusQuartier.addListener(() => setState(() {}));
    _charger();
  }

  @override
  void didUpdateWidget(ChoixLieu ancien) {
    super.didUpdateWidget(ancien);
    // Lieu fourni de l'extérieur (fiche chargée après coup) : les champs
    // suivent, sauf pendant la saisie.
    final loc = widget.lieu.localite?.nom ?? '';
    if (!_focusLocalite.hasFocus && _localite.text != loc) _localite.text = loc;
    final qua = widget.lieu.quartier?.nom ?? '';
    if (!_focusQuartier.hasFocus && _quartier.text != qua) _quartier.text = qua;
    _charger();
  }

  @override
  void dispose() {
    _localite.dispose();
    _quartier.dispose();
    _focusLocalite.dispose();
    _focusQuartier.dispose();
    super.dispose();
  }

  /// Charge les villages de l'arrondissement et les quartiers du village
  /// quand ils changent.
  void _charger() {
    final service = ref.read(serviceLieuxProvider);
    final arr = widget.lieu.arrondissement;
    if (arr != _arrondissementCharge) {
      _arrondissementCharge = arr;
      _localites = null;
      if (service != null && arr != null) {
        service
            .localites(arr)
            .then(
              (l) {
                if (mounted && _arrondissementCharge == arr) {
                  setState(() {
                    _localites = l;
                    _horsLigne = false;
                  });
                }
              },
              onError: (_) {
                if (mounted) setState(() => _horsLigne = true);
              },
            );
      }
    }
    final loc = widget.lieu.localite?.id;
    if (loc != _localiteChargee) {
      _localiteChargee = loc;
      _quartiers = null;
      if (service != null && loc != null) {
        service
            .quartiers(loc)
            .then(
              (q) {
                if (mounted && _localiteChargee == loc) {
                  setState(() => _quartiers = q);
                }
              },
              onError: (_) {
                if (mounted) setState(() => _horsLigne = true);
              },
            );
      }
    }
  }

  LieuChoisi _avec({
    String? region,
    String? departement,
    String? arrondissement,
    Lieu? localite,
    Lieu? quartier,
    int niveau = 5,
  }) {
    final l = widget.lieu;
    return LieuChoisi(
      region: niveau >= 1 ? region ?? l.region : null,
      departement: niveau >= 2 ? departement ?? l.departement : null,
      arrondissement: niveau >= 3 ? arrondissement ?? l.arrondissement : null,
      localite: niveau >= 4 ? localite ?? l.localite : null,
      quartier: niveau >= 5 ? quartier ?? l.quartier : null,
    );
  }

  /// Le nom tapé : le lieu existant de même clé, sinon un nom nouveau.
  Lieu? _depuisSaisie(String texte, List<Lieu>? liste) {
    final c = cleLieu(texte);
    if (c.isEmpty) return null;
    return liste?.where((x) => cleLieu(x.nom) == c).firstOrNull ??
        Lieu(null, texte);
  }

  void _videLocalite() {
    _localite.clear();
    _quartier.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final langue = langueDe(context);
    final decoupage = ref.watch(decoupageProvider).value;
    final lieu = widget.lieu;
    final e = widget.erreurs;
    if (decoupage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget liste({
      required String libelle,
      required String? valeur,
      required List<(String, String)> choix,
      required ValueChanged<String> choisir,
      String? erreur,
    }) => DropdownButtonFormField<String>(
      key: ValueKey('$libelle-${choix.length}-$valeur'),
      initialValue: valeur,
      isExpanded: true,
      icon: const Icon(Symbols.expand_more_rounded),
      decoration: InputDecoration(
        labelText: libelle,
        errorText: erreur,
        errorMaxLines: 2,
      ),
      items: [
        for (final (code, nom) in choix)
          DropdownMenuItem(value: code, child: Text(nom)),
      ],
      onChanged: choix.isEmpty
          ? null
          : (v) {
              if (v != null) choisir(v);
            },
    );

    final regions = [for (final r in decoupage.regions) (r.code, r.nom(langue))]
      ..sort((a, b) => cleLieu(a.$2).compareTo(cleLieu(b.$2)));
    final departements = lieu.region == null
        ? <(String, String)>[]
        : [
            for (final d in decoupage.departementsDe(lieu.region!))
              (d.code, d.nom),
          ];
    final arrondissements = lieu.departement == null
        ? <(String, String)>[]
        : [
            for (final a in decoupage.arrondissementsDe(lieu.departement!))
              (a.code, a.nom),
          ];

    const ecart = SizedBox(height: KassaSpace.s4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        liste(
          libelle: l.lieuRegion,
          valeur: lieu.region,
          choix: regions,
          erreur: e[ChampLieu.region],
          choisir: (v) {
            if (v == lieu.region) return;
            _videLocalite();
            widget.onChanged(LieuChoisi(region: v));
          },
        ),
        if (lieu.region != null) ...[
          ecart,
          liste(
            libelle: l.lieuDepartement,
            valeur: lieu.departement,
            choix: departements,
            erreur: e[ChampLieu.departement],
            choisir: (v) {
              if (v == lieu.departement) return;
              _videLocalite();
              widget.onChanged(_avec(departement: v, niveau: 2));
            },
          ),
        ],
        if (lieu.departement != null) ...[
          ecart,
          liste(
            libelle: l.lieuArrondissement,
            valeur: lieu.arrondissement,
            choix: arrondissements,
            erreur: e[ChampLieu.arrondissement],
            choisir: (v) {
              if (v == lieu.arrondissement) return;
              _videLocalite();
              widget.onChanged(_avec(arrondissement: v, niveau: 3));
            },
          ),
        ],
        if (lieu.arrondissement != null) ...[
          ecart,
          _ChampAvecSuggestions(
            controleur: _localite,
            focus: _focusLocalite,
            libelle: l.lieuLocalite,
            exemple: l.lieuLocaliteHint,
            erreur: e[ChampLieu.localite],
            liste: _localites,
            choisi: lieu.localite,
            horsLigne: _horsLigne || ref.read(serviceLieuxProvider) == null,
            aide: l.lieuOsm,
            onChanged: (texte) {
              _quartier.clear();
              widget.onChanged(
                LieuChoisi(
                  region: lieu.region,
                  departement: lieu.departement,
                  arrondissement: lieu.arrondissement,
                  localite: _depuisSaisie(texte, _localites),
                ),
              );
            },
            onChoisi: (x) {
              _localite.text = x.nom;
              _quartier.clear();
              _focusLocalite.unfocus();
              widget.onChanged(
                LieuChoisi(
                  region: lieu.region,
                  departement: lieu.departement,
                  arrondissement: lieu.arrondissement,
                  localite: x,
                ),
              );
            },
          ),
        ],
        if (cleLieu(lieu.localite?.nom ?? '').isNotEmpty) ...[
          ecart,
          _ChampAvecSuggestions(
            controleur: _quartier,
            focus: _focusQuartier,
            libelle: l.district,
            exemple: l.lieuQuartierHint,
            erreur: e[ChampLieu.quartier],
            liste: _quartiers ?? (lieu.localite?.id == null ? const [] : null),
            choisi: lieu.quartier,
            horsLigne: _horsLigne || ref.read(serviceLieuxProvider) == null,
            onChanged: (texte) => widget.onChanged(
              _avec(quartier: _depuisSaisie(texte, _quartiers)),
            ),
            onChoisi: (x) {
              _quartier.text = x.nom;
              _focusQuartier.unfocus();
              widget.onChanged(_avec(quartier: x));
            },
          ),
        ],
      ],
    );
  }
}

/// Champ texte avec, en dessous, les noms proposés qui correspondent à la
/// saisie et « Ajouter « … » » si le nom tapé n'existe pas encore.
class _ChampAvecSuggestions extends StatelessWidget {
  const _ChampAvecSuggestions({
    required this.controleur,
    required this.focus,
    required this.libelle,
    required this.exemple,
    required this.liste,
    required this.choisi,
    required this.horsLigne,
    required this.onChanged,
    required this.onChoisi,
    this.erreur,
    this.aide,
  });

  final TextEditingController controleur;
  final FocusNode focus;
  final String libelle;
  final String exemple;
  final String? erreur;
  final String? aide;

  /// null : liste en cours de chargement (ou indisponible).
  final List<Lieu>? liste;
  final Lieu? choisi;
  final bool horsLigne;
  final ValueChanged<String> onChanged;
  final ValueChanged<Lieu> onChoisi;

  /// Nombre de noms proposés à la fois.
  static const proposes = 5;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final texte = controleur.text;
    final c = cleLieu(texte);
    final suggestions = liste == null || !focus.hasFocus
        ? const <Lieu>[]
        : filtrerLieux(
            liste!,
            texte,
            max: proposes,
          ).where((x) => x != choisi || cleLieu(x.nom) != c).toList();
    final existe = liste?.any((x) => cleLieu(x.nom) == c) ?? false;
    final nouveau = c.isNotEmpty && !existe;

    final String? aideAffichee;
    if (horsLigne && liste == null) {
      aideAffichee = l.lieuHorsLigne;
    } else if (nouveau && !focus.hasFocus) {
      aideAffichee = l.lieuNouveau(nomLieu(texte));
    } else {
      aideAffichee = aide;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controleur,
          focusNode: focus,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 60,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: libelle,
            hintText: exemple,
            helperText: aideAffichee,
            helperMaxLines: 3,
            errorText: erreur,
            errorMaxLines: 3,
            counterText: '',
            suffixIcon: liste == null && !horsLigne && focus.hasFocus
                ? const Padding(
                    padding: EdgeInsets.all(KassaSpace.s4),
                    child: SizedBox.square(
                      dimension: KassaSpace.s4,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        if (focus.hasFocus && (suggestions.isNotEmpty || nouveau))
          Container(
            margin: const EdgeInsets.only(top: KassaSpace.s1),
            decoration: BoxDecoration(
              color: t.surfaceRaised,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(KassaRadius.sm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final s in suggestions)
                  _Suggestion(
                    icone: Symbols.location_on_rounded,
                    texte: s.nom,
                    onTap: () => onChoisi(s),
                  ),
                if (nouveau)
                  _Suggestion(
                    icone: Symbols.add_location_alt_rounded,
                    texte: l.lieuAjouter(nomLieu(texte)),
                    accent: true,
                    onTap: () => onChoisi(Lieu(null, nomLieu(texte))),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({
    required this.icone,
    required this.texte,
    required this.onTap,
    this.accent = false,
  });

  final IconData icone;
  final String texte;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final couleur = accent ? t.kassa : t.ink;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: KassaSize.touchMin),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: KassaSpace.s4),
            child: Row(
              children: [
                Icon(icone, color: couleur),
                const SizedBox(width: KassaSpace.s2),
                Expanded(
                  child: Text(
                    texte,
                    style: (accent ? t.label : t.body).copyWith(color: couleur),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
