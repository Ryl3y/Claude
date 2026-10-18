import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/kassa_tokens.dart';

/// Icône WhatsApp de la charte (trait arrondi de 2 px, couleur du texte).
/// Material Symbols n'a pas de pictogramme WhatsApp.
class IconeWhatsApp extends StatelessWidget {
  const IconeWhatsApp({
    super.key,
    this.taille = KassaSize.icon,
    required this.couleur,
  });

  final double taille;
  final Color couleur;

  static const _svg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
      'fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" '
      'stroke-linejoin="round"><path d="M4 20l1.3-3.9A8 8 0 1 1 8 19zM9 9.5c.3 2.3 '
      '2.2 4.2 4.5 4.6l1.2-1.2 1.8.8-.4 1.7c-3.5.2-7.4-3.7-7.2-7.2l1.7-.4.8 1.8z"/></svg>';

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    _svg,
    width: taille,
    height: taille,
    theme: SvgTheme(currentColor: couleur),
    excludeFromSemantics: true,
  );
}
