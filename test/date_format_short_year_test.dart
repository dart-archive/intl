library date_time_format_file_test_year_format;

import 'package:intl/intl.dart';
import "package:test/test.dart";

main() {
  test('Two char years', () {
    var format = new DateFormat('d.m.yy');
    var cent20 = format.parse("01.01.89");
    var cent21 = format.parse("01.01.12");
    expect(cent20.year, 1989);
    expect(cent21.year, 2012);
  });
}
