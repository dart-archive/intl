// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'complex_message.dart';
import 'message.dart';
import 'message_extraction_exception.dart';

class MainMessage extends ComplexMessage {
  MainMessage({
    this.sourcePosition,
    this.endPosition,
    required this.arguments,
  })  : examples = {},
        super(null);

  /// All the pieces of the message. When we go to print, these will
  /// all be expanded appropriately. The exact form depends on what we're
  /// printing it for See [expanded], [toCode].
  List<Message> messagePieces = [];

  /// The position in the source at which this message starts.
  int? sourcePosition;

  /// The position in the source at which this message ends.
  int? endPosition;

  /// Optional documentation of the member that wraps the message definition.
  List<String> documentation = [];

  /// Verify that this looks like a correct Intl.message invocation.
  static void checkValidity(
    MethodInvocation node,
    List arguments,
    String? outerName,
    List<FormalParameter> outerArgs, {
    bool nameAndArgsGenerated = false,
    bool examplesRequired = false,
  }) {
    if (arguments.first is! StringLiteral) {
      throw MessageExtractionException(
          'Intl.message messages must be string literals');
    }

    Message.checkValidity(
      node,
      arguments,
      outerName,
      outerArgs,
      nameAndArgsGenerated: nameAndArgsGenerated,
      examplesRequired: examplesRequired,
    );
  }

  void addPieces(List<Object> messages) {
    for (var each in messages) {
      messagePieces.add(Message.from(each, this));
    }
  }

  void validateDescription() {
    if (description == null || description == '') {
      throw MessageExtractionException('Missing description for message $this');
    }
  }

  /// The description provided in the Intl.message call.
  String? description;

  /// The examples from the Intl.message call
  @override
  Map<String, dynamic> examples;

  /// A field to disambiguate two messages that might have exactly the
  /// same text. The two messages will also need different names, but
  /// this can be used by machine translation tools to distinguish them.
  String? meaning;

  /// The name, which may come from the function name, from the arguments
  /// to Intl.message, or we may just re-use the message.
  String? _name;

  /// A placeholder for any other identifier that the translation format
  /// may want to use.
  String? id;

  /// The arguments list from the Intl.message call.
  @override
  List<String> arguments;

  /// The locale argument from the Intl.message call
  String? locale;

  /// Whether extraction skip outputting this message.
  ///
  /// For example, this could be used to define messages whose purpose is known,
  /// but whose text isn't final yet and shouldn't be sent for translation.
  bool skip = false;

  /// When generating code, we store translations for each locale
  /// associated with the original message.
  Map<String, String> translations = {};
  Map<String, Object?> jsonTranslations = {};

  /// If the message was not given a name, we use the entire message string as
  /// the name.
  @override
  String get name => _name ?? '';
  set name(String? newName) {
    _name = newName;
  }

  /// Does this message have an assigned name.
  bool get hasNoName => _name == null;

  /// Return the full message, with any interpolation expressions transformed
  /// by [f] and all the results concatenated. The chunk argument to [f] may be
  /// either a String, an int or an object representing a more complex
  /// message entity.
  /// See [messagePieces].
  @override
  String expanded(
          [String Function(Message, dynamic) transform = nullTransform]) =>
      messagePieces.map((chunk) => transform(this, chunk)).join('');

  /// Record the translation for this message in the given locale, after
  /// suitably escaping it.
  void addTranslation(String locale, Message translated) {
    translated.parent = this;
    translations[locale] = translated.toCode();
    jsonTranslations[locale] = translated.toJson();
  }

  @override
  String toCode() =>
      throw UnsupportedError('MainMessage.toCode requires a locale');

  @override
  String toJson() =>
      throw UnsupportedError('MainMessage.toJson requires a locale');

  /// Generate code for this message, expecting it to be part of a map
  /// keyed by name with values the function that calls Intl.message.
  String toCodeForLocale(String locale, String name) {
    var out = StringBuffer()
      ..write('static $name(')
      ..write(arguments.join(', '))
      ..write(') => "')
      ..write(translations[locale])
      ..write('";');
    return out.toString();
  }

  /// Return a JSON string representation of this message.
  dynamic toJsonForLocale(String locale) {
    return jsonTranslations[locale];
  }

  String turnInterpolationBackIntoStringForm(Message message, dynamic chunk) {
    if (chunk is String) {
      return Message.escapeString(chunk);
    } else if (chunk is int) {
      return r'${message.arguments[chunk]}';
    } else if (chunk is Message) {
      return chunk.toCode();
    } else {
      throw ArgumentError.value(chunk, 'Unexpected value in Intl.message');
    }
  }

  /// Create a string that will recreate this message, optionally
  /// including the compile-time only information desc and examples.
  String toOriginalCode(
      {bool includeDesc = true, bool includeExamples = true}) {
    var out = StringBuffer()..write("Intl.message('");
    out.write(expanded(turnInterpolationBackIntoStringForm));
    out.write("', ");
    out.write("name: '$name', ");
    out.write(locale == null ? '' : "locale: '$locale', ");
    if (includeDesc) {
      out.write(description == null
          ? ''
          : "desc: '${Message.escapeString(description!)}', ");
    }
    if (includeExamples) {
      // json is already mostly-escaped, but we need to handle interpolations.
      var json = jsonEncoder.encode(examples).replaceAll(r'$', r'\$');
      out.write(examples.isEmpty ? '' : 'examples: const $json, ');
    }
    out.write(meaning == null
        ? ''
        : "meaning: '${Message.escapeString(meaning!)}', ");
    out.write("args: [${arguments.join(', ')}]");
    out.write(')');
    return out.toString();
  }

  /// The AST node will have the attribute names as strings, so we translate
  /// between those and the fields of the class.
  @override
  void operator []=(String attributeName, dynamic value) {
    switch (attributeName) {
      case 'desc':
        description = value;
        return;
      case 'examples':
        examples = value as Map<String, dynamic>;
        return;
      case 'name':
        name = value;
        return;
      // We use the actual args from the parser rather than what's given in the
      // arguments to Intl.message.
      case 'args':
        return;
      case 'meaning':
        meaning = value;
        return;
      case 'locale':
        locale = value;
        return;
      case 'skip':
        skip = value as bool;
        return;
      default:
        return;
    }
  }

  /// The AST node will have the attribute names as strings, so we translate
  /// between those and the fields of the class.
  @override
  dynamic operator [](String attributeName) {
    switch (attributeName) {
      case 'desc':
        return description;
      case 'examples':
        return examples;
      case 'name':
        return name;
      // We use the actual args from the parser rather than what's given in the
      // arguments to Intl.message.
      case 'args':
        return [];
      case 'meaning':
        return meaning;
      case 'skip':
        return skip;
      default:
        return null;
    }
  }

  // This is the top-level construct, so there's no meaningful ICU name.
  @override
  String get icuMessageName => '';

  @override
  String get dartMessageName => 'message';

  /// The parameters that the Intl.message call may provide.
  @override
  List<String> get attributeNames =>
      const ['name', 'desc', 'examples', 'args', 'meaning', 'skip'];

  @override
  String toString() =>
      'Intl.message(${expanded()}, $name, $description, $examples, $arguments)';
}
