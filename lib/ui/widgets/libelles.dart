import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../data/db/tables.dart';
import '../../domain/panier.dart';
import '../../l10n/generated/app_localizations.dart';

/// Nom d'un mode de paiement enregistré en base (« especes » → « Espèces »).
String libelleMode(AppLocalizations l, String code) => switch (code) {
  ModePaiement.especes => l.payCash,
  ModePaiement.momo => l.payMomo,
  ModePaiement.orangeMoney => l.payOrange,
  _ => l.payCredit,
};

String libelleModeChoisi(AppLocalizations l, ModeChoisi mode) => switch (mode) {
  ModeChoisi.especes => l.payCash,
  ModeChoisi.momo => l.payMomo,
  ModeChoisi.orangeMoney => l.payOrange,
  ModeChoisi.credit => l.payCredit,
};

IconData iconeMode(ModeChoisi mode) => switch (mode) {
  ModeChoisi.especes => Symbols.payments_rounded,
  ModeChoisi.momo => Symbols.smartphone_rounded,
  ModeChoisi.orangeMoney => Symbols.phone_android_rounded,
  ModeChoisi.credit => Symbols.menu_book_rounded,
};
