// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(Duration(seconds: 180))

library failed_extraction_test;

import 'dart:io';

import 'package:test/test.dart';

import 'message_extraction_test.dart';

void main() {
  test('Expect warnings but successful extraction', () async {
    await runTestWithWarnings(warningsAreErrors: false, expectedExitCode: 0);
  });
}

const List<String> defaultFiles = [
  'sample_with_messages.dart',
  'part_of_sample_with_messages.dart'
];

Future<void> runTestWithWarnings(
    {required bool warningsAreErrors,
    int? expectedExitCode,
    bool embeddedPlurals = true,
    List<String> sourceFiles = defaultFiles}) async {
  void verify(ProcessResult result) {
    try {
      expect(result.exitCode, expectedExitCode);
    } finally {
      deleteGeneratedFiles();
    }
  }

  await copyFilesToTempDirectory();

  var program = asTestDirPath('../../bin/extract_to_arb.dart');
  var args = <String>['--output-dir=$tempDir'];
  if (warningsAreErrors) {
    args.add('--warnings-are-errors');
  }
  if (!embeddedPlurals) {
    args.add('--no-embedded-plurals');
  }
  var files = sourceFiles.map(asTempDirPath).toList();
  var allArgs = <String?>[program, ...args, ...files];
  var callback = expectAsync1(verify);

  run(null, allArgs).then(callback);
}
