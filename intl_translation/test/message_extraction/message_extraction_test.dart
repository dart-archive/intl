// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(Duration(seconds: 180))

library message_extraction_test;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../data_directory.dart';

/// Should we use deferred loading.
bool useDeferredLoading = true;

/// Should we generate JSON strings rather than code for messages.
bool useJson = false;

/// Should we generate the code for Flutter locale split.
///
/// Note that this is only supported in JSON mode.
bool useFlutterLocaleSplit = false;

String get _deferredLoadPrefix => useDeferredLoading ? '' : 'no-';

String get deferredLoadArg => '--${_deferredLoadPrefix}use-deferred-loading';

/// The VM arguments we were given, most important package-root.
final vmArgs = Platform.executableArguments;

/// For testing we move the files into a temporary directory so as not to leave
/// generated files around after a failed test. For debugging, we omit that
/// step if [useLocalDirectory] is true. The place we move them to is saved as
/// [tempDir].
String get tempDir => _tempDir ?? (_tempDir = _createTempDir());
String? _tempDir;
String _createTempDir() => useLocalDirectory
    ? '.'
    : Directory.systemTemp.createTempSync('message_extraction_test').path;

bool useLocalDirectory = false;

/// Translate a relative file path into this test directory. This is
/// applied to all the arguments of [run]. It will ignore a string that
/// is an absolute path or begins with "--", because some of the arguments
/// might be command-line options.
String asTestDirPath(String s) {
  if (s.startsWith('--') || path.isAbsolute(s)) return s;
  return path.join(packageDirectory, 'test', 'message_extraction', s);
}

/// Translate a relative file path into our temp directory. This is
/// applied to all the arguments of [run]. It will ignore a string that
/// is an absolute path or begins with "--", because some of the arguments
/// might be command-line options.
String? asTempDirPath([String? s]) {
  if (s == null || s.startsWith('--') || path.isAbsolute(s)) return s;
  return path.join(tempDir, s);
}

typedef ThenResult = Future<ProcessResult> Function(ProcessResult _);

void main() {
  setUp(copyFilesToTempDirectory);
  tearDown(deleteGeneratedFiles);

  test(
      'Test round trip message extraction, translation, code generation, '
      'and printing', () {
    var makeSureWeVerify = expectAsync1(runAndVerify);
    return extractMessages(null)
        .then((result) => generateTranslationFiles(result))
        .then((result) => generateCodeFromTranslation(result))
        .then(makeSureWeVerify)
        .then(checkResult);
  });
}

Future<void> copyFilesToTempDirectory() async {
  if (useLocalDirectory) {
    return;
  }

  var files = <String>[
    asTestDirPath('sample_with_messages.dart'),
    asTestDirPath('part_of_sample_with_messages.dart'),
    asTestDirPath('verify_messages.dart'),
    asTestDirPath('run_and_verify.dart'),
    asTestDirPath('embedded_plural_text_before.dart'),
    asTestDirPath('embedded_plural_text_after.dart'),
    asTestDirPath('print_to_list.dart'),
    asTestDirPath('dart_list.txt'),
    asTestDirPath('arb_list.txt'),
    asTestDirPath('mock_flutter/services.dart'),
  ];

  for (var filePath in files) {
    var file = File(filePath);
    if (file.existsSync()) {
      file.copySync(path.join(tempDir, path.basename(filePath)));
    }
  }

  // Here we copy the package config file so the test can locate packages.
  var configFile = File.fromUri((await Isolate.packageConfig)!);
  var destFile = File(path.join(tempDir, '.dart_tool', 'package_config.json'));
  if (!destFile.parent.existsSync()) {
    destFile.parent.createSync();
  }
  configFile.copySync(destFile.path);
}

void deleteGeneratedFiles() {
  if (useLocalDirectory) return;
  try {
    Directory(tempDir).deleteSync(recursive: true);
  } on Error catch (e) {
    print('Failed to delete $tempDir');
    print('Exception:\n$e');
  }
}

/// Run the process with the given list of filenames, which we assume
/// are in dir() and need to be qualified in case that's not our working
/// directory.
Future<ProcessResult> run(
    ProcessResult? previousResult, List<String?> filenames) {
  // If there's a failure in one of the sub-programs, print its output.
  checkResult(previousResult);
  var filesInTheRightDirectory = filenames
      .map((x) => asTempDirPath(x))
      .map((x) => path.normalize(x!))
      .toList();
  // Inject the script argument --output-dir in between the script and its
  // arguments.
  var args = <String>[
    ...vmArgs,
    filesInTheRightDirectory.first,
    '--output-dir=$tempDir',
    ...filesInTheRightDirectory.skip(1)
  ];
  var result = Process.run(Platform.executable, args,
      stdoutEncoding: Utf8Codec(), stderrEncoding: Utf8Codec());
  return result;
}

void checkResult(ProcessResult? result) {
  if (result != null) {
    if (result.exitCode != 0) {
      print('Error running sub-program:');
      print(result.stdout);
      print(result.stderr);
      print('exitCode=${result.exitCode}');
    }

    expect(result.exitCode, 0);
  }
}

Future<ProcessResult> extractMessages(ProcessResult? previousResult) =>
    run(previousResult, [
      asTestDirPath('../../bin/extract_to_arb.dart'),
      '--suppress-warnings',
      '--sources-list-file',
      'dart_list.txt'
    ]);

Future<ProcessResult> generateTranslationFiles(ProcessResult previousResult) =>
    run(previousResult, [
      asTestDirPath('make_hardcoded_translation.dart'),
      'intl_messages.arb'
    ]);

Future<ProcessResult> generateCodeFromTranslation(
        ProcessResult previousResult) =>
    run(previousResult, [
      asTestDirPath('../../bin/generate_from_arb.dart'),
      deferredLoadArg,
      '--${useJson ? '' : 'no-'}json',
      '--${useFlutterLocaleSplit ? '' : 'no-'}flutter',
      '--flutter-import-path=.', // Mocks package:flutter/services.dart
      '--generated-file-prefix=foo_',
      '--sources-list-file',
      'dart_list.txt',
      '--translations-list-file',
      'arb_list.txt',
    ]);

Future<ProcessResult> runAndVerify(ProcessResult previousResult) {
  return run(previousResult, ['run_and_verify.dart', 'intl_messages.arb']);
}
