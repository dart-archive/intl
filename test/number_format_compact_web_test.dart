@TestOn('browser')
// Tests for compact number formatting in pure Dart and in ECMAScript.
//
// TODO(b/36488375): run all these tests against both implementations to prove
// consistency when the bug is fixed. Also fix documentation and perhaps
// merge tests: these tests currently also touch non-compact currency
// formatting.
import 'package:intl/intl.dart' as intl;
import 'package:js/js_util.dart' as js;
import 'package:test/test.dart';

import 'compact_number_test_data.dart' as testdata35;
import 'more_compact_number_test_data.dart' as more_testdata;

void main() {
  testdata35.compactNumberTestData.forEach(_validate);
  more_testdata.cldr35CompactNumTests.forEach(_validateMore);

  test('RTL currency formatting', () {
    var basic = intl.NumberFormat.currency(locale: 'he');
    expect(basic.format(1234), '\u200F1,234.00 ILS');
    basic = intl.NumberFormat.currency(locale: 'he', symbol: '₪');
    expect(basic.format(1234), '\u200F1,234.00 ₪');
    expect(_ecmaFormatNumber('he', 1234, style: 'currency', currency: 'ILS'),
        '\u200F1,234.00 ₪');

    var compact = intl.NumberFormat.compactCurrency(locale: 'he');
    // Awkward:
    expect(compact.format(1234), 'ILS \u200F1.23K');
    compact = intl.NumberFormat.compactCurrency(locale: 'he', symbol: '₪');
    // Awkward:
    expect(compact.format(1234), '₪ \u200F1.23K');
    // ECMAScript skips the RTL character for notation:'compact':
    expect(
        _ecmaFormatNumber('he', 1234,
            style: 'currency', currency: 'ILS', notation: 'compact'),
        '₪ 1.2K');
    // short/long compactDisplay doesn't change anything here:
    expect(
        _ecmaFormatNumber('he', 1234,
            style: 'currency',
            currency: 'ILS',
            notation: 'compact',
            compactDisplay: 'short'),
        '₪ 1.2K');
    expect(
        _ecmaFormatNumber('he', 1234,
            style: 'currency',
            currency: 'ILS',
            notation: 'compact',
            compactDisplay: 'long'),
        '₪ 1.2K');

    var compactSimple = intl.NumberFormat.compactSimpleCurrency(locale: 'he');
    expect(compactSimple.format(1234), '₪ \u200F1.23K');
  });
}

String _ecmaFormatNumber(String locale, num number,
    {String? style,
    String? currency,
    String? notation,
    String? compactDisplay}) {
  var options = js.newObject();
  if (notation != null) js.setProperty(options, 'notation', notation);
  if (compactDisplay != null) {
    js.setProperty(options, 'compactDisplay', compactDisplay);
  }
  if (style != null) js.setProperty(options, 'style', style);
  if (currency != null) js.setProperty(options, 'currency', currency);
  return js.callMethod(number, 'toLocaleString', [locale, options]);
}

var _unsupportedChromeLocales = {
  // Not supported in Chrome:
  'af', 'az', 'be', 'br', 'bs', 'eu', 'ga', 'gl', 'gsw', 'haw', 'hy', 'is',
  'ka', 'kk', 'km', 'ky', 'ln', 'lo', 'mk', 'mn', 'mt', 'my', 'ne', 'no',
  'no-NO', 'or', 'pa', 'si', 'sq', 'ur', 'uz', 'ps', 'chr', 'cy', 'tl', 'zu'
};

var _skipLocalesShort = [
  'am', 'bn', 'fa', // Some results change in chrome 88
  ..._unsupportedChromeLocales
];

var _skipLocalesLong = _unsupportedChromeLocales;

String _fixLocale(String locale) {
  return locale.replaceAll('_', '-');
}

void _validate(String locale, List<List<String>> expected) {
  _validateShort(_fixLocale(locale), expected);
  _validateLong(_fixLocale(locale), expected);
}

void _validateShort(String locale, List<List<String>> expected) {
  var skip = _skipLocalesShort.contains(locale)
      ? "Skipping problem locale '$locale' for SHORT compact number tests"
      : false;

  test('Validate $locale SHORT', () {
    for (var data in expected) {
      var number = num.parse(data.first);
      expect(_ecmaFormatNumber(locale, number, notation: 'compact'), data[1]);
    }
  }, skip: skip);
}

void _validateLong(String locale, List<List<String>> expected) {
  var skip = _skipLocalesLong.contains(locale)
      ? "Skipping problem locale '$locale' for LONG compact number tests"
      : false;

  test('Validate $locale LONG', () {
    for (var data in expected) {
      var number = num.parse(data.first);
      expect(
          _ecmaFormatNumber(locale, number,
              notation: 'compact', compactDisplay: 'long'),
          data[2]);
    }
  }, skip: skip);
}

void _validateMore(more_testdata.CompactRoundingTestCase t) {
  var options = js.newObject();
  js.setProperty(options, 'notation', 'compact');
  if (t.maximumIntegerDigits != null) {
    js.setProperty(options, 'maximumIntegerDigits', t.maximumIntegerDigits);
  }

  if (t.minimumIntegerDigits != null) {
    js.setProperty(options, 'minimumIntegerDigits', t.minimumIntegerDigits);
  }

  if (t.maximumFractionDigits != null) {
    js.setProperty(options, 'maximumFractionDigits', t.maximumFractionDigits);
  }

  if (t.minimumFractionDigits != null) {
    js.setProperty(options, 'minimumFractionDigits', t.minimumFractionDigits);
  }

  if (t.minimumExponentDigits != null) {
    js.setProperty(options, 'minimumExponentDigits', t.minimumExponentDigits);
  }

  if (t.significantDigits != null) {
    js.setProperty(options, 'minimumSignificantDigits', t.significantDigits);
    js.setProperty(options, 'maximumSignificantDigits', t.significantDigits);
  }

  test(t.toString(), () {
    expect(js.callMethod(t.number, 'toLocaleString', ['en-US', options]),
        t.expected);
  });
}
