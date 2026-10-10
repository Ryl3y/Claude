import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/heure_douala.dart';
import '../../../core/montant.dart';
import '../../../core/whatsapp.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../state/clients.dart';
import '../../widgets/contexte.dart';

/// Messages WhatsApp aux clients : rappel de dette et reçu de versement.
/// Écrits dans la langue de l'app, signés du nom de la boutique dès
/// qu'elle n'est plus provisoire.
abstract final class MessagesClient {
  static String rappel(
    AppLocalizations l,
    String langue, {
    required String nom,
    required int solde,
    String? boutique,
  }) {
    final montant = Montant.format(solde, langue);
    return boutique == null
        ? l.reminderMessageNoShop(nom, montant)
        : l.reminderMessage(nom, montant, boutique);
  }

  static String recu(
    AppLocalizations l,
    String langue, {
    required String nom,
    required int montant,
    required int reste,
    required DateTime date,
    String? boutique,
  }) => [
    l.receiptMessage(
      nom,
      Montant.format(montant, langue),
      HeureDouala.dateCourte(date, langue),
    ),
    if (reste > 0)
      l.receiptRemaining(Montant.format(reste, langue))
    else
      l.receiptPaidOff,
    ?boutique,
  ].join('\n');
}

/// Ouvre WhatsApp avec [message] pour [telephone]. Prévient si le numéro
/// est invalide ou si WhatsApp ne s'ouvre pas.
Future<void> envoyerWhatsApp(
  BuildContext context,
  WidgetRef ref, {
  required String? telephone,
  required String message,
}) async {
  final l = AppLocalizations.of(context);
  final messager = ScaffoldMessenger.of(context);
  final lien = WhatsApp.lien(telephone: telephone, message: message);
  var ouvert = false;
  if (lien != null) {
    try {
      ouvert = await ref.read(ouvrirLienProvider)(lien);
    } on Object {
      ouvert = false;
    }
  }
  if (!ouvert) {
    messager
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(lien == null ? l.addPhoneToRemind : l.whatsappError),
        ),
      );
  }
}

/// Le numéro de [telephone] peut-il recevoir un message WhatsApp ?
bool peutRecevoirWhatsApp(String? telephone) =>
    WhatsApp.numeroInternational(telephone) != null;

/// Rappel de dette pré-rempli, avec la signature de la boutique.
Future<void> rappelerClient(
  BuildContext context,
  WidgetRef ref, {
  required String nom,
  required String? telephone,
  required int solde,
}) async {
  final l = AppLocalizations.of(context);
  final langue = langueDe(context);
  final boutique = await ref.read(signatureBoutiqueProvider.future);
  if (!context.mounted) return;
  await envoyerWhatsApp(
    context,
    ref,
    telephone: telephone,
    message: MessagesClient.rappel(
      l,
      langue,
      nom: nom,
      solde: solde,
      boutique: boutique,
    ),
  );
}
