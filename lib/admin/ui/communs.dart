import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../ui/theme/kassa_tokens.dart';
import '../../ui/widgets/kassa_button.dart';
import '../etat/etat_admin.dart';

/// Largeur à partir de laquelle l'admin affiche le menu latéral et les
/// panneaux côte à côte (ordinateur).
const largeurBureau = 900.0;

/// Une date du serveur (jour sans heure) : « 9 nov. 2026 ».
String jourAdmin(DateTime jour, String langue) =>
    DateFormat('d MMM y', langue).format(jour);

/// Une carte du tableau de bord : titre et contenu sur fond surface-raised.
class CarteAdmin extends StatelessWidget {
  const CarteAdmin({
    super.key,
    required this.titre,
    required this.child,
    this.action,
  });

  final String titre;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    return Container(
      padding: const EdgeInsets.all(KassaSpace.s4),
      decoration: BoxDecoration(
        color: t.surfaceRaised,
        borderRadius: BorderRadius.circular(KassaRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(titre, style: t.label.copyWith(color: t.ink)),
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: KassaSpace.s4),
          child,
        ],
      ),
    );
  }
}

/// Chargement en cours.
class ChargementAdmin extends StatelessWidget {
  const ChargementAdmin({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(KassaSpace.s6),
    child: Center(child: CircularProgressIndicator()),
  );
}

/// Échec du chargement, avec « Réessayer ». Une session expirée ou un
/// compte retiré des admins renvoie à la connexion.
class ErreurAdmin extends ConsumerStatefulWidget {
  const ErreurAdmin({super.key, required this.reessayer});

  final VoidCallback reessayer;

  @override
  ConsumerState<ErreurAdmin> createState() => _ErreurAdminState();
}

class _ErreurAdminState extends ConsumerState<ErreurAdmin> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sessionAdminProvider.notifier).verifier());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    return Padding(
      padding: const EdgeInsets.all(KassaSpace.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.cloud_off_rounded, color: t.dette),
              const SizedBox(width: KassaSpace.s2),
              Flexible(
                child: Text(
                  l.adminLoadError,
                  style: t.body.copyWith(color: t.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: KassaSpace.s4),
          KassaButton(
            label: l.adminRetry,
            icon: Symbols.refresh_rounded,
            variant: KassaButtonVariant.secondary,
            onPressed: widget.reessayer,
          ),
        ],
      ),
    );
  }
}
