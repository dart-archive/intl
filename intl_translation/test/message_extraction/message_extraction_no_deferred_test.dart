// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(Duration(seconds: 180))

/// A test for message extraction and code generation not using deferred
/// loading for the generated code.
library message_extraction_no_deferred_test;

import 'package:test/test.dart';

import 'message_extraction_test.dart' as main_test;

void main() {
  main_test.useDeferredLoading = false;
  main_test.main();
}
