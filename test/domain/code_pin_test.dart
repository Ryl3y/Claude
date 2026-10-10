import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/domain/code_pin.dart';

void main() {
  test('le bon code est accepté, un autre refusé', () {
    final e = CodePin.hacher('1234');
    expect(CodePin.verifier('1234', e), isTrue);
    expect(CodePin.verifier('1235', e), isFalse);
    expect(CodePin.verifier('', e), isFalse);
  });

  test('jamais en clair, sel différent à chaque fois', () {
    final a = CodePin.hacher('1234');
    final b = CodePin.hacher('1234');
    expect(a, isNot(contains('1234')));
    expect(a, isNot(b));
    expect(a, startsWith(r'pbkdf2-sha256$20000$'));
  });

  test('empreinte abîmée ou d\'un autre format : refusée', () {
    expect(CodePin.verifier('1234', ''), isFalse);
    expect(CodePin.verifier('1234', 'hache'), isFalse);
    expect(CodePin.verifier('1234', r'pbkdf2-sha256$x$a$b'), isFalse);
    expect(CodePin.verifier('1234', r'pbkdf2-sha256$10$@@@$@@@'), isFalse);
  });

  test('seulement 4 chiffres', () {
    expect(CodePin.estValide('1234'), isTrue);
    expect(CodePin.estValide('123'), isFalse);
    expect(CodePin.estValide('12a4'), isFalse);
    expect(() => CodePin.hacher('12'), throwsArgumentError);
  });

  test('PBKDF2-HMAC-SHA256 : vecteurs de référence (RFC 7914)', () {
    String hex(List<int> o) =>
        o.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    expect(
      hex(CodePin.pbkdf2(utf8.encode('passwd'), utf8.encode('salt'), 1)),
      '55ac046e56e3089fec1691c22544b605f94185216dde0465e68b9d57c20dacbc',
    );
    expect(
      hex(CodePin.pbkdf2(utf8.encode('Password'), utf8.encode('NaCl'), 80000)),
      '4ddcd8f60b98be21830cee5ef22701f9641a4418d04c0414aeff08876b34ab56',
    );
  });
}
