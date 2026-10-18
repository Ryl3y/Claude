import 'package:flutter/painting.dart';

/// Palette Kassa, valeurs exactes de la charte graphique.
///
/// Deux jeux, clair et sombre, avec les mêmes noms de jetons.
/// On ne lit jamais ces couleurs directement dans un écran :
/// on passe par `Theme.of(context).colorScheme` ou `context.kassa`.
class KassaPalette {
  const KassaPalette({
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
  });

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

  /// Anneau de focus : alias de [kassa].
  Color get focus => kassa;

  static const clair = KassaPalette(
    surface: Color(0xFFF6F8F5),
    surfaceRaised: Color(0xFFFFFFFF),
    line: Color(0xFFDDE4DE),
    ink: Color(0xFF13241A),
    inkMuted: Color(0xFF56675C),
    kassa: Color(0xFF1D7349),
    kassaSoft: Color(0xFFE2F3E8),
    onKassa: Color(0xFFFFFFFF),
    kassaDeep: Color(0xFF0E3B26),
    onKassaDeep: Color(0xFFFFFFFF),
    or: Color(0xFFF2B233),
    onOr: Color(0xFF2B1D00),
    orSoft: Color(0xFFFDF3DC),
    orInk: Color(0xFF7A5200),
    dette: Color(0xFFB42318),
    detteSoft: Color(0xFFFDECEA),
  );

  static const sombre = KassaPalette(
    surface: Color(0xFF0F1712),
    surfaceRaised: Color(0xFF17221B),
    line: Color(0xFF2A372F),
    ink: Color(0xFFEDF3EE),
    inkMuted: Color(0xFFA1B2A6),
    kassa: Color(0xFF4CC58A),
    kassaSoft: Color(0xFF123222),
    onKassa: Color(0xFF0F1712),
    kassaDeep: Color(0xFF1E5A3D),
    onKassaDeep: Color(0xFFEDF3EE),
    or: Color(0xFFF5C058),
    onOr: Color(0xFF2B1D00),
    orSoft: Color(0xFF33270A),
    orInk: Color(0xFFF5C058),
    dette: Color(0xFFF97066),
    detteSoft: Color(0xFF3A1513),
  );
}
