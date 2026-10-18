import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Code PIN à 4 chiffres, jamais gardé en clair : PBKDF2-HMAC-SHA256 avec
/// un sel aléatoire. Format : `pbkdf2-sha256$<tours>$<sel>$<empreinte>`.
abstract final class CodePin {
  static const longueur = 4;
  static const _tours = 20000;
  static const _prefixe = 'pbkdf2-sha256';

  /// Vrai si [pin] a exactement 4 chiffres.
  static bool estValide(String pin) => RegExp(r'^\d{4}$').hasMatch(pin);

  /// Empreinte à enregistrer pour [pin].
  static String hacher(String pin, {Random? aleatoire}) {
    if (!estValide(pin)) throw ArgumentError.value(pin, 'pin');
    final r = aleatoire ?? Random.secure();
    final sel = Uint8List.fromList(List.generate(16, (_) => r.nextInt(256)));
    final empreinte = _pbkdf2(utf8.encode(pin), sel, _tours);
    return [
      _prefixe,
      '$_tours',
      base64Url.encode(sel),
      base64Url.encode(empreinte),
    ].join(r'$');
  }

  /// Vrai si [pin] correspond à [empreinte] (comparaison à temps constant).
  static bool verifier(String pin, String empreinte) {
    final parties = empreinte.split(r'$');
    if (parties.length != 4 || parties[0] != _prefixe) return false;
    final tours = int.tryParse(parties[1]);
    if (tours == null || tours < 1) return false;
    final List<int> sel;
    final List<int> attendue;
    try {
      sel = base64Url.decode(parties[2]);
      attendue = base64Url.decode(parties[3]);
    } on FormatException {
      return false;
    }
    final calculee = _pbkdf2(utf8.encode(pin), sel, tours);
    if (calculee.length != attendue.length) return false;
    var difference = 0;
    for (var i = 0; i < calculee.length; i++) {
      difference |= calculee[i] ^ attendue[i];
    }
    return difference == 0;
  }

  /// PBKDF2 avec HMAC-SHA256, un seul bloc de 32 octets (RFC 8018).
  @visibleForTesting
  static List<int> pbkdf2(List<int> motDePasse, List<int> sel, int tours) =>
      _pbkdf2(motDePasse, sel, tours);

  static List<int> _pbkdf2(List<int> motDePasse, List<int> sel, int tours) {
    final hmac = Hmac(sha256, motDePasse);
    var u = hmac.convert([...sel, 0, 0, 0, 1]).bytes;
    final resultat = List<int>.from(u);
    for (var i = 1; i < tours; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < resultat.length; j++) {
        resultat[j] ^= u[j];
      }
    }
    return resultat;
  }
}
