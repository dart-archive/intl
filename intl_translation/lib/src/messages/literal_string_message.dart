// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'message.dart';

/// Represents a simple constant string with no dynamic elements.
class LiteralString extends Message {
  String string;
  LiteralString(this.string, [Message? parent]) : super(parent);
  @override
  String toCode() => Message.escapeString(string);
  @override
  String toJson() => string;
  @override
  String toString() => 'Literal($string)';
  @override
  String expanded(
          [String Function(dynamic, dynamic) transform = nullTransform]) =>
      transform(this, string);
}
