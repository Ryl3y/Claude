import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../ui/theme/kassa_tokens.dart';
import '../../ui/widgets/contexte.dart';
import '../../ui/widgets/kassa_badge.dart';
import '../../ui/widgets/kassa_button.dart';
import '../donnees/serveur_admin.dart';
import '../etat/etat_admin.dart';
import '../ui/communs.dart';

/// Villages et quartiers ajoutés par les commerçants : visibles tout de
/// suite par tous, l'équipe corrige une faute ou retire un doublon.
class LieuxAdminScreen extends ConsumerStatefulWidget {
  const LieuxAdminScreen({super.key});

  @override
  ConsumerState<LieuxAdminScreen> createState() => _LieuxAdminScreenState();
}

class _LieuxAdminScreenState extends ConsumerState<LieuxAdminScreen> {
  var _pages = 1;

  void _recharger() {
    ref.invalidate(lieuxAdminProvider);
    setState(() => _pages = 1);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final pages = Pages<LieuAjouteAdmin>([
      for (var i = 0; i < _pages; i++)
        ref.watch(lieuxAdminProvider(i * tailleDePage)),
    ]);

    return ListView(
      padding: const EdgeInsets.all(KassaSpace.s4),
      children: [
        Text(l.adminPlacesIntro, style: t.body.copyWith(color: t.ink)),
        const SizedBox(height: KassaSpace.s4),
        if (pages.total == 0)
          Padding(
            padding: const EdgeInsets.all(KassaSpace.s4),
            child: Text(l.adminPlacesEmpty, style: t.body),
          )
        else if (pages.total != null) ...[
          Semantics(
            container: true,
            child: Text(
              l.adminShownOf(pages.elements.length, pages.total!),
              style: t.caption.copyWith(color: t.ink),
            ),
          ),
          const SizedBox(height: KassaSpace.s2),
        ],
        for (final lieu in pages.elements)
          _LigneLieu(lieu: lieu, apresChangement: _recharger),
        if (pages.enErreur)
          ErreurAdmin(reessayer: _recharger)
        else if (pages.enChargement)
          const ChargementAdmin()
        else if (pages.plusAAfficher)
          Padding(
            padding: const EdgeInsets.only(top: KassaSpace.s2),
            child: KassaButton(
              label: l.adminShowMore,
              icon: Symbols.expand_more_rounded,
              variant: KassaButtonVariant.secondary,
              onPressed: () => setState(() => _pages++),
            ),
          ),
        const SizedBox(height: KassaSpace.s4),
        Text(l.lieuOsm, style: t.caption.copyWith(color: t.inkMuted)),
      ],
    );
  }
}

class _LigneLieu extends StatelessWidget {
  const _LigneLieu({required this.lieu, required this.apresChangement});

  final LieuAjouteAdmin lieu;
  final VoidCallback apresChangement;

  Future<void> _corriger(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogueCorriger(lieu: lieu),
    );
    if (ok ?? false) apresChangement();
  }

  Future<void> _retirer(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messager = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.adminPlaceDeleteTitle(lieu.nom)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Text(
            l.adminPlaceDeleteHelp,
            style: context.kassa.body.copyWith(color: context.kassa.ink),
          ),
        ),
        actions: [
          KassaButton(
            label: l.cancel,
            variant: KassaButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          KassaButton(
            label: l.adminPlaceDelete,
            icon: Symbols.delete_rounded,
            variant: KassaButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;
    try {
      await ref.read(serveurAdminProvider).supprimerLieu(lieu);
      messager.showSnackBar(
        SnackBar(content: Text(l.adminPlaceDeleted(lieu.nom))),
      );
      apresChangement();
    } on Object {
      messager.showSnackBar(SnackBar(content: Text(l.adminLoadError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final type = lieu.estQuartier ? l.district : l.lieuLocalite;
    return Padding(
      padding: const EdgeInsets.only(bottom: KassaSpace.s2),
      child: Container(
        padding: const EdgeInsets.all(KassaSpace.s4),
        decoration: BoxDecoration(
          color: t.surfaceRaised,
          borderRadius: BorderRadius.circular(KassaRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: KassaSpace.s2,
                    runSpacing: KassaSpace.s1,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(lieu.nom, style: t.label.copyWith(color: t.ink)),
                      KassaBadge(
                        label: type,
                        tone: lieu.estQuartier
                            ? KassaBadgeTone.neutre
                            : KassaBadgeTone.kassa,
                        icon: lieu.estQuartier
                            ? Symbols.signpost_rounded
                            : Symbols.location_city_rounded,
                      ),
                    ],
                  ),
                  if (lieu.localite case final localite?)
                    Text(
                      l.adminPlaceDistrictOf(localite),
                      style: t.body.copyWith(color: t.ink),
                    ),
                  Text(
                    l.adminPlaceWhere(lieu.arrondissement, lieu.departement),
                    style: t.caption.copyWith(color: t.inkMuted),
                  ),
                  Text(
                    '${l.adminPlaceAdded(jourAdmin(lieu.creeLe, langue))}'
                    ' · ${l.adminPlaceShops(lieu.boutiques)}',
                    style: t.caption.copyWith(color: t.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KassaSpace.s2),
            Consumer(
              builder: (context, ref, _) => Wrap(
                spacing: KassaSpace.s2,
                runSpacing: KassaSpace.s2,
                children: [
                  KassaButton(
                    label: l.adminPlaceFix,
                    icon: Symbols.edit_rounded,
                    variant: KassaButtonVariant.secondary,
                    onPressed: () => _corriger(context),
                  ),
                  KassaButton(
                    label: l.adminPlaceDelete,
                    icon: Symbols.delete_rounded,
                    variant: KassaButtonVariant.ghost,
                    onPressed: () => _retirer(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogueCorriger extends ConsumerStatefulWidget {
  const _DialogueCorriger({required this.lieu});

  final LieuAjouteAdmin lieu;

  @override
  ConsumerState<_DialogueCorriger> createState() => _DialogueCorrigerState();
}

class _DialogueCorrigerState extends ConsumerState<_DialogueCorriger> {
  late final _nom = TextEditingController(text: widget.lieu.nom);
  var _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final l = AppLocalizations.of(context);
    final nom = _nom.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (nom.runes.length < 2) {
      setState(() => _erreur = l.errLieuNom);
      return;
    }
    if (_enCours) return;
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    final messager = ScaffoldMessenger.of(context);
    final navigateur = Navigator.of(context);
    try {
      await ref.read(serveurAdminProvider).renommerLieu(widget.lieu, nom);
      messager.showSnackBar(SnackBar(content: Text(l.adminPlaceFixed(nom))));
      navigateur.pop(true);
    } on LieuAdminRefuse catch (e) {
      if (!mounted) return;
      setState(() {
        _enCours = false;
        _erreur = switch (e.raison) {
          RefusLieuAdmin.existeDeja => l.adminPlaceErrExists,
          RefusLieuAdmin.nomInvalide => l.errLieuNom,
          RefusLieuAdmin.autre => l.errOther,
        };
      });
    } on Object {
      if (!mounted) return;
      setState(() => _enCours = false);
      messager.showSnackBar(SnackBar(content: Text(l.adminLoadError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    return AlertDialog(
      title: Text(l.adminPlaceFixTitle(widget.lieu.nom)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.adminPlaceFixHelp, style: t.body.copyWith(color: t.ink)),
              const SizedBox(height: KassaSpace.s4),
              TextField(
                controller: _nom,
                autofocus: true,
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _valider(),
                decoration: InputDecoration(
                  labelText: l.adminPlaceNewName,
                  errorText: _erreur,
                  errorMaxLines: 3,
                  counterText: '',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        KassaButton(
          label: l.cancel,
          variant: KassaButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        KassaButton(
          label: l.save,
          icon: Symbols.check_rounded,
          onPressed: _enCours ? null : _valider,
        ),
      ],
    );
  }
}
