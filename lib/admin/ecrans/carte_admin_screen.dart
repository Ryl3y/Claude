import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../ui/theme/kassa_tokens.dart';
import '../donnees/serveur_admin.dart';
import '../etat/etat_admin.dart';
import '../ui/carte_cameroun.dart';
import '../ui/communs.dart';

/// Zones couvertes : la carte, et la liste des villes (même information,
/// lisible sans la carte).
class CarteAdminScreen extends ConsumerWidget {
  const CarteAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final zones = ref.watch(zonesAdminProvider);
    final large = MediaQuery.sizeOf(context).width >= largeurBureau;

    return ListView(
      padding: const EdgeInsets.all(KassaSpace.s4),
      children: [
        switch (zones) {
          AsyncData(:final value) when value.isEmpty => CarteAdmin(
            titre: l.adminMapTitle,
            child: Text(l.adminMapEmpty),
          ),
          AsyncData(:final value) =>
            large
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: CarteAdmin(
                          titre: l.adminMapTitle,
                          child: CarteCameroun(zones: value, hauteur: 560),
                        ),
                      ),
                      const SizedBox(width: KassaSpace.s4),
                      Expanded(flex: 2, child: _ListeVilles(zones: value)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CarteAdmin(
                        titre: l.adminMapTitle,
                        child: CarteCameroun(zones: value, hauteur: 420),
                      ),
                      const SizedBox(height: KassaSpace.s4),
                      _ListeVilles(zones: value),
                    ],
                  ),
          AsyncError() => ErreurAdmin(
            reessayer: () => ref.invalidate(zonesAdminProvider),
          ),
          _ => const ChargementAdmin(),
        },
      ],
    );
  }
}

class _ListeVilles extends StatelessWidget {
  const _ListeVilles({required this.zones});

  final List<ZoneAdmin> zones;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.kassa;
    final surCarte = [
      for (final z in zones)
        if (villesCameroun.containsKey(cleVille(z.ville))) z,
    ];
    final ailleurs = [
      for (final z in zones)
        if (!villesCameroun.containsKey(cleVille(z.ville))) z,
    ];
    Widget ligne(ZoneAdmin z) => Padding(
      padding: const EdgeInsets.only(bottom: KassaSpace.s2),
      child: MergeSemantics(
        child: Wrap(
          spacing: KassaSpace.s2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              z.ville.isEmpty ? '—' : z.ville,
              style: t.label.copyWith(color: t.ink),
            ),
            Text(
              '${l.adminShopsCount(z.boutiques)} · ${z.pro} ${l.proBadge}',
              style: t.body.copyWith(color: t.ink),
            ),
          ],
        ),
      ),
    );
    return CarteAdmin(
      titre: l.adminNavMap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final z in surCarte) ligne(z),
          if (ailleurs.isNotEmpty) ...[
            const SizedBox(height: KassaSpace.s2),
            Text(l.adminMapOffMap, style: t.label.copyWith(color: t.inkMuted)),
            const SizedBox(height: KassaSpace.s2),
            for (final z in ailleurs) ligne(z),
          ],
        ],
      ),
    );
  }
}
