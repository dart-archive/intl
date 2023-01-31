// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is for use in extracting messages from a Dart program
/// using the Intl.message() mechanism and writing them to a file for
/// translation. This provides only the stub of a mechanism, because it
/// doesn't define how the file should be written. It provides an
/// [IntlMessage] class that holds the extracted data and [parseString]
/// and [parseFile] methods which
/// can extract messages that conform to the expected pattern:
///       (parameters) => Intl.message("Message $parameters", desc: ...);
/// It uses the analyzer package to do the parsing, so may
/// break if there are changes to the API that it provides.
/// An example can be found in test/message_extraction/extract_to_json.dart
///
/// Note that this does not understand how to follow part directives, so it
/// has to explicitly be given all the files that it needs. A typical use case
/// is to run it on all .dart files in a directory.
library extract_messages;

import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'src/messages/main_message.dart';
import 'visitors/message_finding_visitor.dart';

/// A function that takes a message and does something useful with it.
typedef OnMessage = void Function(String message);

final _featureSet = FeatureSet.latestLanguageVersion();

/// A particular message extraction run.
///
///  This encapsulates all the state required for message extraction so that
///  it can be run inside a persistent process.
class MessageExtraction {
  MessageExtraction({
    this.onMessage = print,
    this.suppressWarnings = false,
    this.allowEmbeddedPluralsAndGenders = true,
    this.examplesRequired = false,
    this.descriptionRequired = false,
    this.warningsAreErrors = false,
  }) : warnings = [];

  /// If this is true, then treat all warnings as errors.
  bool warningsAreErrors;

  /// What to do when a message is encountered, defaults to [print].
  OnMessage onMessage;

  /// If this is true, print warnings for skipped messages. Otherwise, warnings
  /// are suppressed.
  bool suppressWarnings;

  /// This accumulates a list of all warnings/errors we have found. These are
  /// saved as strings right now, so all that can really be done is print and
  /// count them.
  final List<String> warnings;

  /// Were there any warnings or errors in extracting messages.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Are plural and gender expressions required to be at the top level
  /// of an expression, or are they allowed to be embedded in string literals.
  ///
  /// For example, the following expression
  ///     'There are ${Intl.plural(...)} items'.
  /// is legal if [allowEmbeddedPluralsAndGenders] is true, but illegal
  /// if [allowEmbeddedPluralsAndGenders] is false.
  bool allowEmbeddedPluralsAndGenders;

  /// Are examples required on all messages.
  bool examplesRequired;

  bool descriptionRequired;

  /// How messages with the same name are resolved.
  ///
  /// This function is allowed to mutate its arguments.
  MainMessage Function(MainMessage, MainMessage)? mergeMessages;

  /// Parse the source of the Dart program file [file] and return a Map from
  /// message names to [IntlMessage] instances.
  ///
  /// If [transformer] is true, assume the transformer will supply any "name"
  /// and "args" parameters required in Intl.message calls.
  Map<String, MainMessage> parseFile(File file, [bool transformer = false]) {
    var contents = file.readAsStringSync();
    return parseContent(contents, file.path, transformer);
  }

  /// Parse the source of the Dart program from a file with content
  /// [fileContent] and path [path] and return a Map from message
  /// names to [IntlMessage] instances.
  ///
  /// If [transformer] is true, assume the transformer will supply any "name"
  /// and "args" parameters required in Intl.message calls.
  Map<String, MainMessage> parseContent(
    String fileContent,
    String filepath,
    bool transformer,
  ) {
    var contents = fileContent;
    origin = filepath;
    // Optimization to avoid parsing files we're sure don't contain any messages.
    if (contents.contains('Intl.')) {
      root = _parseCompilationUnit(contents, origin!);
    } else {
      return {};
    }
    var visitor = MessageFindingVisitor(
      this,
      generateNameAndArgs: transformer,
    );
    root.accept(visitor);
    return visitor.messages;
  }

  CompilationUnit _parseCompilationUnit(String contents, String origin) {
    var result = parseString(
      content: contents,
      featureSet: _featureSet,
      throwIfDiagnostics: false,
    );

    if (result.errors.isNotEmpty) {
      print('Error in parsing $origin, no messages extracted.');
      throw ArgumentError('Parsing errors in $origin');
    }

    return result.unit;
  }

  /// The root of the compilation unit, and the first node we visit. We hold
  /// on to this for error reporting, as it can give us line numbers of other
  /// nodes.
  late CompilationUnit root;

  /// An arbitrary string describing where the source code came from. Most
  /// obviously, this could be a file path. We use this when reporting
  /// invalid messages.
  String? origin;

  String reportErrorLocation(AstNode node) {
    var result = StringBuffer();
    if (origin != null) result.write('    from $origin');
    var line = root.lineInfo.getLocation(node.offset);
    result.write('    line: ${line.lineNumber}, column: ${line.columnNumber}');
    return result.toString();
  }
}

/// If a message is a string literal without interpolation, compute
/// a name based on that and the meaning, if present.
// NOTE: THIS LOGIC IS DUPLICATED IN intl AND THE TWO MUST MATCH.
String? computeMessageName(String name, String? text, String? meaning) {
  if (name != '') return name;
  return meaning == null ? text : '${text}_$meaning';
}
