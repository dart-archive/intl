import 'package:intl/intl.dart';
import 'package:test/test.dart';

void main() {
  test('numberOfIntegerDigits calculation', () {
    int n = 1;
    for (var i = 1; i < 20; i++) {
      expect(i, NumberFormat.numberOfIntegerDigits(n));
      n *= 10;
    }
  });
}
