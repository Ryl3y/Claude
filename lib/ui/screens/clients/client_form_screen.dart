import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/montant.dart';
import '../../../data/db/kassa_database.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/clients_repository.dart';
import '../../../domain/client_saisie.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/clients.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';

/// Ajouter un client (sans [clientId]) ou le modifier : nom, téléphone et
/// note. En modification : « Supprimer le client » (refusé s'il doit encore).
class ClientFormScreen extends ConsumerStatefulWidget {
  const ClientFormScreen({super.key, this.clientId});

  final String? clientId;

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _nom = TextEditingController();
  final _telephone = TextEditingController();
  final _note = TextEditingController();
  Set<ErreurClient> _erreurs = const {};
  var _enCours = false;
  var _rempli = false;

  /// Téléphone enregistré, accepté tel quel s'il n'est pas modifié.
  String? _telephoneActuel;

  bool get _creation => widget.clientId == null;

  @override
  void dispose() {
    _nom.dispose();
    _telephone.dispose();
    _note.dispose();
    super.dispose();
  }

  void _remplir(Client c) {
    if (_rempli) return;
    _rempli = true;
    _nom.text = c.nom;
    _telephone.text = c.telephone ?? '';
    _telephoneActuel = c.telephone;
    _note.text = c.note ?? '';
  }

  ClientSaisie get _saisie => ClientSaisie(
    nom: _nom.text,
    telephone: _telephone.text,
    note: _note.text,
  );

  Future<void> _enregistrer() async {
    if (_enCours) return;
    final erreurs = ReglesClient.verifier(
      _saisie,
      telephoneActuel: _telephoneActuel,
    );
    setState(() => _erreurs = erreurs);
    if (erreurs.isNotEmpty) return;
    final l = AppLocalizations.of(context);
    setState(() => _enCours = true);
    final repo = ref.read(clientsRepositoryProvider);
    try {
      if (_creation) {
        final id = await repo.creerClient(
          nom: _nom.text,
          telephone: _telephone.text,
          note: _note.text,
        );
        if (mounted) context.pushReplacement(Chemins.client(id));
      } else {
        await repo.modifierClient(widget.clientId!, _saisie);
        if (mounted) context.pop();
      }
    } on Object {
      if (!mounted) return;
      setState(() => _enCours = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.saveError)));
    }
  }

  Future<void> _supprimer(Client c) async {
    final l = AppLocalizations.of(context);
    final langue = langueDe(context);
    final messager = ScaffoldMessenger.of(context);
    if (c.soldeDette > 0) {
      messager.showSnackBar(
        SnackBar(
          content: Text(
            l.errDeleteIndebted(c.nom, Montant.format(c.soldeDette, langue)),
          ),
        ),
      );
      return;
    }
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogue) => AlertDialog(
        title: Text(l.deleteCustomerTitle(c.nom)),
        content: Text(l.deleteCustomerBody),
        actions: [
          KassaButton(
            label: l.cancel,
            variant: KassaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogue).pop(false),
          ),
          KassaButton(
            label: l.deleteConfirm,
            variant: KassaButtonVariant.danger,
            onPressed: () => Navigator.of(dialogue).pop(true),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;
    setState(() => _enCours = true);
    try {
      await ref.read(clientsRepositoryProvider).supprimerClient(c.id);
      if (!mounted) return;
      context.go(Chemins.clients);
      messager
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.customerDeleted(c.nom))));
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _enCours = false);
      messager.showSnackBar(
        SnackBar(
          content: Text(
            e is ClientEndette
                ? l.errDeleteIndebted(
                    c.nom,
                    Montant.format(e.soldeDette, langue),
                  )
                : l.saveError,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_creation) return _formulaire(null);
    final client = ref.watch(clientProvider(widget.clientId!));
    return client.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (erreur, pile) => Scaffold(
        appBar: AppBar(),
        body: EtatVide(icone: Symbols.error_rounded, titre: l.loadError),
      ),
      data: (c) {
        if (c == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EtatVide(
              icone: Symbols.person_off_rounded,
              titre: l.customerNotFound,
            ),
          );
        }
        _remplir(c);
        return _formulaire(c);
      },
    );
  }

  Widget _formulaire(Client? c) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;

    return Scaffold(
      appBar: AppBar(
        title: Text(_creation ? l.newCustomer : l.editCustomerTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: KassaComposants.largeurContenuMax,
          ),
          child: ListView(
            padding: const EdgeInsets.all(KassaSpace.s4),
            children: [
              TextField(
                controller: _nom,
                autofocus: _creation,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_erreurs.contains(ErreurClient.nomVide)) {
                    setState(
                      () =>
                          _erreurs = {..._erreurs}
                            ..remove(ErreurClient.nomVide),
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
                textInputAction: TextInputAction.next,
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
                  helperMaxLines: 2,
                  errorMaxLines: 2,
                  errorText: _erreurs.contains(ErreurClient.telephoneInvalide)
                      ? l.errCustomerPhone
                      : null,
                ),
              ),
              const SizedBox(height: KassaSpace.s4),
              TextField(
                controller: _note,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l.customerNote,
                  helperText: l.customerNoteHint,
                  helperMaxLines: 2,
                  alignLabelWithHint: true,
                ),
              ),
              if (c != null) ...[
                const SizedBox(height: KassaSpace.s8),
                KassaButton(
                  label: l.deleteCustomer,
                  icon: Symbols.delete_rounded,
                  variant: KassaButtonVariant.danger,
                  fullWidth: true,
                  onPressed: _enCours ? null : () => _supprimer(c),
                ),
                if (c.soldeDette > 0) ...[
                  const SizedBox(height: KassaSpace.s2),
                  Text(
                    l.errDeleteIndebted(
                      c.nom,
                      Montant.format(c.soldeDette, langueDe(context)),
                    ),
                    style: t.caption.copyWith(color: t.inkMuted),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: KassaButton(
          label: _creation ? l.addCustomer : l.save,
          icon: _creation ? Symbols.person_add_rounded : Symbols.check_rounded,
          size: KassaButtonSize.main,
          fullWidth: true,
          onPressed: _enCours ? null : _enregistrer,
        ),
      ),
    );
  }
}
