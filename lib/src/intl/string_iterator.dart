// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'constants.dart' as constants;

/// An indexed position in a String which can read by specified character
/// counts, or read digits up to a delimiter.
class StringIterator {
  final String contents;
  int _index = 0;
  int get index => _index;

  StringIterator(this.contents);

  bool atEnd() => index >= contents.length;

  String next() => contents[_index++];

  /// Return the next [howMany] characters, or as many as there are remaining,
  /// and advance the index.
  String pop([int howMany = 1]) {
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
  String peekAll() => peek(contents.length - index);

  /// Read as much content as [digitMatcher] matches from the current position,
  /// and parse the result as an integer, advancing the index.
  ///
  /// The regular expression [digitMatcher] is used to find the substring which
  /// matches an integer.
  /// The codeUnit of the local zero [zeroDigit] is used to anchor the parsing
  /// into digits.
  int? nextInteger(RegExp digitMatcher, int zeroDigit) {
    var string = digitMatcher.stringMatch(peekAll());
    if (string == null || string.isEmpty) return null;
    pop(string.length);
    if (zeroDigit != constants.asciiZeroCodeUnit) {
      // Trying to optimize this, as it might get called a lot.
      var codeUnits = string.codeUnits;
      string = String.fromCharCodes(List.generate(
        codeUnits.length,
        (index) => codeUnits[index] - zeroDigit + constants.asciiZeroCodeUnit,
        growable: false,
      ));
    }
    return int.parse(string);
  }
}
