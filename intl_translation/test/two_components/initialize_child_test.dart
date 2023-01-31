// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Tests initializing the fr_FR locale when we only have fr available.
///
/// This is not actually related to the two components testing, but it's
/// convenient to put it here because there's already a hard-coded
/// message here.
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import 'app_messages_all.dart';
import 'main_app_test.dart';

void main() {
  test('Initialize sub-locale', () async {
    await initializeMessages('fr_FR');
    Intl.withLocale(
        'fr_FR', () => expect(appMessage(), "Bonjour de l'application"));
  });
}
