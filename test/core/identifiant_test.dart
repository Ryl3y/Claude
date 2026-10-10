import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/core/identifiant.dart';

void main() {
  test('UUID v4 unique', () {
    final a = Identifiant.nouveau();
    final b = Identifiant.nouveau();
    expect(a, isNot(b));
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(a),
      isTrue,
    );
  });
}
