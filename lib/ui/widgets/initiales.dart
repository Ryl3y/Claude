import 'package:flutter/widgets.dart';

/// Les deux premières lettres d'un nom, en majuscules (« Riz 5 kg » → « RI »).
String initiales(String nom) {
  final lettres = nom.trim().replaceAll(RegExp(r'\s+'), '').characters.take(2);
  return lettres.isEmpty ? '?' : lettres.toString().toUpperCase();
}
