import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/domain/essais_pin.dart';

void main() {
  test('5 essais libres, puis 30 s qui doublent, 15 min au plus', () {
    expect(EssaisPin.attenteApres(0), Duration.zero);
    expect(EssaisPin.attenteApres(4), Duration.zero);
    expect(EssaisPin.attenteApres(5), const Duration(seconds: 30));
    expect(EssaisPin.attenteApres(6), const Duration(minutes: 1));
    expect(EssaisPin.attenteApres(7), const Duration(minutes: 2));
    expect(EssaisPin.attenteApres(20), const Duration(minutes: 15));
  });

  test('essais restants', () {
    expect(EssaisPin.restants(0), 5);
    expect(EssaisPin.restants(3), 2);
    expect(EssaisPin.restants(9), 0);
  });
}
