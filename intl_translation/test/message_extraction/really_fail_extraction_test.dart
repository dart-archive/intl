// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(Duration(seconds: 180))

library really_fail_extraction_test;

import 'package:test/test.dart';

import 'failed_extraction_test.dart';

void main() {
  test('Expect failure because warnings are errors', () {
    runTestWithWarnings(warningsAreErrors: true, expectedExitCode: 1);
  });
}
