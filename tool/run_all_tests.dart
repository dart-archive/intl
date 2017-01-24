import '../test/bidi_format_test.dart' as test_1;
import '../test/bidi_utils_test.dart' as test_2;
import '../test/date_time_format_file_even_test.dart' as test_3;
import '../test/date_time_format_file_odd_test.dart' as test_4;
// import '../test/date_time_format_http_request_test.dart' as test_5;
import '../test/date_time_format_local_even_test.dart' as test_6;
import '../test/date_time_format_local_odd_test.dart' as test_7;
import '../test/date_time_format_uninitialized_test.dart' as test_8;
import '../test/date_time_loose_parsing_test.dart' as test_9;
import '../test/date_time_strict_test.dart' as test_10;
import '../test/find_default_locale_standalone_test.dart' as test_11;
// import '../test/find_default_locale_browser_test.dart' as test_12;
import '../test/fixnum_test.dart' as test_13;
import '../test/intl_test.dart' as test_14;
import '../test/number_closure_test.dart' as test_15;
import '../test/number_format_compact_test.dart' as test_16;
import '../test/number_format_test.dart' as test_17;
import '../test/plural_test.dart' as test_18;

// Run all of the tests, skipping the ones that require a browser.
main() {
  test_1.main();
  test_2.main();
  test_3.main();
  test_4.main();
  // test_5.main();
  test_6.main();
  test_7.main();
  test_8.main();
  test_9.main();
  test_10.main();
  test_11.main();
  // test_12.main();
  test_13.main();
  test_14.main();
  test_15.main();
  test_16.main();
  test_17.main();
  test_18.main();
}
