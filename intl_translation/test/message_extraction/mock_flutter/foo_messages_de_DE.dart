// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library keep_the_static_analysis_from_complaining;

class MessageLookup {
  String get messages => throw UnimplementedError(
      'This entire file is only here to make the static'
      ' analysis happy. It will be generated during actual tests.');
}
