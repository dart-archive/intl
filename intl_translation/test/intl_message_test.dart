// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:intl_translation/src/messages/literal_string_message.dart';
import 'package:intl_translation/src/messages/submessages/plural.dart';
import 'package:test/test.dart';

void main() {
  test('Prefer explicit =0 to ZERO in plural', () {
    var msg = Plural.from(
        'main',
        [
          ['=0', 'explicit'],
          ['ZERO', 'general']
        ],
        null);
    expect((msg['zero'] as LiteralString).string, 'explicit');
  });

  test('Prefer explicit =1 to ONE in plural', () {
    var msg = Plural.from(
        'main',
        [
          ['=1', 'explicit'],
          ['ONE', 'general']
        ],
        null);
    expect((msg['one'] as LiteralString).string, 'explicit');
  });

  test('Prefer explicit =1 to ONE in plural, reverse order', () {
    var msg = Plural.from(
        'main',
        [
          ['ONE', 'general'],
          ['=1', 'explicit']
        ],
        null);
    expect((msg['one'] as LiteralString).string, 'explicit');
  });

  test('Prefer explicit =2 to TWO in plural', () {
    var msg = Plural.from(
        'main',
        [
          ['=2', 'explicit'],
          ['TWO', 'general']
        ],
        null);
    expect((msg['two'] as LiteralString).string, 'explicit');
  });
}
