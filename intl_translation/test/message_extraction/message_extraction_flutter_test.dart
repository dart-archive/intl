// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(Duration(seconds: 180))

/// A test for message extraction and code generation using generated
/// JSON rather than functions

import 'package:test/test.dart';

import 'message_extraction_test.dart' as main_test;

void main() {
  main_test.useJson = true;
  main_test.useFlutterLocaleSplit = true;
  main_test.main();
}
