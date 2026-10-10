import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/heure_douala.dart';
import '../../../core/saisie.dart';
import '../../../data/repositories/clients_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../router.dart';
import '../../state/clients.dart';
import '../../theme/kassa_composants.dart';
import '../../theme/kassa_tokens.dart';
import '../../widgets/contexte.dart';
import '../../widgets/widgets.dart';
import 'whatsapp_client.dart';

/// Écran 12 : les clients, plus grosse dette d'abord, avec le total des
/// dettes à recevoir, la recherche et le rappel WhatsApp en un toucher.
class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final resumes = ref.watch(clientsResumesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.navCustomers)),
      body: resumes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, pile) =>
            EtatVide(icone: Symbols.error_rounded, titre: l.loadError),
        data: (liste) => liste.isEmpty
            ? EtatVide(
                icone: Symbols.group_rounded,
                titre: l.customersEmptyTitle,
                message: l.customersEmptyBody,
              )
            : _Liste(resumes: liste, recherche: _recherche),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(KassaSpace.s4),
        child: KassaButton(
          label: l.newCustomer,
          icon: Symbols.person_add_rounded,
          size: KassaButtonSize.main,
          fullWidth: true,
          onPressed: () => context.push(Chemins.nouveauClient),
        ),
      ),
    );
  }
}

class _Liste extends ConsumerStatefulWidget {
  const _Liste({required this.resumes, required this.recherche});

  final List<ClientResume> resumes;
  final TextEditingController recherche;

  @override
  ConsumerState<_Liste> createState() => _ListeState();
}

class _ListeState extends ConsumerState<_Liste> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final langue = langueDe(context);
    final texte = widget.recherche.text.trim();
    final cherche = Saisie.pourRecherche(texte);
    final chiffres = texte.replaceAll(RegExp('[^0-9]'), '');
    final filtres = [
      for (final r in widget.resumes)
        if (cherche.isEmpty ||
            Saisie.pourRecherche(r.client.nom).contains(cherche) ||
            (chiffres.isNotEmpty &&
                (r.client.telephone ?? '')
                    .replaceAll(RegExp('[^0-9]'), '')
                    .contains(chiffres)))
          r,
    ];
    // Seules les dettes comptent : un solde négatif (trop-perçu après une
    // synchronisation) ne doit pas baisser le total à recevoir.
    final total = widget.resumes.fold(
      0,
      (s, r) => s + (r.client.soldeDette > 0 ? r.client.soldeDette : 0),
    );
    final debiteurs = widget.resumes
        .where((r) => r.client.soldeDette > 0)
        .length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: KassaComposants.largeurContenuMax,
        ),
        child: ListView(
          padding: const EdgeInsets.all(KassaSpace.s4),
          children: [
            StatTile(
              label: l.moneyOwed,
              value: total,
              tone: total > 0 ? AmountTone.dette : AmountTone.neutre,
              hint: l.debtorsCount(debiteurs),
            ),
            const SizedBox(height: KassaSpace.s4),
            TextField(
              controller: widget.recherche,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l.searchCustomers,
                prefixIcon: const Icon(Symbols.search_rounded),
              ),
            ),
            const SizedBox(height: KassaSpace.s4),
            if (filtres.isEmpty)
              Padding(
                padding: const EdgeInsets.all(KassaSpace.s4),
                child: Text(
                  l.noCustomerMatch(texte),
                  style: t.body.copyWith(color: t.inkMuted),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(KassaRadius.md),
                child: Column(
                  children: [
                    for (final (i, r) in filtres.indexed) ...[
                      if (i > 0) const Divider(),
                      ClientRow(
                        nom: r.client.nom,
                        meta: _meta(l, langue, r),
                        montantDu: r.client.soldeDette,
                        onTap: () => context.push(Chemins.client(r.client.id)),
                        onRappel: peutRecevoirWhatsApp(r.client.telephone)
                            ? () => rappelerClient(
                                context,
                                ref,
                                nom: r.client.nom,
                                telephone: r.client.telephone,
                                solde: r.client.soldeDette,
                              )
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// « Dernier achat hier », sinon le téléphone, sinon rien.
  String _meta(AppLocalizations l, String langue, ClientResume r) {
    final achat = r.dernierAchat;
    if (achat == null) return r.client.telephone ?? '';
    final jour = HeureDouala.debutDuJourUtc(achat);
    final aujourdhui = HeureDouala.debutDuJourUtc(HeureDouala.maintenantUtc());
    if (jour == aujourdhui) return l.lastPurchaseToday;
    if (jour == aujourdhui.subtract(const Duration(days: 1))) {
      return l.lastPurchaseYesterday;
    }
    return l.lastPurchaseOn(HeureDouala.dateCourte(achat, langue));
  }
}
