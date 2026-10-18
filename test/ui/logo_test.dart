import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/ui/brand/kassa_logo.dart';

String _sansEspaces(String s) => s
    .replaceAll(RegExp(r'\s+'), '')
    .replaceAll('xmlns="http://www.w3.org/2000/svg"', '');

void main() {
  // Les SVG du code et ceux de assets/logo doivent rester identiques.
  test('symbole principal = assets/logo/kassa_symbole.svg', () {
    expect(
      _sansEspaces(KassaSvg.principal()),
      _sansEspaces(File('assets/logo/kassa_symbole.svg').readAsStringSync()),
    );
  });

  test('petit symbole = assets/logo/kassa_symbole_petit.svg', () {
    expect(
      _sansEspaces(KassaSvg.petit),
      _sansEspaces(
        File('assets/logo/kassa_symbole_petit.svg').readAsStringSync(),
      ),
    );
  });

  test('symbole sur fond foncé = assets/logo/kassa_symbole_fonce.svg', () {
    expect(
      _sansEspaces(KassaSvg.surFonce()),
      _sansEspaces(
        File('assets/logo/kassa_symbole_fonce.svg').readAsStringSync(),
      ),
    );
  });

  test('sur fond foncé, le K et la pièce prennent la couleur du fond', () {
    final svg = KassaSvg.pour(
      KassaSymboleVariante.surFonce,
      contourPiece: const Color(0xFF1E5A3D),
    );
    expect('#1e5a3d'.allMatches(svg).length, 2);
    expect(svg.contains('#0e3b26'), isFalse);
  });
}
