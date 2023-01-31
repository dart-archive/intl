// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library verify_and_run;

import 'dart:convert';
import 'dart:io';

import 'sample_with_messages.dart' as sample;
import 'verify_messages.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: run_and_verify [message_file.arb]');
    exit(0);
  }

  // Verify message translation output
  await sample.main();
  verifyResult();

  // Messages with skipExtraction set should not be extracted
  var fileArgs = args.where((x) => x.contains('.arb'));
  var messages = jsonDecode(File(fileArgs.first).readAsStringSync())
      as Map<String, dynamic>;
  messages.forEach((name, _) {
    // Assume any name with 'skip' in it should not have been extracted.
    if (name.contains('skip')) {
      throw "A skipped message was extracted ('$name')";
    }
  });
}
