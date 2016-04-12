// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of intl;

/// Represents a compact format for a particular base
///
/// For example, 10k can be used to represent 10,000.  Corresponds to one of the
/// patterns in COMPACT_DECIMAL_SHORT_FORMAT. So, for example, in en_US we have
/// the pattern
///
///       4: '0K'
/// which matches
///
///      new _CompactStyle(pattern: '0K', requiredDigits: 4, divisor: 1000,
///      expectedDigits: 1, prefix: '', suffix: 'K');
///
/// where expectedDigits is the number of zeros.
class _CompactStyle {
  _CompactStyle(
      {this.pattern,
      this.requiredDigits: 0,
      this.divisor: 1,
      this.expectedDigits: 1,
      this.prefix: '',
      this.suffix: ''});

  /// The pattern on which this is based.
  ///
  /// We don't actually need this, but it makes debugging easier.
  String pattern;

  /// The length for which the format applies.
  ///
  /// So if this is 3, we expect it to apply to numbers from 100 up. Typically
  /// it would be from 100 to 1000, but that depends if there's a style for 4 or
  /// not. This is the CLDR index of the pattern, and usually determines the
  /// divisor, but if the pattern is just a 0 with no prefix or suffix then we
  /// don't divide at all.
  int requiredDigits;

  /// What should we divide the number by in order to print. Normally is either
  /// 10^requiredDigits or 1 if we shouldn't divide at all.
  int divisor;

  /// How many integer digits do we expect to print - the number of zeros in the
  /// CLDR pattern.
  int expectedDigits;

  /// Text we put in front of the number part.
  String prefix;

  /// Text we put after the number part.
  String suffix;

  /// How many total digits do we expect in the number.
  ///
  /// If the pattern is
  ///
  ///       4: "00K",
  ///
  /// then this is 5, meaning we expect this to be a 5-digit (or more)
  /// number. We will scale by 1000 and expect 2 integer digits remaining, so we
  /// get something like '12K'. This is used to find the closest pattern for a
  /// number.
  get totalDigits => requiredDigits + expectedDigits - 1;
}

class _CompactNumberFormat extends NumberFormat {
  Map<int, String>
      _patterns; // Should be either the COMPACT_DECIMAL_SHORT_PATTERN
  // or COMPACT_DECIMAL_LONG_PATTERN.

  List<_CompactStyle> _styles = [];

  _CompactNumberFormat({String locale, bool longFormat})
      : super._forPattern(locale, (x) => x.DECIMAL_PATTERN) {
    significantDigits = 3;
    turnOffGrouping();
    _patterns = longFormat
        ? compactSymbols.COMPACT_DECIMAL_LONG_PATTERN ??
            compactSymbols.COMPACT_DECIMAL_SHORT_PATTERN
        : compactSymbols.COMPACT_DECIMAL_SHORT_PATTERN;
    var regex = new RegExp('([^0]*)(0+)(.*)');
    _patterns.forEach((int impliedDigits, String pattern) {
      var match = regex.firstMatch(pattern);
      var integerDigits = match.group(2).length;
      var prefix = match.group(1);
      var suffix = match.group(3);
      // If the pattern is just zeros, with no suffix, then we shouldn't divide
      // by the number of digits. e.g. for 'af', the pattern for 3 is '0', but
      // it doesn't mean that 4321 should print as 4. But if the pattern was
      // '0K', then it should print as '4K'. So we have to check if the pattern
      // has a suffix. This seems extremely hacky, but I don't know how else to
      // encode that. Check what other things are doing.
      var divisor = 1;
      if (pattern.replaceAll('0', '').isNotEmpty) {
        divisor = pow(10, impliedDigits - integerDigits + 1);
      }
      var style = new _CompactStyle(
          pattern: pattern,
          requiredDigits: impliedDigits,
          expectedDigits: integerDigits,
          prefix: prefix,
          suffix: suffix,
          divisor: divisor);
      _styles.add(style);
    });
    // Reverse the styles so that we look through them from largest to smallest.
    _styles = _styles.reversed.toList();
    // Add a fallback style that just prints the number.
    _styles.add(new _CompactStyle());
  }

  String format(number) {
    var style = _styleFor(number);
    var divisor = style.divisor;
    var numberToFormat = _divide(number, divisor);
    var formatted = super.format(numberToFormat);
    return "${style.prefix}$formatted${style.suffix}";
  }

  /// Divide numbers that may not have a division operator (e.g. Int64).
  ///
  /// Only used for powers of 10, so we require an integer denominator.
  num _divide(numerator, int denominator) {
    if (numerator is num) {
      return numerator / denominator;
    }
    // If it doesn't fit in a JS int after division, we're not going to be able
    // to meaningfully print a compact representation for it.
    var divided = numerator ~/ denominator;
    var integerPart = divided.toInt();
    if (divided != integerPart) {
      throw new FormatException(
          "Number too big to use with compact format", numerator);
    }
    var remainder = numerator.remainder(denominator).toInt();
    var originalFraction = numerator - (numerator ~/ 1);
    var fraction = originalFraction == 0 ? 0 : originalFraction / denominator;
    return integerPart + (remainder / denominator) + fraction;
  }

  _CompactStyle _styleFor(number) {
    // We have to round the number based on the number of significant digits so
    // that we pick the right style based on the rounded form and format 999999
    // as 1M rather than 1000K.
    var originalLength = NumberFormat.numberOfIntegerDigits(number);
    var additionalDigits = originalLength - significantDigits;
    var digitLength = originalLength;
    if (additionalDigits > 0) {
      var divisor = pow(10, additionalDigits);
      // If we have an Int64, value speed over precision and make it double.
      var rounded = (number.toDouble() / divisor).round() * divisor;
      digitLength = NumberFormat.numberOfIntegerDigits(rounded);
    }
    for (var style in _styles) {
      if (digitLength > style.totalDigits) {
        return style;
      }
    }
    throw new FormatException(
        "No compact style found for number. This should not happen", number);
  }

  num parse(String text) {
    for (var style in _styles.reversed) {
      if (text.startsWith(style.prefix) && text.endsWith(style.suffix)) {
        var numberText = text.substring(
            style.prefix.length, text.length - style.suffix.length);
        var number = _tryParsing(numberText);
        if (number != null) {
          return number * style.divisor;
        }
      }
    }
    throw new FormatException(
        "Cannot parse compact number in locale '$locale'", text);
  }

  num _tryParsing(String text) {
    try {
      return super.parse(text);
    } on FormatException {
      return null;
    }
  }

  CompactNumberSymbols get compactSymbols => compactNumberSymbols[_locale];
}
