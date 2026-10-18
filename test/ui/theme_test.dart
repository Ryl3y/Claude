import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kassa/ui/state/langue.dart';
import 'package:kassa/ui/theme/kassa_colors.dart';
import 'package:kassa/ui/theme/kassa_theme.dart';
import 'package:kassa/ui/theme/kassa_tokens.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('ColorScheme clair conforme à la charte', () {
    final s = KassaTheme.clair().colorScheme;
    expect(s.primary, const Color(0xFF1D7349));
    expect(s.onPrimary, const Color(0xFFFFFFFF));
    expect(s.primaryContainer, const Color(0xFFE2F3E8));
    expect(s.secondary, const Color(0xFFF2B233));
    expect(s.onSecondary, const Color(0xFF2B1D00));
    expect(s.error, const Color(0xFFB42318));
    expect(s.errorContainer, const Color(0xFFFDECEA));
    expect(s.surface, const Color(0xFFFFFFFF));
    expect(s.outline, const Color(0xFFDDE4DE));
  });

  test('ColorScheme sombre conforme à la charte', () {
    final s = KassaTheme.sombre().colorScheme;
    expect(s.brightness, Brightness.dark);
    expect(s.primary, const Color(0xFF4CC58A));
    expect(s.onPrimary, const Color(0xFF0F1712));
    expect(s.primaryContainer, const Color(0xFF123222));
    expect(s.secondary, const Color(0xFFF5C058));
    expect(s.error, const Color(0xFFF97066));
    expect(s.errorContainer, const Color(0xFF3A1513));
    expect(s.surface, const Color(0xFF17221B));
    expect(s.outline, const Color(0xFF2A372F));
  });

  test('KassaTokens : couleurs hors ColorScheme et styles de texte', () {
    final t = KassaTheme.clair().extension<KassaTokens>()!;
    expect(t.orInk, KassaPalette.clair.orInk);
    expect(t.kassaDeep, const Color(0xFF0E3B26));
    expect(t.focus, t.kassa);

    expect(t.display.fontSize, 32);
    expect(t.display.fontSize! * t.display.height!, closeTo(40, 0.01));
    expect(t.display.fontWeight, FontWeight.w800);
    expect(t.title.fontSize, 22);
    expect(t.amountLg.fontSize, 36);
    expect(t.amountLg.fontWeight, FontWeight.w800);
    expect(t.amount.fontSize, 20);
    expect(t.body.fontSize, 16);
    expect(t.label.fontWeight, FontWeight.w600);
    expect(t.caption.fontSize, 12);

    // Chiffres tabulaires pour les montants.
    expect(t.amount.fontFeatures, contains(const FontFeature.tabularFigures()));
    expect(
      t.amountLg.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    // Chaque graisse utilise son propre fichier de police (pas de faux gras).
    expect(t.body.fontFamily, 'PlusJakartaSans_regular');
    expect(t.caption.fontFamily, 'PlusJakartaSans_500');
    expect(t.label.fontFamily, 'PlusJakartaSans_600');
    expect(t.title.fontFamily, 'PlusJakartaSans_700');
    expect(t.display.fontFamily, 'PlusJakartaSans_800');
    expect(t.amountLg.fontFamily, 'PlusJakartaSans_800');
  });

  test('lerp entre clair et sombre', () {
    final a = KassaTheme.clair().extension<KassaTokens>()!;
    final b = KassaTheme.sombre().extension<KassaTokens>()!;
    expect(a.lerp(b, 0).kassa, a.kassa);
    expect(a.lerp(b, 1).kassa, b.kassa);
  });

  test('ombre unique des feuilles du bas', () {
    final o = kassaShadowSheet.single;
    expect(o.offset, const Offset(0, -4));
    expect(o.blurRadius, 16);
    expect(o.color, const Color.fromRGBO(19, 36, 26, 0.12));
  });

  test('langue : suit le téléphone, français par défaut', () {
    expect(resoudreLangue([const Locale('en', 'US')]), const Locale('en'));
    expect(resoudreLangue([const Locale('fr', 'CM')]), const Locale('fr'));
    expect(resoudreLangue([const Locale('de')]), const Locale('fr'));
    expect(resoudreLangue(null), const Locale('fr'));
  });
}
