/// Tests for ECMAScript compact format numbers (e.g. 1.2M instead of 1200000).
///
/// These tests check that the test cases match what ECMAScript produces. They
/// are not testing the package:intl implementation, they only help verify
/// consistent behaviour across platforms.

/// We use @Tags rather than @TestOn to be able to specify something that can be
/// ignored when using a build system that can't read dart_test.yaml. This
/// depends on https://github.com/tc39/proposal-unified-intl-numberformat.
@Tags(const ['unifiedNumberFormat'])

import 'package:js/js_util.dart' as js;
import 'package:test/test.dart';

import 'compact_number_test_data.dart' as testdata35;
import 'more_compact_number_test_data.dart' as more_testdata;

main() {
  testdata35.compactNumberTestData.forEach(validate);
  more_testdata.cldr35CompactNumTests.forEach(validateMore);
}

var ecmaProblemLocalesShort = [
  // Not supported in Chrome:
  'af', 'az', 'be', 'br', 'bs', 'eu', 'ga', 'gl', 'gsw', 'haw', 'hy', 'is',
  'ka', 'kk', 'km', 'ky', 'ln', 'lo', 'mk', 'mn', 'mt', 'my', 'ne', 'no',
  'no-NO', 'or', 'pa', 'si', 'sq', 'ur', 'uz', 'ps',
];

var ecmaProblemLocalesLong = ecmaProblemLocalesShort +
    [
      // Short happens to match 'en', but actually not in Chrome:
      'chr', 'cy', 'tl', 'zu'
    ];

String fixLocale(String locale) {
  return locale.replaceAll('_', '-');
}

void validate(String locale, List<List<String>> expected) {
  validateShort(fixLocale(locale), expected);
  validateLong(fixLocale(locale), expected);
}

void validateShort(String locale, List<List<String>> expected) {
  if (ecmaProblemLocalesShort.contains(locale)) {
    print("Skipping problem locale '$locale' for SHORT compact number tests");
    return;
  }
  var options = js.newObject();
  js.setProperty(options, 'notation', 'compact');

  test('Validate $locale SHORT', () {
    for (var data in expected) {
      var number = num.parse(data.first);
      expect(
          js.callMethod(number, 'toLocaleString', [locale, options]), data[1]);
    }
  });
}

void validateLong(String locale, List<List<String>> expected) {
  if (ecmaProblemLocalesLong.contains(locale)) {
    print("Skipping problem locale '$locale' for LONG compact number tests");
    return;
  }
  var options = js.newObject();
  js.setProperty(options, 'notation', 'compact');
  js.setProperty(options, 'compactDisplay', 'long');

  test('Validate $locale LONG', () {
    for (var data in expected) {
      var number = num.parse(data.first);
      expect(
          js.callMethod(number, 'toLocaleString', [locale, options]), data[2]);
    }
  });
}

void validateMore(more_testdata.CompactRoundingTestCase t) {
  var options = js.newObject();
  js.setProperty(options, 'notation', 'compact');
  if (t.maximumIntegerDigits != null)
    js.setProperty(options, 'maximumIntegerDigits', t.maximumIntegerDigits);
  if (t.minimumIntegerDigits != null)
    js.setProperty(options, 'minimumIntegerDigits', t.minimumIntegerDigits);
  if (t.maximumFractionDigits != null)
    js.setProperty(options, 'maximumFractionDigits', t.maximumFractionDigits);
  if (t.minimumFractionDigits != null)
    js.setProperty(options, 'minimumFractionDigits', t.minimumFractionDigits);
  if (t.minimumExponentDigits != null)
    js.setProperty(options, 'minimumExponentDigits', t.minimumExponentDigits);
  if (t.significantDigits != null) {
    js.setProperty(options, 'minimumSignificantDigits', t.significantDigits);
    js.setProperty(options, 'maximumSignificantDigits', t.significantDigits);
  }

  test(t.toString(), () {
    expect(js.callMethod(t.number, 'toLocaleString', ['en-US', options]),
        t.expected);
  });
}
