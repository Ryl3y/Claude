import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/widgets.dart';

/// Résultat de la boîte « Nouvelle catégorie ».
typedef NouvelleCategorie = ({String nom, String icone});

/// Demande le nom (et l'icône) d'une nouvelle catégorie.
/// Les modèles (Épicerie, Boissons…) remplissent le nom en un toucher.
Future<NouvelleCategorie?> demanderNouvelleCategorie(BuildContext context) =>
    showDialog<NouvelleCategorie>(
      context: context,
      builder: (_) => const _NouvelleCategorieDialog(),
    );

class _NouvelleCategorieDialog extends StatefulWidget {
  const _NouvelleCategorieDialog();

  @override
  State<_NouvelleCategorieDialog> createState() =>
      _NouvelleCategorieDialogState();
}

class _NouvelleCategorieDialogState extends State<_NouvelleCategorieDialog> {
  final _nom = TextEditingController();
  var _icone = IconeCategorie.autre;
  String? _erreur;

  @override
  void dispose() {
    _nom.dispose();
    super.dispose();
  }

  void _valider() {
    final l = AppLocalizations.of(context);
    final nom = _nom.text.trim();
    if (nom.isEmpty) {
      setState(() => _erreur = l.errCategoryName);
      return;
    }
    Navigator.of(context).pop((nom: nom, icone: _icone.nom));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    return AlertDialog(
      title: Text(l.newCategory),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.categoryQuickPick,
              style: t.caption.copyWith(color: t.inkMuted),
            ),
            const SizedBox(height: KassaSpace.s2),
            Wrap(
              spacing: KassaSpace.s2,
              runSpacing: KassaSpace.s2,
              children: [
                for (final modele in IconeCategorie.values)
                  ChoiceChip(
                    avatar: Icon(
                      modele.icone,
                      size: KassaComposants.iconeEtiquette,
                      color: t.ink,
                    ),
                    label: Text(modele.libelle(l)),
                    selected: _icone == modele,
                    showCheckmark: false,
                    onSelected: (_) => setState(() {
                      _icone = modele;
                      if (modele != IconeCategorie.autre) {
                        _nom.text = modele.libelle(l);
                        _erreur = null;
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: KassaSpace.s4),
            TextField(
              controller: _nom,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _valider(),
              onChanged: (_) {
                if (_erreur != null) setState(() => _erreur = null);
              },
              decoration: InputDecoration(
                labelText: l.categoryName,
                errorText: _erreur,
              ),
            ),
          ],
        ),
      ),
      actions: [
        KassaButton(
          label: l.cancel,
          variant: KassaButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        KassaButton(label: l.categoryCreate, onPressed: _valider),
      ],
    );
  }
}
