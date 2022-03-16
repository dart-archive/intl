library date_time_format_tests;

import 'package:intl/intl.dart';
import 'package:test/test.dart';


void main() {
   test('No delimiter 4 digits year', () {
    final timestamp = "20190614071930";
    final result = DateFormat('yyyyMMddHHmmss').parseNoDelimiter(timestamp);
    expect(result, DateTime(2019, 06, 14, 07, 19, 30));
  });
  test('No delimiter 2 digits year', () {
    final timestamp = "190614071930";
    final result = DateFormat('yyMMddHHmmss').parseNoDelimiter(timestamp);
    expect(result, DateTime(2019, 06, 14, 07, 19, 30));
  });
  test('No delimiter 1 digits year', () {
    final timestamp = "190614071930";
    final result = DateFormat('yMMddHHmmss').parseNoDelimiter(timestamp);
    expect(result, DateTime(0019, 06, 14, 07, 19, 30));
  });
  
}