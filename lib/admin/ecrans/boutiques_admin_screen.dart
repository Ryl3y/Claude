import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/heure_douala.dart';
import '../../core/telephone.dart';
import '../../domain/abonnement.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/theme/kassa_tokens.dart';
import '../../ui/widgets/contexte.dart';
import '../../ui/widgets/kassa_badge.dart';
import '../../ui/widgets/kassa_button.dart';
import '../../ui/widgets/types_commerce.dart';
import '../donnees/serveur_admin.dart';
import '../etat/etat_admin.dart';
import '../ui/communs.dart';

/// État de l'abonnement d'une boutique, en une étiquette.
({String texte, KassaBadgeTone ton}) etiquetteAbonnement(
  AppLocalizations l,
  BoutiqueAdmin b,
  String langue,
) {
  final fin = b.dateFin;
  if (fin == null || b.formule == null) {
    return (texte: l.adminSubNone, ton: KassaBadgeTone.neutre);
  }
  final date = jourAdmin(fin, langue);
  final aujourdhui = EtatAbonnement.jourDouala(HeureDouala.maintenantUtc());
  if (fin.isBefore(aujourdhui)) {
    return (texte: l.adminSubEnded(date), ton: KassaBadgeTone.dette);
  }
  return b.formule == 'pro'
      ? (texte: l.proUntil(date), ton: KassaBadgeTone.or)
      : (texte: l.trialUntil(date), ton: KassaBadgeTone.kassa);
}

/// Liste des boutiques avec recherche ; la fiche s'ouvre à droite
/// (ordinateur) ou en plein écran (petit écran).
class BoutiquesAdminScreen extends ConsumerStatefulWidget {
  const BoutiquesAdminScreen({super.key});

  @override
  ConsumerState<BoutiquesAdminScreen> createState() =>
      _BoutiquesAdminScreenState();
}

class _BoutiquesAdminScreenState extends ConsumerState<BoutiquesAdminScreen> {
  final _recherche = TextEditingController();
  Timer? _attente;
  var _texte = '';
  var _pages = 1;
  BoutiqueAdmin? _choisie;

  @override
  void dispose() {
    _attente?.cancel();
    _recherche.dispose();
    super.dispose();
  }

  void _chercher(String texte) {
    _attente?.cancel();
    _attente = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _texte = texte.trim();
          _pages = 1;
        });
      }
    });
  }

  void _ouvrir(BoutiqueAdmin b, bool large) {
    if (large) {
      setState(() => _choisie = b);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(b.nom)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(KassaSpace.s4),
            child: FicheBoutique(boutique: b),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final large = MediaQuery.sizeOf(context).width >= largeurBureau;
    final pages = Pages<BoutiqueAdmin>([
      for (var i = 0; i < _pages; i++)
        ref.watch(
          boutiquesAdminProvider((
            recherche: _texte,
            decalage: i * tailleDePage,
          )),
        ),
    ]);

    final liste = ListView(
      padding: const EdgeInsets.all(KassaSpace.s4),
      children: [
        TextField(
          controller: _recherche,
          onChanged: _chercher,
          decoration: InputDecoration(
            labelText: l.adminSearchShops,
            prefixIcon: const Icon(Symbols.search_rounded),
            // Nombre de boutiques trouvées, lu avec le champ de recherche.
            helperText: (pages.total ?? 0) > 0
                ? l.adminShownOf(pages.elements.length, pages.total!)
                : null,
            helperStyle: t.caption.copyWith(color: t.ink),
          ),
        ),
        const SizedBox(height: KassaSpace.s4),
        if (pages.total == 0)
          Padding(
            padding: const EdgeInsets.all(KassaSpace.s4),
            child: Text(l.adminNoShops, style: t.body),
          ),
        for (final b in pages.elements)
          _LigneBoutique(
            boutique: b,
            choisie: b.id == _choisie?.id,
            onTap: () => _ouvrir(b, large),
          ),
        if (pages.enErreur)
          ErreurAdmin(reessayer: () => ref.invalidate(boutiquesAdminProvider))
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
      ],
    );

    if (!large) return liste;
    // La fiche suit la version la plus récente de la boutique choisie.
    final choisie =
        pages.elements.where((b) => b.id == _choisie?.id).firstOrNull ??
        _choisie;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 3, child: liste),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(KassaSpace.s4),
            child: choisie == null
                ? CarteAdmin(
                    titre: l.adminNavShops,
                    child: Text(l.adminChooseShop, style: t.body),
                  )
                : FicheBoutique(key: ValueKey(choisie.id), boutique: choisie),
          ),
        ),
      ],
    );
  }
}

class _LigneBoutique extends StatelessWidget {
  const _LigneBoutique({
    required this.boutique,
    required this.choisie,
    required this.onTap,
  });

  final BoutiqueAdmin boutique;
  final bool choisie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final b = boutique;
    final etat = etiquetteAbonnement(l, b, langueDe(context));
    return Padding(
      padding: const EdgeInsets.only(bottom: KassaSpace.s2),
      child: Material(
        color: choisie ? t.kassaSoft : t.surfaceRaised,
        borderRadius: BorderRadius.circular(KassaRadius.md),
        clipBehavior: Clip.antiAlias,
        child: MergeSemantics(
          child: Semantics(
            button: true,
            selected: choisie,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: KassaSize.touchMin,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(KassaSpace.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.nom, style: t.label.copyWith(color: t.ink)),
                      Text(
                        '${b.quartier}, ${b.ville} · '
                        '${Telephone.afficher(b.telephone)}',
                        style: t.caption.copyWith(color: t.inkMuted),
                      ),
                      const SizedBox(height: KassaSpace.s1),
                      KassaBadge(label: etat.texte, tone: etat.ton),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fiche d'une boutique : informations, abonnement, gestes commerciaux.
class FicheBoutique extends ConsumerStatefulWidget {
  const FicheBoutique({super.key, required this.boutique});

  final BoutiqueAdmin boutique;

  @override
  ConsumerState<FicheBoutique> createState() => _FicheBoutiqueState();
}

class _FicheBoutiqueState extends ConsumerState<FicheBoutique> {
  late BoutiqueAdmin _b = widget.boutique;

  @override
  void didUpdateWidget(FicheBoutique ancien) {
    super.didUpdateWidget(ancien);
    _b = widget.boutique;
  }

  Future<void> _offrir() async {
    final fin = await offrirDesJours(context, _b);
    if (fin == null) return;
    ref
      ..invalidate(boutiquesAdminProvider)
      ..invalidate(ajustementsAdminProvider(_b.id))
      ..invalidate(chiffresAdminProvider);
    // Relit la boutique : la fiche (ouverte seule sur petit écran) montre
    // tout de suite le nouvel abonnement.
    try {
      final page = await ref
          .read(serveurAdminProvider)
          .boutiques(recherche: _b.telephone, limite: 5);
      final relue = page.elements.where((x) => x.id == _b.id).firstOrNull;
      if (relue != null && mounted) setState(() => _b = relue);
    } on Object {
      // La liste se rechargera ; la fiche garde l'ancienne version.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final b = _b;
    final etat = etiquetteAbonnement(l, b, langue);
    final historique = ref.watch(ajustementsAdminProvider(b.id));

    Widget ligne(IconData icone, String texte) => Padding(
      padding: const EdgeInsets.only(bottom: KassaSpace.s2),
      child: Row(
        children: [
          Icon(icone, color: t.inkMuted),
          const SizedBox(width: KassaSpace.s2),
          Expanded(child: Text(texte, style: t.body)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CarteAdmin(
          titre: b.nom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: KassaBadge(label: etat.texte, tone: etat.ton),
              ),
              const SizedBox(height: KassaSpace.s4),
              ligne(Symbols.call_rounded, Telephone.afficher(b.telephone)),
              ligne(
                Symbols.category_rounded,
                TypesCommerce.libelle(l, b.typeCommerce),
              ),
              ligne(Symbols.location_on_rounded, '${b.quartier}, ${b.ville}'),
              ligne(
                Symbols.calendar_today_rounded,
                l.adminShopSince(HeureDouala.dateCourte(b.creeLe, langue)),
              ),
              ligne(
                Symbols.cloud_done_rounded,
                b.derniereActivite == null
                    ? l.adminNoBackup
                    : l.adminLastBackup(
                        '${HeureDouala.dateCourte(b.derniereActivite!, langue)}'
                        ' ${HeureDouala.heure(b.derniereActivite!, langue)}',
                      ),
              ),
              ligne(Symbols.point_of_sale_rounded, l.salesCount(b.ventes)),
              const SizedBox(height: KassaSpace.s2),
              KassaButton(
                label: l.adminGift,
                icon: Symbols.redeem_rounded,
                variant: KassaButtonVariant.or,
                fullWidth: true,
                onPressed: _offrir,
              ),
            ],
          ),
        ),
        const SizedBox(height: KassaSpace.s4),
        CarteAdmin(
          titre: l.adminHistory,
          child: switch (historique) {
            AsyncData(:final value) when value.isEmpty => Text(
              l.adminHistoryEmpty,
              style: t.body,
            ),
            AsyncData(:final value) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final a in value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: KassaSpace.s2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.adminHistoryEntry(
                            HeureDouala.dateCourte(a.creeLe, langue),
                            a.jours,
                            a.formule == 'pro'
                                ? l.adminGiftKindPro
                                : l.adminGiftKindTrial,
                            a.adminEmail ?? '',
                          ),
                          style: t.label.copyWith(color: t.ink),
                        ),
                        Text(
                          a.motif,
                          style: t.caption.copyWith(color: t.inkMuted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            AsyncError() => ErreurAdmin(
              reessayer: () => ref.invalidate(ajustementsAdminProvider(b.id)),
            ),
            _ => const ChargementAdmin(),
          },
        ),
      ],
    );
  }
}

/// Offre des jours d'essai ou de Pro à une boutique ; renvoie la nouvelle
/// date de fin, ou null si l'admin annule.
Future<DateTime?> offrirDesJours(BuildContext context, BoutiqueAdmin b) =>
    showDialog<DateTime>(
      context: context,
      builder: (_) => _DialogueOffrir(boutique: b),
    );

class _DialogueOffrir extends ConsumerStatefulWidget {
  const _DialogueOffrir({required this.boutique});

  final BoutiqueAdmin boutique;

  @override
  ConsumerState<_DialogueOffrir> createState() => _DialogueOffrirState();
}

class _DialogueOffrirState extends ConsumerState<_DialogueOffrir> {
  final _jours = TextEditingController(text: '7');
  final _motif = TextEditingController();
  var _formule = 'gratuit';
  var _enCours = false;
  String? _erreurJours;
  String? _erreurMotif;

  @override
  void dispose() {
    _jours.dispose();
    _motif.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final l = AppLocalizations.of(context);
    final jours = int.tryParse(_jours.text.trim());
    final motif = _motif.text.trim();
    // Même mesure que le serveur : en caractères (points de code).
    final longueur = motif.runes.length;
    setState(() {
      _erreurJours = jours == null || jours < 1 || jours > 366
          ? l.adminErrDays
          : null;
      _erreurMotif = longueur < 3 || longueur > 500 ? l.adminErrReason : null;
    });
    if (_erreurJours != null || _erreurMotif != null || _enCours) return;
    setState(() => _enCours = true);
    final messager = ScaffoldMessenger.of(context);
    final navigateur = Navigator.of(context);
    final langue = langueDe(context);
    try {
      final fin = await ref
          .read(serveurAdminProvider)
          .ajusterAbonnement(
            boutiqueId: widget.boutique.id,
            jours: jours!,
            formule: _formule,
            motif: motif,
          );
      messager.showSnackBar(
        SnackBar(
          content: Text(
            l.adminGiftDone(widget.boutique.nom, jourAdmin(fin, langue)),
          ),
        ),
      );
      navigateur.pop(fin);
    } on AjustementRefuse catch (e) {
      if (!mounted) return;
      setState(() {
        _enCours = false;
        switch (e.raison) {
          case RefusAjustement.jours:
            _erreurJours = l.adminErrDays;
          case RefusAjustement.motif:
            _erreurMotif = l.adminErrReason;
          case RefusAjustement.autre:
            messager.showSnackBar(SnackBar(content: Text(l.errOther)));
        }
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
      title: Text(l.adminGiftTitle(widget.boutique.nom)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.adminGiftDaysHelp, style: t.body.copyWith(color: t.ink)),
              const SizedBox(height: KassaSpace.s4),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'gratuit',
                    label: Text(l.adminGiftKindTrial),
                    icon: const Icon(Symbols.hourglass_top_rounded),
                  ),
                  ButtonSegment(
                    value: 'pro',
                    label: Text(l.adminGiftKindPro),
                    icon: const Icon(Symbols.workspace_premium_rounded),
                  ),
                ],
                selected: {_formule},
                onSelectionChanged: (s) => setState(() => _formule = s.first),
              ),
              const SizedBox(height: KassaSpace.s4),
              TextField(
                controller: _jours,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l.adminGiftDays,
                  errorText: _erreurJours,
                  errorMaxLines: 2,
                ),
              ),
              const SizedBox(height: KassaSpace.s4),
              TextField(
                controller: _motif,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: l.adminGiftReason,
                  hintText: l.adminGiftReasonHint,
                  errorText: _erreurMotif,
                  errorMaxLines: 2,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        KassaButton(
          label: l.adminGiftConfirm,
          icon: Symbols.redeem_rounded,
          onPressed: _enCours ? null : _valider,
        ),
      ],
    );
  }
}
