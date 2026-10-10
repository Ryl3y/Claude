import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'kassa_colors.dart';
import 'kassa_composants.dart';
import 'kassa_tokens.dart';

/// Thème Kassa (clair et sombre).
///
/// ColorScheme : primary = kassa, onPrimary = on-kassa,
/// primaryContainer = kassa-soft, secondary = or, onSecondary = on-or,
/// error = dette, errorContainer = dette-soft, surface = surface-raised,
/// outline = line. Tout le reste est dans [KassaTokens].
abstract final class KassaTheme {
  static ThemeData clair() => _build(Brightness.light, KassaPalette.clair);
  static ThemeData sombre() => _build(Brightness.dark, KassaPalette.sombre);

  /// Police de base : Plus Jakarta Sans via google_fonts.
  /// Les fichiers sont embarqués dans assets/fonts (aucun téléchargement).
  static TextStyle _police(FontWeight graisse) =>
      GoogleFonts.plusJakartaSans(fontWeight: graisse);

  static ThemeData _build(Brightness brightness, KassaPalette p) {
    final textes = KassaTextStyles.build(_police, p.ink);
    final tokens = KassaTokens.from(p, textes);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.kassa,
      onPrimary: p.onKassa,
      primaryContainer: p.kassaSoft,
      onPrimaryContainer: p.ink,
      secondary: p.or,
      onSecondary: p.onOr,
      secondaryContainer: p.orSoft,
      onSecondaryContainer: p.orInk,
      tertiary: p.kassaDeep,
      onTertiary: p.onKassaDeep,
      error: p.dette,
      onError: p.onKassa,
      errorContainer: p.detteSoft,
      onErrorContainer: p.dette,
      surface: p.surfaceRaised,
      onSurface: p.ink,
      onSurfaceVariant: p.inkMuted,
      surfaceContainerLowest: p.surfaceRaised,
      surfaceContainerLow: p.surfaceRaised,
      surfaceContainer: p.surfaceRaised,
      surfaceContainerHigh: p.surfaceRaised,
      surfaceContainerHighest: p.surface,
      outline: p.line,
      outlineVariant: p.line,
      shadow: const Color(0xFF13241A),
      surfaceTint: Colors.transparent,
    );

    final textTheme = TextTheme(
      displaySmall: textes.display,
      headlineSmall: textes.title,
      titleLarge: textes.title,
      titleMedium: textes.label.copyWith(fontSize: 16, height: 24 / 16),
      titleSmall: textes.label,
      bodyLarge: textes.body,
      bodyMedium: textes.body,
      bodySmall: textes.caption.copyWith(color: p.inkMuted),
      labelLarge: textes.label,
      labelMedium: textes.label,
      labelSmall: textes.caption,
    );

    const rayonMd = BorderRadius.all(Radius.circular(KassaRadius.md));
    const rayonSm = BorderRadius.all(Radius.circular(KassaRadius.sm));
    const tailleBouton = Size(KassaSize.touchMin, KassaSize.touchMin);
    const paddingBouton = EdgeInsets.symmetric(horizontal: KassaSpace.s4);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      fontFamily: textes.body.fontFamily,
      scaffoldBackgroundColor: p.surface,
      canvasColor: p.surface,
      dividerColor: p.line,
      focusColor: p.focus.withValues(alpha: 0.16),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      extensions: [tokens],
      iconTheme: IconThemeData(color: p.ink, size: KassaSize.icon),
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textes.title,
      ),
      dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: p.surfaceRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: rayonMd),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.kassa,
          foregroundColor: p.onKassa,
          minimumSize: tailleBouton,
          padding: paddingBouton,
          shape: const RoundedRectangleBorder(borderRadius: rayonMd),
          textStyle: textes.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: tailleBouton,
          padding: paddingBouton,
          side: BorderSide(color: p.line),
          shape: const RoundedRectangleBorder(borderRadius: rayonMd),
          textStyle: textes.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.kassa,
          minimumSize: tailleBouton,
          padding: paddingBouton,
          shape: const RoundedRectangleBorder(borderRadius: rayonMd),
          textStyle: textes.label,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: tailleBouton,
          selectedBackgroundColor: p.kassaSoft,
          selectedForegroundColor: p.ink,
          foregroundColor: p.ink,
          side: BorderSide(color: p.line),
          textStyle: textes.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KassaSpace.s4,
          vertical: KassaSpace.s4,
        ),
        labelStyle: textes.label.copyWith(color: p.inkMuted),
        hintStyle: textes.body.copyWith(color: p.inkMuted),
        helperStyle: textes.caption.copyWith(color: p.inkMuted),
        errorStyle: textes.caption.copyWith(color: p.dette),
        border: OutlineInputBorder(
          borderRadius: rayonSm,
          borderSide: BorderSide(color: p.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: rayonSm,
          borderSide: BorderSide(color: p.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: rayonSm,
          borderSide: BorderSide(color: p.focus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: rayonSm,
          borderSide: BorderSide(color: p.dette),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: rayonSm,
          borderSide: BorderSide(color: p.dette, width: 2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: p.line,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(KassaRadius.lg),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: KassaComposants.navHauteur,
        indicatorColor: p.kassaSoft,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? tokens.ongletActif.copyWith(color: p.kassa)
              : tokens.onglet.copyWith(color: p.inkMuted),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: KassaSize.iconNav,
            color: states.contains(WidgetState.selected) ? p.kassa : p.inkMuted,
          ),
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: p.or,
        textColor: p.onOr,
        textStyle: tokens.etiquette,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceRaised,
        selectedColor: p.kassaSoft,
        side: BorderSide(color: p.line),
        labelStyle: textes.label,
        shape: const RoundedRectangleBorder(borderRadius: rayonSm),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: textes.body.copyWith(color: p.surface),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: rayonMd),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: rayonMd),
        titleTextStyle: textes.title,
        contentTextStyle: textes.body,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.kassa),
      listTileTheme: ListTileThemeData(
        minTileHeight: KassaSize.touchMin,
        iconColor: p.ink,
        textColor: p.ink,
        titleTextStyle: textes.body,
        subtitleTextStyle: textes.caption.copyWith(color: p.inkMuted),
      ),
    );
  }
}
