import 'package:flutter/material.dart';

import 'kassa_colors.dart';

/// Espacements de la charte (grille de 4 px).
abstract final class KassaSpace {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s4 = 16;
  static const double s6 = 24;
  static const double s8 = 32;
}

/// Rayons des coins.
abstract final class KassaRadius {
  /// Champs de saisie, puces, badges.
  static const double sm = 8;

  /// Boutons, cartes.
  static const double md = 14;

  /// Feuilles du bas.
  static const double lg = 24;
}

/// Tailles minimales des zones touchables.
abstract final class KassaSize {
  /// Tout élément touchable.
  static const double touchMin = 48;

  /// Bouton principal (Nouvelle vente, Encaisser).
  static const double buttonMain = 56;

  /// Icônes : 24 px, 28 px dans la barre du bas.
  static const double icon = 24;
  static const double iconNav = 28;
}

/// Seule ombre du système : panier et feuilles du bas.
/// `0 -4px 16px rgba(19,36,26,0.12)`.
const kassaShadowSheet = <BoxShadow>[
  BoxShadow(
    offset: Offset(0, -4),
    blurRadius: 16,
    color: Color.fromRGBO(19, 36, 26, 0.12),
  ),
];

/// Jetons Kassa qui n'ont pas de place dans [ColorScheme] :
/// toutes les couleurs nommées de la charte et les styles de texte
/// (dont `amount` et `amountLg`, en chiffres tabulaires).
///
/// Accès : `context.kassa.orInk`, `context.kassa.amountLg`…
@immutable
class KassaTokens extends ThemeExtension<KassaTokens> {
  const KassaTokens({
    required this.surface,
    required this.surfaceRaised,
    required this.line,
    required this.ink,
    required this.inkMuted,
    required this.kassa,
    required this.kassaSoft,
    required this.onKassa,
    required this.kassaDeep,
    required this.onKassaDeep,
    required this.or,
    required this.onOr,
    required this.orSoft,
    required this.orInk,
    required this.dette,
    required this.detteSoft,
    required this.focus,
    required this.display,
    required this.title,
    required this.amountLg,
    required this.amount,
    required this.body,
    required this.label,
    required this.caption,
  });

  factory KassaTokens.from(KassaPalette p, KassaTextStyles t) => KassaTokens(
        surface: p.surface,
        surfaceRaised: p.surfaceRaised,
        line: p.line,
        ink: p.ink,
        inkMuted: p.inkMuted,
        kassa: p.kassa,
        kassaSoft: p.kassaSoft,
        onKassa: p.onKassa,
        kassaDeep: p.kassaDeep,
        onKassaDeep: p.onKassaDeep,
        or: p.or,
        onOr: p.onOr,
        orSoft: p.orSoft,
        orInk: p.orInk,
        dette: p.dette,
        detteSoft: p.detteSoft,
        focus: p.focus,
        display: t.display,
        title: t.title,
        amountLg: t.amountLg,
        amount: t.amount,
        body: t.body,
        label: t.label,
        caption: t.caption,
      );

  final Color surface;
  final Color surfaceRaised;
  final Color line;
  final Color ink;
  final Color inkMuted;
  final Color kassa;
  final Color kassaSoft;
  final Color onKassa;
  final Color kassaDeep;
  final Color onKassaDeep;
  final Color or;
  final Color onOr;
  final Color orSoft;
  final Color orInk;
  final Color dette;
  final Color detteSoft;
  final Color focus;

  /// 32/40 w800 — titre de l'écran de bienvenue.
  final TextStyle display;

  /// 22/28 w700 — titre d'écran.
  final TextStyle title;

  /// 36/44 w800, chiffres tabulaires — total de la vente, ventes du jour.
  final TextStyle amountLg;

  /// 20/28 w700, chiffres tabulaires — montants dans les cartes et listes.
  final TextStyle amount;

  /// 16/24 w400 — texte courant.
  final TextStyle body;

  /// 14/20 w600 — boutons, onglets, libellés.
  final TextStyle label;

  /// 12/16 w500 — dates, unités, aides.
  final TextStyle caption;

  @override
  KassaTokens copyWith({
    Color? surface,
    Color? surfaceRaised,
    Color? line,
    Color? ink,
    Color? inkMuted,
    Color? kassa,
    Color? kassaSoft,
    Color? onKassa,
    Color? kassaDeep,
    Color? onKassaDeep,
    Color? or,
    Color? onOr,
    Color? orSoft,
    Color? orInk,
    Color? dette,
    Color? detteSoft,
    Color? focus,
    TextStyle? display,
    TextStyle? title,
    TextStyle? amountLg,
    TextStyle? amount,
    TextStyle? body,
    TextStyle? label,
    TextStyle? caption,
  }) {
    return KassaTokens(
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      line: line ?? this.line,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      kassa: kassa ?? this.kassa,
      kassaSoft: kassaSoft ?? this.kassaSoft,
      onKassa: onKassa ?? this.onKassa,
      kassaDeep: kassaDeep ?? this.kassaDeep,
      onKassaDeep: onKassaDeep ?? this.onKassaDeep,
      or: or ?? this.or,
      onOr: onOr ?? this.onOr,
      orSoft: orSoft ?? this.orSoft,
      orInk: orInk ?? this.orInk,
      dette: dette ?? this.dette,
      detteSoft: detteSoft ?? this.detteSoft,
      focus: focus ?? this.focus,
      display: display ?? this.display,
      title: title ?? this.title,
      amountLg: amountLg ?? this.amountLg,
      amount: amount ?? this.amount,
      body: body ?? this.body,
      label: label ?? this.label,
      caption: caption ?? this.caption,
    );
  }

  @override
  KassaTokens lerp(ThemeExtension<KassaTokens>? other, double t) {
    if (other is! KassaTokens) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    TextStyle s(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return KassaTokens(
      surface: c(surface, other.surface),
      surfaceRaised: c(surfaceRaised, other.surfaceRaised),
      line: c(line, other.line),
      ink: c(ink, other.ink),
      inkMuted: c(inkMuted, other.inkMuted),
      kassa: c(kassa, other.kassa),
      kassaSoft: c(kassaSoft, other.kassaSoft),
      onKassa: c(onKassa, other.onKassa),
      kassaDeep: c(kassaDeep, other.kassaDeep),
      onKassaDeep: c(onKassaDeep, other.onKassaDeep),
      or: c(or, other.or),
      onOr: c(onOr, other.onOr),
      orSoft: c(orSoft, other.orSoft),
      orInk: c(orInk, other.orInk),
      dette: c(dette, other.dette),
      detteSoft: c(detteSoft, other.detteSoft),
      focus: c(focus, other.focus),
      display: s(display, other.display),
      title: s(title, other.title),
      amountLg: s(amountLg, other.amountLg),
      amount: s(amount, other.amount),
      body: s(body, other.body),
      label: s(label, other.label),
      caption: s(caption, other.caption),
    );
  }
}

/// Les sept styles de texte de la charte.
class KassaTextStyles {
  const KassaTextStyles({
    required this.display,
    required this.title,
    required this.amountLg,
    required this.amount,
    required this.body,
    required this.label,
    required this.caption,
  });

  /// Construit les styles à partir d'un style de base (la police)
  /// et de la couleur du texte principal.
  factory KassaTextStyles.build(TextStyle base, Color ink) {
    const tabular = [FontFeature.tabularFigures()];
    TextStyle style(double size, double height, FontWeight weight,
            {bool chiffres = false}) =>
        base.copyWith(
          fontSize: size,
          height: height / size,
          fontWeight: weight,
          color: ink,
          fontFeatures: chiffres ? tabular : null,
          leadingDistribution: TextLeadingDistribution.even,
        );

    return KassaTextStyles(
      display: style(32, 40, FontWeight.w800),
      title: style(22, 28, FontWeight.w700),
      amountLg: style(36, 44, FontWeight.w800, chiffres: true),
      amount: style(20, 28, FontWeight.w700, chiffres: true),
      body: style(16, 24, FontWeight.w400),
      label: style(14, 20, FontWeight.w600),
      caption: style(12, 16, FontWeight.w500),
    );
  }

  final TextStyle display;
  final TextStyle title;
  final TextStyle amountLg;
  final TextStyle amount;
  final TextStyle body;
  final TextStyle label;
  final TextStyle caption;
}

/// Raccourci : `context.kassa`.
extension KassaContext on BuildContext {
  KassaTokens get kassa => Theme.of(this).extension<KassaTokens>()!;
}

/// Lettres resserrées de −3 % pour le nom « kassa ».
double kassaWordmarkSpacing(double fontSize) => -0.03 * fontSize;
