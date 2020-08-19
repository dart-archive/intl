// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// @dart=2.9

/// A utility function for test and tools that compensates (at least for very
/// simple cases) for file-dependent programs being run from different
/// directories. The important cases are
///   - running in the directory that contains the test itself, i.e.
///    test/ or a sub-directory.
///   - running in root of this package, which is where the editor and bots will
///   run things by default
library data_directory;

import 'package:dart.testing/google3_test_util.dart' show runfilesDir;
import 'package:path/path.dart' as path;

String get dataDirectory {
  return path.join(intlDirectory, datesRelativeToIntl);
}

// NOTE(tjblasi): Google3-specific code for locating the directory.
String get intlDirectory =>
    path.join(runfilesDir, 'google3', 'third_party', 'dart', 'intl');

String get datesRelativeToIntl => path.join('lib', 'src', 'data', 'dates');
