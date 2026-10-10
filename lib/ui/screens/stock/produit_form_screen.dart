import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/montant.dart';
import '../../../core/quantite.dart';
import '../../../core/saisie.dart';
import '../../../data/db/kassa_database.dart';
import '../../../data/photos_produits.dart';
import '../../../data/providers.dart';
import '../../../domain/produit_saisie.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/produits.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';
import 'nouvelle_categorie_dialog.dart';

/// Écran 10 : ajouter ou modifier un produit.
///
/// Sans [produitId] : création. Avec : modification ; changer la quantité
/// enregistre un mouvement « correction » (le stock reste recalculable).
class ProduitFormScreen extends ConsumerStatefulWidget {
  const ProduitFormScreen({super.key, this.produitId});

  final String? produitId;

  @override
  ConsumerState<ProduitFormScreen> createState() => _ProduitFormScreenState();
}

class _ProduitFormScreenState extends ConsumerState<ProduitFormScreen> {
  static const _valeurNouvelleCategorie = '__nouvelle__';

  final _formulaire = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prixAchat = TextEditingController();
  final _prixVente = TextEditingController();
  final _quantite = TextEditingController();
  final _unite = TextEditingController();
  final _seuil = TextEditingController();

  String? _categorieId;

  /// Change à chaque choix de catégorie pour reconstruire la liste
  /// déroulante (elle ne relit sa valeur initiale qu'à sa création).
  var _versionCategorie = 0;
  String? _photo;

  /// Photo enregistrée en base à l'ouverture, et photos prises pendant la
  /// saisie : celles qui ne servent plus sont effacées du téléphone.
  String? _photoInitiale;
  final _photosPrises = <String>{};
  var _enregistre = false;
  double _quantiteAffichee = 0;
  String? _codeBarre;
  var _charge = false;
  var _introuvable = false;
  var _enCours = false;

  bool get _creation => widget.produitId == null;

  @override
  void initState() {
    super.initState();
    for (final c in [_prixAchat, _prixVente, _unite]) {
      c.addListener(() => setState(() {}));
    }
    _charger();
  }

  Future<void> _charger() async {
    final repo = ref.read(produitsRepositoryProvider);
    if (_creation) {
      final seuil = await repo.seuilParDefaut();
      if (!mounted) return;
      final langue = langueDe(context);
      setState(() {
        _quantite.text = '0';
        _seuil.text = Quantite.pourSaisie(seuil, langue);
        _charge = true;
      });
      return;
    }
    final Produit? p = await repo.surveillerProduit(widget.produitId!).first;
    if (!mounted) return;
    if (p == null) {
      setState(() => _introuvable = true);
      return;
    }
    final langue = langueDe(context);
    setState(() {
      _nom.text = p.nom;
      _categorieId = p.categorieId;
      _prixAchat.text = '${p.prixAchat}';
      _prixVente.text = '${p.prixVente}';
      _quantiteAffichee = p.quantite;
      _quantite.text = Quantite.pourSaisie(p.quantite, langue);
      _unite.text = p.unite;
      _seuil.text = Quantite.pourSaisie(p.seuilAlerte, langue);
      _photo = p.photoLocale;
      _photoInitiale = p.photoLocale;
      _codeBarre = p.codeBarre;
      _charge = true;
    });
  }

  /// Après une réappro lancée depuis ce formulaire : reprend le stock et le
  /// prix d'achat à jour, sans toucher aux autres champs déjà modifiés.
  Future<void> _ouvrirReappro() async {
    await context.push(Chemins.reappro(produitId: widget.produitId));
    if (!mounted) return;
    final p = await ref
        .read(produitsRepositoryProvider)
        .surveillerProduit(widget.produitId!)
        .first;
    if (p == null || !mounted) return;
    final langue = langueDe(context);
    setState(() {
      _quantiteAffichee = p.quantite;
      _quantite.text = Quantite.pourSaisie(p.quantite, langue);
      _prixAchat.text = '${p.prixAchat}';
    });
  }

  @override
  void dispose() {
    // Formulaire quitté sans enregistrer : les photos prises sont inutiles.
    if (!_enregistre) {
      for (final photo in _photosPrises) {
        PhotosProduits.effacer(photo);
      }
    }
    for (final c in [_nom, _prixAchat, _prixVente, _quantite, _unite, _seuil]) {
      c.dispose();
    }
    super.dispose();
  }

  // ------------------------------------------------------------- Actions

  Future<void> _choisirCategorie(String? valeur) async {
    if (valeur != _valeurNouvelleCategorie) {
      setState(() {
        _categorieId = valeur;
        _versionCategorie++;
      });
      return;
    }
    final l = AppLocalizations.of(context);
    final nouvelle = await demanderNouvelleCategorie(context);
    String? id;
    if (nouvelle != null) {
      try {
        id = await ref
            .read(produitsRepositoryProvider)
            .creerCategorie(nom: nouvelle.nom, icone: nouvelle.icone);
      } on Object {
        if (mounted) _message(l.saveError);
      }
    }
    if (!mounted) return;
    // Annulé ou échoué : la liste revient à la catégorie précédente.
    setState(() {
      _categorieId = id ?? _categorieId;
      _versionCategorie++;
    });
  }

  Future<void> _changerPhoto() async {
    final l = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symbols.photo_camera_rounded),
              title: Text(l.photoTake),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Symbols.photo_library_rounded),
              title: Text(l.photoGallery),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            if (_photo != null)
              ListTile(
                leading: Icon(
                  Symbols.delete_rounded,
                  color: context.kassa.dette,
                ),
                title: Text(
                  l.photoRemove,
                  style: context.kassa.body.copyWith(
                    color: context.kassa.dette,
                  ),
                ),
                onTap: () {
                  setState(() => _photo = null);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: PhotosProduits.largeurMax,
        imageQuality: PhotosProduits.qualite,
      );
      if (image == null) return;
      final chemin = await PhotosProduits.enregistrer(image.path);
      _photosPrises.add(chemin);
      if (mounted) setState(() => _photo = chemin);
    } on Exception {
      if (mounted) _message(l.photoError);
    }
  }

  void _message(String texte) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texte)));

  Future<void> _enregistrer() async {
    final l = AppLocalizations.of(context);
    if (!_formulaire.currentState!.validate()) return;
    final saisie = ProduitSaisie(
      nom: _nom.text,
      categorieId: _categorieId,
      prixAchat: Saisie.montant(_prixAchat.text)!,
      prixVente: Saisie.montant(_prixVente.text)!,
      quantite: Saisie.quantite(_quantite.text)!,
      unite: _unite.text,
      seuilAlerte: Saisie.quantite(_seuil.text)!,
      photoLocale: _photo,
      codeBarre: _codeBarre,
    );
    setState(() => _enCours = true);
    try {
      final repo = ref.read(produitsRepositoryProvider);
      if (_creation) {
        await repo.creerProduit(saisie);
      } else {
        await repo.modifierProduit(
          widget.produitId!,
          saisie,
          quantiteAffichee: _quantiteAffichee,
        );
      }
      _enregistre = true;
      // Photos remplacées ou retirées : effacées du téléphone.
      for (final photo in {..._photosPrises, ?_photoInitiale}) {
        if (photo != _photo) PhotosProduits.effacer(photo);
      }
      if (!mounted) return;
      final messager = ScaffoldMessenger.of(context);
      context.pop();
      messager.showSnackBar(
        SnackBar(content: Text(_creation ? l.productAdded : l.productSaved)),
      );
    } on Object {
      if (mounted) {
        setState(() => _enCours = false);
        _message(l.saveError);
      }
    }
  }

  Future<void> _supprimer() async {
    final l = AppLocalizations.of(context);
    final nom = _nom.text.trim();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteProductTitle(nom)),
        content: Text(l.deleteProductBody),
        actions: [
          KassaButton(
            label: l.keep,
            variant: KassaButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          KassaButton(
            label: l.deleteConfirm,
            variant: KassaButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;
    try {
      final photo = await ref
          .read(produitsRepositoryProvider)
          .supprimerProduit(widget.produitId!);
      await PhotosProduits.effacer(photo);
    } on Object {
      if (mounted) _message(l.saveError);
      return;
    }
    if (!mounted) return;
    final messager = ScaffoldMessenger.of(context);
    context.pop();
    messager.showSnackBar(SnackBar(content: Text(l.productDeleted(nom))));
  }

  // ------------------------------------------------------------- Interface

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final titre = _creation ? l.productNewTitle : l.productEditTitle;

    if (_introuvable) {
      return Scaffold(
        appBar: AppBar(title: Text(titre)),
        body: EtatVide(
          icone: Symbols.search_off_rounded,
          titre: l.productNotFound,
        ),
      );
    }
    if (!_charge) {
      return Scaffold(
        appBar: AppBar(title: Text(titre)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(titre)),
      body: Form(
        key: _formulaire,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: KassaComposants.largeurContenuMax,
            ),
            child: ListView(
              padding: const EdgeInsets.all(KassaSpace.s4),
              children: _champs(context, l),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: KassaButton(
          label: _creation ? l.addProduct : l.save,
          icon: _creation ? Symbols.add_rounded : Symbols.check_rounded,
          size: KassaButtonSize.main,
          fullWidth: true,
          onPressed: _enCours ? null : _enregistrer,
        ),
      ),
    );
  }

  List<Widget> _champs(BuildContext context, AppLocalizations l) {
    final t = context.kassa;
    final langue = langueDe(context);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final perte = ReglesProduit.perteParUnite(
      prixAchat: Saisie.montant(_prixAchat.text) ?? 0,
      prixVente: Saisie.montant(_prixVente.text) ?? 0,
    );
    final unites = [
      l.unitPiece, l.unitKg, l.unitLitre, l.unitCarton, //
      l.unitBag, l.unitPack, l.unitBottle, l.unitBox,
    ];
    const espace = SizedBox(height: KassaSpace.s4);

    String? montantValide(String? v) =>
        Saisie.montant(v ?? '') == null ? l.errPriceRequired : null;
    // Stock : négatif seulement en modification. Seuil : jamais négatif.
    String? quantiteValide(String? v) {
      final q = Saisie.quantite(v ?? '');
      return q == null || (_creation && q < 0) ? l.errQuantityInvalid : null;
    }

    String? seuilValide(String? v) {
      final q = Saisie.quantite(v ?? '');
      return q == null || q < 0 ? l.errQuantityInvalid : null;
    }

    return [
      // Photo
      Center(
        child: Column(
          children: [
            VignetteProduit(
              nom: _nom.text.isEmpty ? '?' : _nom.text,
              photo: _photo,
              taille: KassaComposants.vignetteFormulaire,
            ),
            const SizedBox(height: KassaSpace.s2),
            KassaButton(
              label: _photo == null ? l.photoAdd : l.photoChange,
              icon: Symbols.add_a_photo_rounded,
              variant: KassaButtonVariant.ghost,
              onPressed: _changerPhoto,
            ),
          ],
        ),
      ),
      espace,
      TextFormField(
        controller: _nom,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.next,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: l.fieldName,
          hintText: l.fieldNameHint,
        ),
        validator: (v) => (v ?? '').trim().isEmpty ? l.errNameRequired : null,
      ),
      espace,
      DropdownButtonFormField<String?>(
        key: ValueKey(_versionCategorie),
        // Catégorie pas encore chargée : rien de choisi plutôt qu'une erreur.
        initialValue: categories.any((c) => c.id == _categorieId)
            ? _categorieId
            : null,
        isExpanded: true,
        icon: const Icon(Symbols.expand_more_rounded),
        decoration: InputDecoration(labelText: l.fieldCategory),
        items: [
          DropdownMenuItem(value: null, child: Text(l.noCategory)),
          for (final c in categories)
            DropdownMenuItem(
              value: c.id,
              child: Row(
                children: [
                  Icon(IconeCategorie.depuisNom(c.icone).icone),
                  const SizedBox(width: KassaSpace.s2),
                  Flexible(child: Text(c.nom, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          DropdownMenuItem(
            value: _valeurNouvelleCategorie,
            child: Row(
              children: [
                Icon(Symbols.add_rounded, color: t.kassa),
                const SizedBox(width: KassaSpace.s2),
                Text(l.newCategory, style: t.label.copyWith(color: t.kassa)),
              ],
            ),
          ),
        ],
        onChanged: _choisirCategorie,
      ),
      espace,
      TextFormField(
        controller: _prixAchat,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.next,
        style: t.amount,
        decoration: InputDecoration(
          labelText: l.fieldPurchasePrice,
          helperText: l.fieldPurchasePriceHelp,
          suffixText: Montant.deviseLongue,
        ),
        validator: montantValide,
      ),
      espace,
      TextFormField(
        controller: _prixVente,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.next,
        style: t.amount,
        decoration: InputDecoration(
          labelText: l.fieldSalePrice,
          helperText: l.fieldSalePriceHelp,
          suffixText: Montant.deviseLongue,
        ),
        validator: montantValide,
      ),
      if (perte > 0) ...[
        const SizedBox(height: KassaSpace.s2),
        Avertissement(
          texte: l.warnSellingAtLoss(Montant.format(perte, langue)),
        ),
      ],
      espace,
      TextFormField(
        controller: _quantite,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        style: t.amount,
        decoration: InputDecoration(
          labelText: l.fieldQuantity,
          helperText: _creation
              ? l.fieldQuantityHelpNew
              : l.fieldQuantityHelpEdit,
          helperMaxLines: 2,
          suffixText: _unite.text.isEmpty ? null : _unite.text,
        ),
        validator: quantiteValide,
      ),
      espace,
      TextFormField(
        controller: _unite,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: l.fieldUnit),
        validator: (v) => (v ?? '').trim().isEmpty ? l.errUnitRequired : null,
      ),
      const SizedBox(height: KassaSpace.s2),
      Wrap(
        spacing: KassaSpace.s2,
        runSpacing: KassaSpace.s2,
        children: [
          for (final u in unites)
            ChoiceChip(
              label: Text(u),
              selected: _unite.text.trim() == u,
              showCheckmark: false,
              onSelected: (_) => _unite.text = u,
            ),
        ],
      ),
      espace,
      TextFormField(
        controller: _seuil,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: t.amount,
        decoration: InputDecoration(
          labelText: l.fieldThreshold,
          helperText: l.fieldThresholdHelp,
          helperMaxLines: 2,
          suffixText: _unite.text.isEmpty ? null : _unite.text,
        ),
        validator: seuilValide,
      ),
      if (!_creation) ...[
        const SizedBox(height: KassaSpace.s6),
        KassaButton(
          label: l.restock,
          icon: Symbols.local_shipping_rounded,
          variant: KassaButtonVariant.secondary,
          fullWidth: true,
          onPressed: _ouvrirReappro,
        ),
        const SizedBox(height: KassaSpace.s2),
        KassaButton(
          label: l.deleteProduct,
          icon: Symbols.delete_rounded,
          variant: KassaButtonVariant.danger,
          fullWidth: true,
          onPressed: _supprimer,
        ),
      ],
    ];
  }
}
