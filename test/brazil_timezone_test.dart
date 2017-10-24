// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Test date formatting and parsing while the system time zone is set to
/// America/Sao Paulo.
///
/// In Brazil the time change spring/fall happens at midnight. This can make
/// operations working with dates as midnight on a particular day fail. For
/// example, in the (Brazilian) autumn, a date might "fall back" an hour and be
/// on the previous day. This test verifies that we're handling those situations.
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';

// This test relies on setting the TZ environment variable to affect the
// system's time zone calculations. That's only effective on Linux environments,
// and would only work in a browser if we were able to set it before the browser
// launched, which we aren't. So restrict this test to the VM and Linux.
@TestOn('vm')
@TestOn('linux')

/// The VM arguments we were given, most importantly package-root.
final vmArgs = Platform.executableArguments;

final dart = Platform.executable;

main() {
  // The VM can be invoked with a "-DPACKAGE_DIR=<directory>" argument to
  // indicate the root of the Intl package. If it is not provided, we assume
  // that the root of the Intl package is the current directory.
  var packageDir = new String.fromEnvironment('PACKAGE_DIR');
  var packageRelative = 'test/date_time_format_local_even_test.dart';
  var fileToSpawn =
      packageDir == null ? packageRelative : '$packageDir/$packageRelative';

  test("Run tests in Sao Paulo time zone", () async {
    List<String> args = []
      ..addAll(vmArgs)
      ..add(fileToSpawn);
    var result = await Process.run(dart, args,
        stdoutEncoding: UTF8,
        stderrEncoding: UTF8,
        includeParentEnvironment: true,
        environment: {'TZ': 'America/Sao_Paulo'});
    // Because the actual tests are run in a spawned parocess their output isn't
    // directly visible here. To debug, it's necessary to look at the output of
    // that test, so we print it here for convenience.
    print(
        "Spawning test to run in the America/Sao Paulo time zone. Stderr is:");
    print(result.stderr);
    print("Spawned test in America/Sao Paulo time zone has Stdout:");
    print(result.stdout);
    expect(result.exitCode, 0,
        reason: "Spawned test failed. See the test log from stderr to debug");
  });
}
