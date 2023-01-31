// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../message.dart';
import 'submessage.dart';

/// Represents a message send of [Intl.gender] inside a message that is to
/// be internationalized. This corresponds to an ICU message syntax "select"
/// with "male", "female", and "other" as the possible options.
class Gender extends SubMessage {
  Gender() : super.from('', [], null);

  /// Create a new Gender providing [mainArgument] and the list of possible
  /// clauses. Each clause is expected to be a list whose first element is a
  /// variable name and whose second element is either a [String] or
  /// a list of strings and [Message] or [VariableSubstitution].
  Gender.from(String mainArgument, List clauses, [Message? parent])
      : super.from(mainArgument, clauses, parent);

  Message? female;
  Message? male;
  Message? other;

  @override
  String get icuMessageName => 'select';
  @override
  String get dartMessageName => 'Intl.gender';

  @override
  List<String> get attributeNames => ['female', 'male', 'other'];
  @override
  List<String> get codeAttributeNames => attributeNames;

  /// The node will have the attribute names as strings, so we translate
  /// between those and the fields of the class.
  @override
  void operator []=(String attributeName, dynamic rawValue) {
    var value = Message.from(rawValue, this);
    switch (attributeName) {
      case 'female':
        female = value;
        return;
      case 'male':
        male = value;
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
      case 'female':
        return female;
      case 'male':
        return male;
      case 'other':
        return other;
      default:
        return other;
    }
  }
}
