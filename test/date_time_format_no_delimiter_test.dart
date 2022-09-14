library date_time_format_tests;

import 'package:intl/intl.dart';
import 'package:test/test.dart';

void main() {
  test('No delimiter 4 digits year', () {
    final timestamp = '20190614071930';
    final result = DateFormat('yyyyMMddHHmmss').parseNoDelimiter(timestamp);
    expect(result, DateTime(2019, 06, 14, 07, 19, 30));
  });
  test('No delimiter 3 digits year', () {
    final timestamp = '20190614071930';
    final result = DateFormat('yyyMMddHHmmss').parseNoDelimiter(timestamp);
    expect(result, DateTime(2019, 06, 14, 07, 19, 30));
  });

  test('No delimiter 2 digits year', () {
    final timestamp = '190614071930';
    final result = DateFormat('yyMMddHHmmss').parseNoDelimiter(timestamp);
    expect(result, DateTime(2019, 06, 14, 07, 19, 30));
  });
  test('No delimiter 1 digits year', () {
    final timestamp = '190614071930';
    final result = DateFormat('yMMddHHmmss').parseNoDelimiter(timestamp);
    expect(result, DateTime(19, 06, 14, 07, 19, 30));
  });

  test('No delimiter n digits year', () {
    final timestamp = '20190614071930';
    final result = DateFormat('yyyyyyMMddHHmmss').parseNoDelimiter(timestamp);
    expect(result, DateTime(2019, 06, 14, 07, 19, 30));
  });
  test('No delimiter 2 digits year with other order', () {
    final timestamp = '061407193019';
    final result = DateFormat('MMddHHmmssyy').parseNoDelimiter(timestamp);
    expect(result, DateTime(2019, 06, 14, 07, 19, 30));
  });
  test('No delimiter 1 digits year random order', () {
    final timestamp = '140619071930';
    final result = DateFormat('ddMMyHHmmss').parseNoDelimiter(timestamp);
    expect(result, DateTime(0019, 06, 14, 07, 19, 30));
  });

  test('No delimiter 4 digits year other order', () {
    final timestamp = '06140719302019';
    final result = DateFormat('MMddHHmmssyyyy').parseNoDelimiter(timestamp);
    expect(result, DateTime(2019, 06, 14, 07, 19, 30));
  });
  test('With delimiter 4 digits year other order', () {
    final timestamp = '06-14-07-19-30-2019';
    final result =
        DateFormat('MM-dd-HH-mm-ss-yyyy').parseNoDelimiter(timestamp);
    expect(result, DateTime(2019, 06, 14, 07, 19, 30));
  });
  test('With delimiter 3 digits year other order', () {
    final timestamp = '06-14-07-19-30-2019';
    final result = DateFormat('MM-dd-HH-mm-ss-yyy').parseNoDelimiter(timestamp);
    expect(result, DateTime(2019, 06, 14, 07, 19, 30));
  });
}
