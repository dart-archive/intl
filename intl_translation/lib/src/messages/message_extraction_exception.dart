// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Exception thrown when we cannot process a message properly.
class MessageExtractionException implements Exception {
  /// A message describing the error.
  final String message;

  /// Creates a new exception with an optional error [message].
  const MessageExtractionException([this.message = '']);

  @override
  String toString() => 'MessageExtractionException: $message';
}
