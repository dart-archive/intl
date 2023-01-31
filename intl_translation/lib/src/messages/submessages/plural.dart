// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../message.dart';
import 'submessage.dart';

class Plural extends SubMessage {
  Plural() : super.from('', [], null);
  Plural.from(String mainArgument, List clauses, [Message? parent])
      : super.from(mainArgument, clauses, parent);

  Message? zero;
  Message? one;
  Message? two;
  Message? few;
  Message? many;
  Message? other;

  @override
  String get icuMessageName => 'plural';
  @override
  String get dartMessageName => 'Intl.plural';

  @override
  List<String> get attributeNames => ['=0', '=1', '=2', 'few', 'many', 'other'];
  @override
  List<String> get codeAttributeNames =>
      ['zero', 'one', 'two', 'few', 'many', 'other'];

  /// The node will have the attribute names as strings, so we translate
  /// between those and the fields of the class.
  @override
  void operator []=(String attributeName, dynamic rawValue) {
    var value = Message.from(rawValue, this);
    switch (attributeName) {
      case 'zero':
        // We prefer an explicit "=0" clause to a "ZERO"
        // if both are present.
        zero ??= value;
        return;
      case '=0':
        zero = value;
        return;
      case 'one':
        // We prefer an explicit "=1" clause to a "ONE"
        // if both are present.
        one ??= value;
        return;
      case '=1':
        one = value;
        return;
      case 'two':
        // We prefer an explicit "=2" clause to a "TWO"
        // if both are present.
        two ??= value;
        return;
      case '=2':
        two = value;
        return;
      case 'few':
        few = value;
        return;
      case 'many':
        many = value;
        return;
      case 'other':
        other = value;
        return;
      default:
        return;
    }
  }

  @override
  Message? operator [](String attributeName) {
    switch (attributeName) {
      case 'zero':
        return zero;
      case '=0':
        return zero;
      case 'one':
        return one;
      case '=1':
        return one;
      case 'two':
        return two;
      case '=2':
        return two;
      case 'few':
        return few;
      case 'many':
        return many;
      case 'other':
        return other;
      default:
        return other;
    }
  }
}
