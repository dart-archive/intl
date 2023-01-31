#!/usr/bin/env dart
// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This script uses the extract_messages.dart library to find the Intl.message
/// calls in the target dart files and produces ARB format output. See
/// https://code.google.com/p/arb/wiki/ApplicationResourceBundleSpecification
library extract_to_arb;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/src/arb_generation.dart';
import 'package:intl_translation/src/directory_utils.dart';
import 'package:path/path.dart' as path;

void main(List<String> args) {
  var targetDir = '.';
  var outputFilename = 'intl_messages.arb';
  String? sourcesListFile;
  var transformer = false;
  var parser = ArgParser();
  var extract = MessageExtraction();
  String? locale;

  // Whether to include source_text in messages
  var includeSourceText = false;

  // If this is true, no translation meta data is written
  var suppressMetaData = false;

  // If this is true, the @@last_modified entry is not output.
  var suppressLastModified = false;

  parser.addFlag('help',
      abbr: 'h', negatable: false, help: 'Print this usage information.');

  // If this is true, then treat all warnings as errors.
  parser.addFlag('suppress-last-modified',
      callback: (x) => suppressLastModified = x,
      help: 'Suppress @@last_modified entry.');
  parser.addFlag('suppress-warnings',
      defaultsTo: false,
      callback: (x) => extract.suppressWarnings = x,
      help: 'Suppress printing of warnings.');
  parser.addFlag('suppress-meta-data',
      callback: (x) => suppressMetaData = x,
      help: 'Suppress writing meta information');
  parser.addFlag('warnings-are-errors',
      callback: (x) => extract.warningsAreErrors = x,
      help: 'Treat all warnings as errors, stop processing ');
  parser.addFlag('embedded-plurals',
      defaultsTo: true,
      callback: (x) => extract.allowEmbeddedPluralsAndGenders = x,
      help: 'Allow plurals and genders to be embedded as part of a larger '
          'string, otherwise they must be at the top level.');
  //TODO(mosuem): All references to the transformer can be removed, but this
  // should happen in a separate PR to help with testing.
  parser.addFlag('transformer',
      callback: (x) => transformer = x,
      help: 'Assume that the transformer is in use, so name and args '
          "don't need to be specified for messages.");
  parser.addOption('locale',
      defaultsTo: null,
      callback: (value) => locale = value,
      help: 'Specify the locale set inside the arb file.');
  parser.addFlag(
    'with-source-text',
    callback: (x) => includeSourceText = x,
    help: 'Include source_text in meta information.',
  );
  parser.addOption(
    'output-dir',
    callback: (value) {
      if (value != null) targetDir = value;
    },
    help: 'Specify the output directory.',
  );
  parser.addOption(
    'output-file',
    callback: (value) {
      if (value != null) outputFilename = value;
    },
    help: 'Specify the output file.',
  );
  parser.addOption(
    'sources-list-file',
    callback: (value) => sourcesListFile = value,
    help: 'A file that lists the Dart files to read, one per line.'
        'The paths in the file can be absolute or relative to the '
        'location of this file.',
  );
  parser.addFlag(
    'require_descriptions',
    defaultsTo: false,
    help: "Fail for messages that don't have a description.",
    callback: (val) => extract.descriptionRequired = val,
  );

  var argResults = parser.parse(args);
  var showHelp = (argResults['help'] as bool?) ?? false;
  if (args.isEmpty || showHelp) {
    print('Accepts Dart source files and produce $outputFilename as output.');
    print('');
    print('Usage: extract_to_arb [options] <files.dart>');
    print('');
    print(parser.usage);
    exit(0);
  }

  var allMessages = <String, dynamic>{};
  if (locale != null) {
    allMessages['@@locale'] = locale!;
  }
  if (!suppressLastModified) {
    allMessages['@@last_modified'] = DateTime.now().toIso8601String();
  }

  var dartFiles = <String>[
    ...args.where((x) => x.endsWith('.dart')),
    ...linesFromFile(sourcesListFile)
  ];
  dartFiles
      .map((dartFile) => extract.parseFile(File(dartFile), transformer))
      .expand((parsedFile) => parsedFile.entries)
      .map((nameToMessage) => toARB(
            message: nameToMessage.value,
            includeSourceText: includeSourceText,
            suppressMetadata: suppressMetaData,
          ))
      .forEach((message) => allMessages.addAll(message));
  var file = File(path.join(targetDir, outputFilename));
  file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(allMessages));
  if (extract.hasWarnings && extract.warningsAreErrors) {
    exit(1);
  }
}
