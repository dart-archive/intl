// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Test date formatting and parsing while the system time zone is set to
/// Europe/London.
///
/// This is the same as UTC for part of the year, which makes it an interesting
/// edge case.
import 'timezone_test_core.dart';

main() {
  testTimezone('Europe/London', expectedUtcOffset: 0);
}
