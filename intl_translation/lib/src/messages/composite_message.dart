// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'message.dart';

/// This represents a message chunk that is a list of multiple sub-pieces,
/// each of which is in turn a [Message].
class CompositeMessage extends Message {
  List<Message> pieces;

  CompositeMessage.withParent(parent)
      : pieces = const [],
        super(parent);
  CompositeMessage(this.pieces, [super.parent]) {
    for (var x in pieces) {
      x.parent = this;
    }
  }
  @override
  String toCode() => pieces.map((each) => each.toCode()).join('');
  @override
  List<Object?> toJson() => pieces.map((each) => each.toJson()).toList();
  @override
  String toString() => 'CompositeMessage($pieces)';
  @override
  String expanded(
          [String Function(dynamic, dynamic) transform = nullTransform]) =>
      pieces.map((chunk) => transform(this, chunk)).join('');
}
