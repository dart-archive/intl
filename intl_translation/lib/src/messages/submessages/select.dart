// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import '../message.dart';
import '../message_extraction_exception.dart';
import 'submessage.dart';

/// Represents a message send of [Intl.select] inside a message that is to
/// be internationalized. This corresponds to an ICU message syntax "select"
/// with arbitrary options.
class Select extends SubMessage {
  Select() : super.from('', [], null);

  /// Create a new [Select] providing [mainArgument] and the list of possible
  /// clauses. Each clause is expected to be a list whose first element is a
  /// variable name and whose second element is either a String or
  /// a list of strings and [Message]s or [VariableSubstitution]s.
  Select.from(String mainArgument, List clauses, [Message? parent])
      : super.from(mainArgument, clauses, parent);

  Map<String, Message> cases = <String, Message>{};

  @override
  String get icuMessageName => 'select';
  @override
  String get dartMessageName => 'Intl.select';

  @override
  List<String> get attributeNames => cases.keys.toList();
  @override
  List<String> get codeAttributeNames => attributeNames;

  // Check for valid select keys.
  // See http://site.icu-project.org/design/formatting/select
  static const selectPattern = '[a-zA-Z][a-zA-Z0-9_-]*';
  static final validSelectKey = RegExp(selectPattern);

  @override
  void operator []=(String attributeName, dynamic rawValue) {
    var value = Message.from(rawValue, this);
    if (validSelectKey.stringMatch(attributeName) == attributeName) {
      cases[attributeName] = value;
    } else {
      throw MessageExtractionException(
          "Invalid select keyword: '$attributeName', must "
          "match '$selectPattern'");
    }
  }

  @override
  Message? operator [](String attributeName) {
    var exact = cases[attributeName];
    return exact ?? cases['other'];
  }

  /// Return the arguments that we care about for the select. In this
  /// case they will all be passed in as a Map rather than as the named
  /// arguments used in Plural/Gender.
  static Map<String, Expression> argumentsOfInterestFor(MethodInvocation node) {
    var casesArgument = node.argumentList.arguments[1] as SetOrMapLiteral;
    // ignore: prefer_for_elements_to_map_fromiterable
    return Map.fromIterable(
      casesArgument.elements,
      key: (element) => _keyForm(element.key),
      value: (element) => element.value,
    );
  }

  // The key might already be a simple string, or it might be
  // something else, in which case we convert it to a string
  // and take the portion after the period, if present.
  // This is to handle enums as select keys.
  static String _keyForm(key) {
    return (key is SimpleStringLiteral) ? key.value : '$key'.split('.').last;
  }

  @override
  void validate() {
    if (this['other'] == null) {
      throw MessageExtractionException(
          'Missing keyword other for Intl.select $this');
    }
  }

  /// Write out the generated representation of this message. This differs
  /// from Plural/Gender in that it prints a literal map rather than
  /// named arguments.
  @override
  String toCode() {
    var out = StringBuffer();
    out.write('\${');
    out.write(dartMessageName);
    out.write('(');
    out.write(mainArgument);
    var args = codeAttributeNames;
    out.write(', {');
    args.fold<StringBuffer>(out,
        (buffer, arg) => buffer..write("'$arg': '${this[arg]!.toCode()}', "));
    out.write('})}');
    return out.toString();
  }

  /// We represent this in JSON as a List with the name of the message
  /// (e.g. Intl.select), the index in the arguments list of the main argument,
  /// and then a Map from the cases to the List of strings or sub-messages.
  @override
  List toJson() {
    var json = [];
    json.add(dartMessageName);
    json.add(arguments.indexOf(mainArgument));
    var attributes = {};
    for (var arg in codeAttributeNames) {
      attributes[arg] = this[arg]!.toJson();
    }
    json.add(attributes);
    return json;
  }
}
