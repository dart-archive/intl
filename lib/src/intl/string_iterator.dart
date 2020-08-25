// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// @dart=2.9

// TODO(nweiz): remove this when issue 3780 is fixed.
import 'dart:collection';

/// Provides an Iterable that wraps [_iterator] so it can be used in a `for`
/// loop.
class StringIterable extends IterableBase<String> {
  final Iterator<String> iterator;

  StringIterable(String s) : iterator = StringIterator(s);
}

/// Provides an iterator over a string as a list of substrings, and also
/// gives us a lookahead of one via the [peek] method.
class StringIterator implements Iterator<String> {
  final String input;
  int nextIndex = 0;
  String _current;

  StringIterator(input) : input = _validate(input);

  String get current => _current;

  bool moveNext() {
    if (nextIndex >= input.length) {
      _current = null;
      return false;
    }
    _current = input[nextIndex++];
    return true;
  }

  String get peek => nextIndex >= input.length ? null : input[nextIndex];

  Iterator<String> get iterator => this;

  static String _validate(input) {
    if (input is! String) throw ArgumentError(input);
    return input;
  }
}
