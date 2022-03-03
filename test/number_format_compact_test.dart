/// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
/// for details. All rights reserved. Use of this source code is governed by a
/// BSD-style license that can be found in the LICENSE file.

/// Tests for compact format numbers, e.g. 1.2M rather than 1,200,000
import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart' as patterns;
import 'package:test/test.dart';

import 'compact_number_test_data.dart' as testdata;
import 'more_compact_number_test_data.dart' as more_testdata;

/// A place to put a case that's causing a problem and have it run first when
/// debugging
var interestingCases = <String, List<List<String>>>{
//  'mn' : [['4321', '4.32M', 'whatever']]
};

var compactWithExplicitSign = <String, List<List<String>>>{
  'en_US': [
    ['0', '+0', '+0'],
    ['0.012', '+0.01', '+0.01'],
    ['0.123', '+0.12', '+0.12'],
    ['1.234', '+1.23', '+1.23'],
    ['12', '+12', '+12'],
    ['12.34', '+12.3', '+12.3'],
    ['123.4', '+123', '+123'],
    ['123.41', '+123', '+123'],
    ['1234.1', '+1.23K', '+1.23 thousand'],
    ['12341', '+12.3K', '+12.3 thousand'],
    ['123412', '+123K', '+123 thousand'],
    ['1234123', '+1.23M', '+1.23 million'],
    ['12341234', '+12.3M', '+12.3 million'],
    ['123412341', '+123M', '+123 million'],
    ['1234123412', '+1.23B', '+1.23 billion'],
    ['-0.012', '-0.01', '-0.01'],
    ['-0.123', '-0.12', '-0.12'],
    ['-1.234', '-1.23', '-1.23'],
    ['-12', '-12', '-12'],
    ['-12.34', '-12.3', '-12.3'],
    ['-123.4', '-123', '-123'],
    ['-123.41', '-123', '-123'],
    ['-1234.1', '-1.23K', '-1.23 thousand'],
    ['-12341', '-12.3K', '-12.3 thousand'],
    ['-123412', '-123K', '-123 thousand'],
    ['-1234123', '-1.23M', '-1.23 million'],
    ['-12341234', '-12.3M', '-12.3 million'],
    ['-123412341', '-123M', '-123 million'],
    ['-1234123412', '-1.23B', '-1.23 billion'],
  ],
  'sw': [
    ['12', '+12', '+12'],
    ['12341', 'elfu\u00A0+12.3', 'elfu +12.3'],
    ['-12', '-12', '-12'],
    ['-12341', 'elfu\u00A0-12.3', 'elfu -12.3'],
  ],
  'he': [
    ['12', '\u200e+12', '\u200e+12'],
    ['12341', '\u200e+12.3K\u200f', '\u200e+\u200f12.3 אלף'],
    ['-12', '\u200e-12', '\u200e-12'],
    ['-12341', '\u200e-12.3K\u200f', '\u200e-\u200f12.3 אלף'],
  ],
};

var parsingTestCases = <String, List<List<String>>>{
  'en_US': [
    ['1230', '1.23 K', '1.23  thousand'], // Random spaces.
    ['1230', '1.23\u00a0K', '1.23\u00a0thousand'], // NO-BREAK SPACE.
    ['1230', '1.23\u202fK', '1.23\u202fthousand'], // NARROW NO-BREAK SPACE.
  ],
  'fi': [
    ['4320', '4,32t.', '4,32tuhatta'], // Actual format uses NO-BREAK SPACE.
    ['-4320', '-4,32t.', '-4,32tuhatta'], // Actual format uses MINUS SIGN.
    ['-4320', '\u22124,32t.', '\u22124,32tuhatta'], // Like actual format.
  ],
  'he': [
    ['-12300', '-12.3 K', '-12.3\u05D0\u05DC\u05E3'], // LTR/RTL marks dropped.
  ],
  'fa': [
    [
      '123',
      // With locale numerals.
      '\u06F1\u06F2\u06F3',
      '\u06F1\u06F2\u06F3'
    ],
    [
      '4320',
      // With locale numerals.
      '\u06F4\u066B\u06F3\u06F2 \u0647\u0632\u0627\u0631',
      '\u06F4\u066B\u06F3\u06F2 \u0647\u0632\u0627\u0631'
    ],
    ['123', '123', '123'], // With roman numerals.
    [
      '4320',
      // With roman numerals.
      '4.32 \u0647\u0632\u0627\u0631',
      '4.32 \u0647\u0632\u0627\u0631'
    ],
  ]
};

void main() {
  interestingCases.forEach(_validate);
  testdata.compactNumberTestData.forEach(_validate);
  more_testdata.oldIntlCompactNumTests.forEach(_validateFancy);
  // Once code and data is updated to CLDR35:
  // more_testdata.cldr35CompactNumTests.forEach(_validateFancy);

  compactWithExplicitSign.forEach(_validateWithExplicitSign);
  parsingTestCases.forEach(_validateParsing);

  test("Patterns are consistent across locales", () {
    var checkPatterns = (Map<int, Map<String, String>> patterns) {
      expect(patterns, isNotEmpty);
      // Check patterns are iterable in order.
      var lastExp = -1;
      for (var entries in patterns.entries) {
        var exp = entries.key;
        expect(exp, isPositive);
        expect(exp, greaterThan(lastExp));
        lastExp = exp;
        var patternMap = entries.value;
        expect(patternMap, isNotEmpty);
      }
    };

    patterns.compactNumberSymbols.forEach((locale, patterns) {
      checkPatterns(patterns.COMPACT_DECIMAL_SHORT_PATTERN);
      if (patterns.COMPACT_DECIMAL_LONG_PATTERN != null) {
        checkPatterns(patterns.COMPACT_DECIMAL_LONG_PATTERN!);
      }
      checkPatterns(patterns.COMPACT_DECIMAL_SHORT_CURRENCY_PATTERN);
    });
  });

  // ICU doesn't support compact currencies yet, so we don't have a way to
  // generate automatic data for comparison. Hard-coded a couple of cases as a
  // smoke test. JPY is a useful test because it has no decimalDigits and
  // different grouping than USD, as well as a different currency symbol and
  // suffixes.
  testCurrency('ja', 1.2345, '¥1', '¥1');
  testCurrency('ja', 1, '¥1', '¥1');
  testCurrency('ja', 12, '¥12', '¥10');
  testCurrency('ja', 123, '¥123', '¥100');
  testCurrency('ja', 1234, '¥1230', '¥1000');
  testCurrency('ja', 12345, '¥1.23\u4E07', '¥1\u4E07');
  testCurrency('ja', 123456, '¥12.3\u4E07', '¥10\u4E07');
  testCurrency('ja', 1234567, '¥123\u4e07', '¥100\u4e07');
  testCurrency('ja', 12345678, '¥1230\u4e07', '¥1000\u4e07');
  testCurrency('ja', 123456789, '¥1.23\u5104', '¥1\u5104');

  testCurrency('ja', 0.9876, '¥1', '¥1');
  testCurrency('ja', 9, '¥9', '¥9');
  testCurrency('ja', 98, '¥98', '¥100');
  testCurrency('ja', 987, '¥987', '¥1000');
  testCurrency('ja', 9876, '¥9880', '¥1\u4E07');
  testCurrency('ja', 98765, '¥9.88\u4E07', '¥10\u4E07');
  testCurrency('ja', 987656, '¥98.8\u4E07', '¥100\u4E07');
  testCurrency('ja', 9876567, '¥988\u4e07', '¥1000\u4e07');
  testCurrency('ja', 98765678, '¥9880\u4e07', '¥1\u5104');
  testCurrency('ja', 987656789, '¥9.88\u5104', '¥10\u5104');

  testCurrency('en_US', 1, r'$1.00', r'$1');
  testCurrency('en_US', 1.2345, r'$1.23', r'$1');
  testCurrency('en_US', 12, r'$12.00', r'$10');
  testCurrency('en_US', 12.3, r'$12.30', r'$10');
  testCurrency('en_US', 123, r'$123', r'$100');
  testCurrency('en_US', 999, r'$999', r'$1K');
  testCurrency('en_US', 1000, r'$1K', r'$1K');
  testCurrency('en_US', 1234, r'$1.23K', r'$1K');
  testCurrency('en_US', 12345, r'$12.3K', r'$10K');
  testCurrency('en_US', 123456, r'$123K', r'$100K');
  testCurrency('en_US', 1234567, r'$1.23M', r'$1M');

  testCurrency('en_US', -1, r'-$1.00', r'-$1');
  testCurrency('en_US', -12.3, r'-$12.30', r'-$10');
  testCurrency('en_US', -999, r'-$999', r'-$1K');
  testCurrency('en_US', -1234, r'-$1.23K', r'-$1K');

  // Check for order of currency symbol when currency is a suffix.
  testCurrency('ru', 4420, '4,42\u00A0тыс.\u00A0руб.', '4\u00A0тыс.\u00A0руб.');

  // Check for sign location when multiple patterns.
  testCurrency('sw', 12341, 'TSh\u00A0elfu12.3', 'TSh\u00A0elfu10');
  testCurrency('sw', -12341, 'TShelfu\u00A0-12.3', 'TShelfu\u00A0-10');

  // Locales which don't have a suffix for thousands.
  testCurrency('it', 442, '442\u00A0€', '400\u00A0€');
  testCurrency('it', 4420, '4420\u00A0\$', '4000\u00A0\$', currency: 'CAD');
  testCurrency('it', 4420000, '4,42\u00A0Mio\u00A0\$', '4\u00A0Mio\u00A0\$',
      currency: 'USD');

  testCurrency('he', 335, '\u200F335\u00A0₪', '\u200F300\u00A0₪',
      reason: 'TODO(b/36488375): Short format throws away significant digits '
          'without good reason.');
  testCurrency('he', -335, '\u200F-335\u00A0₪', '\u200F-300\u00A0₪');
  testCurrency('he', 12341, '₪12.3K\u200f', '₪10K\u200f');
  testCurrency('he', -12341, '\u200e-₪12.3K\u200f', '\u200e-₪10K\u200f');

  test('Explicit non-default symbol with compactCurrency', () {
    var format = NumberFormat.compactCurrency(locale: 'ja', symbol: '()');
    var result = format.format(98765);
    expect(result, '()9.88\u4e07');
  });
}

/// Tests for [NumberFormat.compactSimpleCurrency] and
/// [Numberformat.compactCurrency]. For `compactCurrency`, it also passes the
/// `symbol` parameter after which the result is expected to be the same as for
/// `compactSimpleCurrency`. The `expectedShort` string is compared to the
/// output of the formatters with significantDigits set to `1`.
void testCurrency(
    String locale, num number, String expected, String expectedShort,
    {String? currency, String? reason}) {
  test('Compact simple currency for $locale, $number', () {
    var format =
        NumberFormat.compactSimpleCurrency(locale: locale, name: currency);
    var result = format.format(number);
    expect(result, expected, reason: '$reason');
    var shortFormat =
        NumberFormat.compactSimpleCurrency(locale: locale, name: currency);
    shortFormat.significantDigits = 1;
    var shortResult = shortFormat.format(number);
    expect(shortResult, expectedShort, reason: 'shortFormat: $reason');
  });
  test('Compact currency for $locale, $number', () {
    var symbols = {
      'ja': '¥',
      'en_US': r'$',
      'ru': 'руб.',
      'it': '€',
      'he': '₪',
      'sw': 'TSh',
      'CAD': r'$',
      'USD': r'$'
    };
    var symbol = symbols[currency] ?? symbols[locale];
    var format = NumberFormat.compactCurrency(
        locale: locale, name: currency, symbol: symbol);
    var result = format.format(number);
    expect(result, expected, reason: '$reason');
    var shortFormat = NumberFormat.compactCurrency(
        locale: locale, name: currency, symbol: symbol);
    shortFormat.significantDigits = 1;
    var shortResult = shortFormat.format(number);
    expect(shortResult, expectedShort, reason: 'shortFormat: $reason');
  });
}

// TODO(alanknight): Don't just skip the whole locale if there's one problem
// case.
var _skipLocalsShort = <String>{
  'bn', // Bug in CLDR: ambiguous parsing: 10^9 ("000 কো") and 10^11 ("000কো") only differ by a nbsp.
};

/// Locales that have problems in the long format.
///
var _skipLocalesLong = <String>{
  // None ;o)
};

void _validate(String locale, List<List<String>> expected) {
  _validateShort(locale, expected);
  _validateLong(locale, expected);
}

/// Check each bit of test data against the short compact format, both
/// formatting and parsing.
void _validateShort(String locale, List<List<String>> expected) {
  var skip = _skipLocalsShort.contains(locale)
      ? "Skipping problem locale '$locale' for SHORT compact number tests"
      : false;
  var shortFormat = NumberFormat.compact(locale: locale);
  test('Validate $locale SHORT', () {
    for (var data in expected) {
      var number = num.parse(data.first);
      _validateNumber(number, shortFormat, data[1]);
      var int64Number = Int64(number as int);
      _validateNumber(int64Number, shortFormat, data[1]);
      // TODO(alanknight): Make this work for MicroMoney
    }
  }, skip: skip);
}

void _validateLong(String locale, List<List<String>> expected) {
  var skip = _skipLocalesLong.contains(locale)
      ? "Skipping problem locale '$locale' for LONG compact number tests"
      : false;
  var longFormat = NumberFormat.compactLong(locale: locale);
  test('Validate $locale LONG', () {
    for (var data in expected) {
      var number = num.parse(data.first);
      _validateNumber(number, longFormat, data[2]);
    }
  }, skip: skip);
}

void _validateNumber(number, NumberFormat format, String expected) {
  var formatted = format.format(number);
  var ok = _closeEnough(formatted, expected);
  if (!ok) {
    expect(
        '$formatted ${formatted.codeUnits}', '$expected ${expected.codeUnits}',
        reason: 'for number: $number');
  }
  var parsed = format.parse(formatted);
  var rounded = _roundForPrinting(number, format);
  expect(((parsed - rounded) / rounded).abs() < 0.001, isTrue,
      reason: 'for number: $formatted (parsed: $parsed, rounded: $rounded)');

  var originalParsed = format.parse(number.toString());
  expect(originalParsed.toDouble(), number.toDouble(),
      reason: 'for number: $number');
}

/// Duplicate a bit of the logic in formatting, where if we have a
/// number that will round to print differently depending on the number
/// of significant digits, we need to check that as well, e.g.
/// 999999 may print as 1M.
num _roundForPrinting(number, NumberFormat format) {
  var originalLength = NumberFormat.numberOfIntegerDigits(number);
  var additionalDigits = originalLength - format.significantDigits!;
  if (additionalDigits > 0) {
    var divisor = pow(10, additionalDigits);
    // If we have an Int64, value speed over precision and make it double.
    var rounded = (number.toDouble() / divisor).round() * divisor;
    return rounded;
  }
  return number.toDouble();
}

final _nbsp = 0xa0;
final _nbspString = String.fromCharCode(_nbsp);

/// Return true if the strings are close enough to what we
/// expected to consider a pass.
///
/// In particular, there seem to be minor differences between what PyICU is
/// currently producing and the CLDR data. So if the strings differ only in the
/// presence or absence of a period at the end or of a space between the number
/// and the suffix, consider it close enough and return true.
bool _closeEnough(String result, String reference) {
  var expected = reference.replaceAll(' ', _nbspString);
  if (result == expected) {
    return true;
  }
  if ('$result.' == expected) {
    return true;
  }
  if (result == '$expected.') {
    return true;
  }
  if (_oneSpaceOnlyDifference(result, expected)) {
    return true;
  }
  return false;
}

/// Do the two strings differ only by a single space being
/// omitted in one of them.
///
/// We assume non-breaking spaces because we
/// know that's what the Intl data uses. We already know the strings aren't
/// equal because that's checked first in the only caller.
bool _oneSpaceOnlyDifference(String result, String expected) {
  var resultWithoutSpaces =
      String.fromCharCodes(result.codeUnits.where((x) => x != _nbsp));
  var expectedWithoutSpaces =
      String.fromCharCodes(expected.codeUnits.where((x) => x != _nbsp));
  var resultDifference = result.length - resultWithoutSpaces.length;
  var expectedDifference = expected.length - expectedWithoutSpaces.length;
  return resultWithoutSpaces == expectedWithoutSpaces &&
      resultDifference <= 1 &&
      expectedDifference <= 1;
}

void _validateFancy(more_testdata.CompactRoundingTestCase t) {
  var shortFormat = NumberFormat.compact(locale: 'en');
  if (t.maximumIntegerDigits != null) {
    shortFormat.maximumIntegerDigits = t.maximumIntegerDigits!;
  }

  if (t.minimumIntegerDigits != null) {
    shortFormat.minimumIntegerDigits = t.minimumIntegerDigits!;
  }

  if (t.maximumFractionDigits != null) {
    shortFormat.maximumFractionDigits = t.maximumFractionDigits!;
  }

  if (t.minimumFractionDigits != null) {
    shortFormat.minimumFractionDigits = t.minimumFractionDigits!;
  }

  if (t.minimumExponentDigits != null) {
    shortFormat.minimumExponentDigits = t.minimumExponentDigits!;
  }

  if (t.significantDigits != null) {
    shortFormat.significantDigits = t.significantDigits;
  }

  test(t.toString(), () {
    expect(shortFormat.format(t.number), t.expected);
  });
}

void _validateWithExplicitSign(String locale, List<List<String>> expected) {
  for (var data in expected) {
    final input = num.parse(data[0]);
    test('Validate compact with $locale and explicit sign for $input', () {
      final numberFormat =
          NumberFormat.compact(locale: locale, explicitSign: true);
      expect(numberFormat.format(input), data[1]);
    });
    test('Validate compactLong with $locale and explicit sign for $input', () {
      final numberFormat =
          NumberFormat.compactLong(locale: locale, explicitSign: true);
      expect(numberFormat.format(input), data[2]);
    });
  }
}

void _validateParsing(String locale, List<List<String>> expected) {
  for (var data in expected) {
    final expected = num.parse(data[0]);
    final inputShort = data[1];
    test('Validate compact parsing with $locale for $inputShort', () {
      final numberFormat = NumberFormat.compact(locale: locale);
      expect(numberFormat.parse(inputShort), expected);
    });
    final inputLong = data[2];
    test('Validate compactLong parsing with $locale for $inputLong', () {
      final numberFormat = NumberFormat.compactLong(locale: locale);
      expect(numberFormat.parse(inputLong), expected);
    });
  }
}
