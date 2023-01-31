// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// An application using the code map messages.
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import 'code_map_messages_all.dart';

String appMessage() => Intl.message('Hello from application', desc: 'hi');

void main() async {
  Intl.defaultLocale = 'fr';
  await initializeMessages('fr');
  test('String lookups should provide translation to French', () {
    expect(appMessage(), 'Bonjour de l\'application');
  });
}
