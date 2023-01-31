// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import '../complex_message.dart';
import '../composite_message.dart';
import '../literal_string_message.dart';
import '../message.dart';
import '../pair_message.dart';

/// An abstract class to represent sub-sections of a message, primarily
/// plurals and genders.
abstract class SubMessage extends ComplexMessage {
  /// Creates the sub-message, given a list of [clauses] in the sort of form
  /// that we're likely to get them from parsing a translation file format,
  /// as a list of [key, value] where value may in turn be a list.
  SubMessage.from(this.mainArgument, List clauses, super.parent) {
    for (var clause in clauses) {
      String key;
      Object? value;
      if (clause is List && clause[0] is String && clause.length == 2) {
        //If trying to parse a string
        key = clause[0];
        value = (clause[1] is List) ? clause[1] : [(clause[1])];
      } else if (clause is PairMessage<LiteralString, Message>) {
        //If trying to parse a message
        key = clause.first.string;
        var second = clause.second;
        value = second is CompositeMessage ? second.pieces : [second];
      } else {
        throw Exception(
            'The clauses argument supplied must be a list of pairs, i.e. list of lists of length 2 or PairMessages.');
      }
      this[key] = value;
    }
  }

  @override
  String toString() => expanded();

  /// The name of the main argument, which is expected to have the value which
  /// is one of [attributeNames] and is used to decide which clause to use.
  String mainArgument;

  /// Return the arguments that affect this SubMessage as a map of
  /// argument names and values.
  static Map<String, Expression> argumentsOfInterestFor(MethodInvocation node) {
    return {
      for (var node in node.argumentList.arguments.whereType<NamedExpression>())
        node.name.label.token.value() as String: node.expression,
    };
  }

  /// Return the list of attribute names to use when generating code. This
  ///  may be different from [attributeNames] if there are multiple aliases
  ///  that map to the same clause.
  List<String> get codeAttributeNames;

  @override
  String expanded(
      [String Function(dynamic, dynamic) transform = nullTransform]) {
    String fullMessageForClause(String key) =>
        '$key{${transform(parent, this[key])}}';
    var clauses = attributeNames
        .where((key) => this[key] != null)
        .map(fullMessageForClause)
        .toList();
    return "{$mainArgument,$icuMessageName, ${clauses.join("")}}";
  }

  @override
  String toCode() {
    var out = StringBuffer();
    out.write('\${');
    out.write(dartMessageName);
    out.write('(');
    out.write(mainArgument);
    var args = codeAttributeNames.where((attribute) => this[attribute] != null);
    args.fold<StringBuffer>(
        out,
        (buffer, arg) =>
            buffer..write(", $arg: '${(this[arg] as Message).toCode()}'"));
    out.write(')}');
    return out.toString();
  }

  /// We represent this in JSON as a list with [dartMessageName], the index in
  /// the arguments list at which we will find the main argument (e.g. howMany
  /// for a plural), and then the values of all the possible arguments, in the
  /// order that they appear in codeAttributeNames. Any missing arguments are
  /// saved as an explicit null.
  @override
  List toJson() {
    var json = [];
    json.add(dartMessageName);
    json.add(arguments.indexOf(mainArgument));
    for (var arg in codeAttributeNames) {
      json.add(this[arg]?.toJson());
    }
    return json;
  }
}
