// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Test date formatting and parsing while the system time zone is set.
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';

/// The VM arguments we were given, most importantly package-root.
final vmArgs = Platform.executableArguments;

final dart = Platform.executable;

/// Test for a particular timezone. In order to verify that we are in fact
/// running in that time zone, verify that the DateTime offset is one of the
/// expected values.
testTimezone(String timezoneName, {int expectedUtcOffset}) {
  // The VM can be invoked with a "-DPACKAGE_DIR=<directory>" argument to
  // indicate the root of the Intl package. If it is not provided, we assume
  // that the root of the Intl package is the current directory.
  var packageDir = const String.fromEnvironment('PACKAGE_DIR');
  var packageRelative = 'test/timezone_local_even_test_helper.dart';
  var fileToSpawn =
      packageDir == null ? packageRelative : '$packageDir/$packageRelative';

  test("Run tests in $timezoneName time zone", () async {
    List<String> args = []
      ..addAll(vmArgs)
      ..add(fileToSpawn);
    var environment = <String, String>{'TZ': timezoneName};
    if (expectedUtcOffset != null) {
      environment['EXPECTED_TZ_OFFSET_FOR_TEST'] = '$expectedUtcOffset';
    }
    var result = await Process.run(dart, args,
        stdoutEncoding: new Utf8Codec(),
        stderrEncoding: new Utf8Codec(),
        includeParentEnvironment: true,
        environment: environment);
    // Because the actual tests are run in a spawned parocess their output isn't
    // directly visible here. To debug, it's necessary to look at the output of
    // that test, so we print it here for convenience.
    print("Spawning test to run in the $timezoneName time zone. Stderr is:");
    print(result.stderr);
    print("Spawned test in $timezoneName time zone has Stdout:");
    print(result.stdout);
    expect(result.exitCode, 0,
        reason: "Spawned test failed. See the test log from stderr to debug");
  }, testOn: 'linux && vm');
}
