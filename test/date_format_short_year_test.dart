library date_time_format_file_test_year_format;

import 'package:intl/intl.dart';
import "package:test/test.dart";

main() {
  test('Two char years', () {
    expect(DateBuilderHelper.yearFromShortFormat(0,
      dateBase: new DateTime(2016)), 2000);
    expect(DateBuilderHelper.yearFromShortFormat(16,
      dateBase: new DateTime(2016)), 2016);
    expect(DateBuilderHelper.yearFromShortFormat(24,
      dateBase: new DateTime(2016)), 2024);
    expect(DateBuilderHelper.yearFromShortFormat(99,
      dateBase: new DateTime(2016)), 1999);
    expect(DateBuilderHelper.yearFromShortFormat(0,
      yearOffsetInYears: 10, dateBase: new DateTime(1999)), 2000);
    expect(DateBuilderHelper.yearFromShortFormat(99,
      yearOffsetInYears: 10, dateBase: new DateTime(1999)), 1999);
    expect(DateBuilderHelper.yearFromShortFormat(99,
      yearOffsetInYears: 10, dateBase: new DateTime(2000)), 1999);
    expect(DateBuilderHelper.yearFromShortFormat(90,
      yearOffsetInYears: 10, dateBase: new DateTime(2000)), 1990);
    expect(DateBuilderHelper.yearFromShortFormat(0,
      yearOffsetInYears: 10, dateBase: new DateTime(1990)), 2000);
    expect(DateBuilderHelper.yearFromShortFormat(28,
      yearOffsetInYears: 10, dateBase: new DateTime(2016)), 1928);
  });
}
