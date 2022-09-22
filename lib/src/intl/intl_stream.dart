// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'constants.dart' as constants;

/// An indexed position in a String which can read by specified character
/// counts, or read digits up to a delimeter.
// TODO(nbosch): This is too similar to StringIterator for them to both exist.
class IntlStream {
  final String contents;
  int _index = 0;
  int get index => _index;

  IntlStream(this.contents);

  bool atEnd() => index >= contents.length;

  String next() => contents[_index++];

  /// Return the next [howMany] characters, or as many as there are remaining,
  /// and advance the index.
  String read([int howMany = 1]) {
    var result = peek(howMany);
    _index += howMany;
    return result;
  }

  /// Returns whether the input starts with [pattern] from the current index.
  bool startsWith(String pattern) => contents.startsWith(pattern, index);

  /// Return the next [howMany] characters, or as many as there are remaining,
  /// without advancing the index.
  String peek([int howMany = 1]) =>
      contents.substring(index, min(index + howMany, contents.length));

  /// Return the remaining contents of the String, without advancing the index.
  String rest() => peek(contents.length - index);

  /// Read as much content as [digitMatcher] matches from the current position,
  /// and parse the result as an integer, advancing the index.
  ///
  /// The regular expression [digitMatcher] is used to find the substring which
  /// matches an integer.
  /// The codeUnit of the local zero [zeroDigit] is used to anchor the parsing
  /// into digits.
  int? nextInteger(RegExp digitMatcher, int zeroDigit) {
    var string = digitMatcher.stringMatch(rest());
    if (string == null || string.isEmpty) return null;
    read(string.length);
    if (zeroDigit != constants.asciiZeroCodeUnit) {
      // Trying to optimize this, as it might get called a lot.
      var oldDigits = string.codeUnits;
      var newDigits = List<int>.filled(string.length, 0);
      for (var i = 0; i < string.length; i++) {
        newDigits[i] = oldDigits[i] - zeroDigit + constants.asciiZeroCodeUnit;
      }
      string = String.fromCharCodes(newDigits);
    }
    return int.parse(string);
  }
}
