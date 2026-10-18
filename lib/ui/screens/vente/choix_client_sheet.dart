import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/saisie.dart';
import '../../../data/db/kassa_database.dart';
import '../../../data/providers.dart';
import '../../../domain/client_saisie.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../state/vente.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/widgets.dart';
import '../abonnement/garde_abonnement.dart';

/// Choisit un client (ou en crée un : nom + téléphone) pour une vente à
/// crédit. Renvoie l'identifiant du client, ou null si la feuille est fermée.
Future<String?> choisirClient(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ChoixClient(),
    );

class _ChoixClient extends ConsumerStatefulWidget {
  const _ChoixClient();

  @override
  ConsumerState<_ChoixClient> createState() => _ChoixClientState();
}

class _ChoixClientState extends ConsumerState<_ChoixClient> {
  final _recherche = TextEditingController();
  final _nom = TextEditingController();
  final _telephone = TextEditingController();
  var _creation = false;
  var _enCours = false;
  Set<ErreurClient> _erreurs = const {};

  @override
  void dispose() {
    _recherche.dispose();
    _nom.dispose();
    _telephone.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    if (!await ecritureAutorisee(context, ref) || !mounted) return;
    if (_enCours) return;
    final l = AppLocalizations.of(context);
    final erreurs = ReglesClient.verifier(
      ClientSaisie(nom: _nom.text, telephone: _telephone.text),
    );
    setState(() => _erreurs = erreurs);
    if (erreurs.isNotEmpty) return;
    setState(() => _enCours = true);
    try {
      final id = await ref
          .read(clientsRepositoryProvider)
          .creerClient(nom: _nom.text, telephone: _telephone.text);
      if (mounted) Navigator.of(context).pop(id);
    } on Object {
      if (mounted) {
        setState(() => _enCours = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.saveError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final bas = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bas),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.sizeOf(context).height *
                KassaComposants.hauteurMaxFeuille,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              KassaSpace.s4,
              0,
              KassaSpace.s4,
              KassaSpace.s4,
            ),
            child: _creation ? _formulaire(l, t) : _liste(l, t),
          ),
        ),
      ),
    );
  }

  Widget _formulaire(AppLocalizations l, KassaTokens t) =>
      SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.newCustomer, style: t.title),
            const SizedBox(height: KassaSpace.s4),
            TextField(
              controller: _nom,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_erreurs.contains(ErreurClient.nomVide)) {
                  setState(
                    () =>
                        _erreurs = {..._erreurs}..remove(ErreurClient.nomVide),
                  );
                }
              },
              decoration: InputDecoration(
                labelText: l.customerName,
                errorText: _erreurs.contains(ErreurClient.nomVide)
                    ? l.errCustomerName
                    : null,
              ),
            ),
            const SizedBox(height: KassaSpace.s4),
            TextField(
              controller: _telephone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _creer(),
              onChanged: (_) {
                if (_erreurs.contains(ErreurClient.telephoneInvalide)) {
                  setState(
                    () =>
                        _erreurs = {..._erreurs}
                          ..remove(ErreurClient.telephoneInvalide),
                  );
                }
              },
              decoration: InputDecoration(
                labelText: l.customerPhone,
                helperText: l.customerPhoneHint,
                errorMaxLines: 2,
                errorText: _erreurs.contains(ErreurClient.telephoneInvalide)
                    ? l.errCustomerPhone
                    : null,
              ),
            ),
            const SizedBox(height: KassaSpace.s6),
            KassaButton(
              label: l.addCustomer,
              icon: Symbols.person_add_rounded,
              size: KassaButtonSize.main,
              fullWidth: true,
              onPressed: _enCours ? null : _creer,
            ),
          ],
        ),
      );

  Widget _liste(AppLocalizations l, KassaTokens t) {
    final cherche = Saisie.pourRecherche(_recherche.text);
    final clients = [
      for (final c in ref.watch(clientsProvider).value ?? const <Client>[])
        if (cherche.isEmpty ||
            Saisie.pourRecherche(c.nom).contains(cherche) ||
            (c.telephone ?? '').contains(cherche))
          c,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.chooseCustomer, style: t.title)),
            KassaButton(
              label: l.newCustomer,
              icon: Symbols.person_add_rounded,
              variant: KassaButtonVariant.secondary,
              onPressed: () => setState(() {
                _creation = true;
                _nom.text = _recherche.text.trim();
              }),
            ),
          ],
        ),
        const SizedBox(height: KassaSpace.s2),
        TextField(
          controller: _recherche,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l.searchCustomers,
            prefixIcon: const Icon(Symbols.search_rounded),
          ),
        ),
        const SizedBox(height: KassaSpace.s2),
        if (clients.isEmpty)
          Padding(
            padding: const EdgeInsets.all(KassaSpace.s4),
            child: Text(
              l.noCustomers,
              style: t.body.copyWith(color: t.inkMuted),
              textAlign: TextAlign.center,
            ),
          )
        else
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(KassaRadius.md),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: clients.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, i) => ClientRow(
                  nom: clients[i].nom,
                  meta: clients[i].telephone ?? '',
                  montantDu: clients[i].soldeDette,
                  onTap: () => Navigator.of(context).pop(clients[i].id),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
