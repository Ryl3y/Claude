import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/kassa_composants.dart';
import '../theme/kassa_tokens.dart';
import 'amount_text.dart';
import 'icone_whatsapp.dart';
import 'initiales.dart';

/// Une ligne de la liste des clients : initiales, nom, une info (téléphone
/// ou dernier achat) et ce que le client doit.
///
/// Dette > 0 : « Doit … » en rouge, et un bouton WhatsApp si [onRappel]
/// est fourni (l'appelant ouvre le lien wa.me pré-rempli). Sinon « À jour ».
class ClientRow extends StatelessWidget {
  const ClientRow({
    super.key,
    required this.nom,
    required this.meta,
    required this.montantDu,
    this.onTap,
    this.onRappel,
  });

  final String nom;
  final String meta;

  /// Dette du client en FCFA (0 = à jour).
  final int montantDu;
  final VoidCallback? onTap;
  final VoidCallback? onRappel;

  @override
  Widget build(BuildContext context) {
    final t = context.kassa;
    final l = AppLocalizations.of(context);
    final doit = montantDu > 0;

    return Material(
      color: t.surfaceRaised,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: KassaComposants.ligneClientHauteur,
        ),
        child: Row(
          children: [
            Expanded(
              child: MergeSemantics(
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KassaSpace.s4,
                      KassaSpace.s2,
                      KassaSpace.s2,
                      KassaSpace.s2,
                    ),
                    child: Row(
                      children: [
                        ExcludeSemantics(
                          child: Container(
                            width: KassaComposants.avatarClient,
                            height: KassaComposants.avatarClient,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: t.kassaSoft,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              initiales(nom),
                              style: t.initialesClient.copyWith(color: t.kassa),
                            ),
                          ),
                        ),
                        const SizedBox(width: KassaSpace.s4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nom,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.label.copyWith(
                                  fontSize: t.body.fontSize,
                                  height: t.body.height,
                                ),
                              ),
                              if (meta.isNotEmpty)
                                Text(
                                  meta,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.caption.copyWith(color: t.inkMuted),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: KassaSpace.s2),
                        // Le nom garde la place libre ; le montant prend au
                        // plus 45 % de la ligne et rétrécit avec un très
                        // grand texte plutôt que de déborder.
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.sizeOf(context).width *
                                KassaComposants.partMaxMontantLigne,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: doit
                                ? AmountText(
                                    value: montantDu,
                                    tone: AmountTone.dette,
                                    short: true,
                                  )
                                : Text(
                                    l.paidUp,
                                    style: t.label.copyWith(color: t.kassa),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (doit && onRappel != null)
              Padding(
                padding: const EdgeInsets.only(right: KassaSpace.s4),
                child: IconButton(
                  onPressed: onRappel,
                  tooltip: l.remindOnWhatsapp(nom),
                  style: IconButton.styleFrom(
                    backgroundColor: t.kassaSoft,
                    minimumSize: const Size(
                      KassaSize.touchMin,
                      KassaSize.touchMin,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(KassaRadius.md),
                      ),
                    ),
                  ),
                  icon: IconeWhatsApp(couleur: t.kassa),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
