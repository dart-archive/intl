// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'message.dart';

/// Represents an interpolation of a variable value in a message. We expect
/// this to be specified as an [index] into the list of variables, or else
/// as the name of a variable that exists in [arguments] and we will
/// compute the variable name or the index based on the value of the other.
class VariableSubstitution extends Message {
  VariableSubstitution(this._index, [Message? parent]) : super(parent);

  /// Create a substitution based on the name rather than the index. The name
  /// may have been used as all upper-case in the translation tool, so we
  /// save it separately and look it up case-insensitively once the parent
  /// (and its arguments) are definitely available.
  VariableSubstitution.named(String name, [Message? parent]) : super(parent) {
    _variableName = name;
    _variableNameUpper = name.toUpperCase();
  }

  /// The index in the list of parameters of the containing function.
  int? _index;
  int? get index {
    if (_index != null) return _index;
    if (arguments.isEmpty) return null;
    // We may have been given an all-uppercase version of the name, so compare
    // case-insensitive.
    _index = arguments
        .map((x) => x.toUpperCase())
        .toList()
        .indexOf(_variableNameUpper!);
    if (_index == -1) {
      throw ArgumentError(
          "Cannot find parameter named '$_variableNameUpper' in "
          "message named '$name'. Available "
          'parameters are $arguments');
    }
    return _index;
  }

  /// The variable name we get from parsing. This may be an all uppercase
  /// version of the Dart argument name.
  String? _variableNameUpper;

  /// The name of the variable in the parameter list of the containing function.
  /// Used when generating code for the interpolation.
  String? get variableName {
    return index != null ? arguments[index!] : _variableName;
  }

  String? _variableName;
  // Although we only allow simple variable references, we always enclose them
  // in curly braces so that there's no possibility of ambiguity with
  // surrounding text.
  @override
  String toCode() => '\${$variableName}';
  @override
  int? toJson() => index;
  @override
  String toString() => 'VariableSubstitution(${index ?? _variableName})';
  @override
  String expanded(
          [String Function(dynamic, dynamic) transform = nullTransform]) =>
      transform(this, index);
}
