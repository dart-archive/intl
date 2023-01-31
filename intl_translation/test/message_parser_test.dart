// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:intl_translation/src/message_parser.dart';
import 'package:intl_translation/src/messages/composite_message.dart';
import 'package:intl_translation/src/messages/literal_string_message.dart';
import 'package:intl_translation/src/messages/message.dart';
import 'package:intl_translation/src/messages/submessages/gender.dart';
import 'package:intl_translation/src/messages/submessages/plural.dart';
import 'package:intl_translation/src/messages/submessages/select.dart';
import 'package:intl_translation/src/messages/variable_substitution_message.dart';
import 'package:test/test.dart';

void main() {
  test('Gender', () {
    var input =
        '''{gender_of_host, select, female {test} male {test2} other {test3}}''';
    var parsedMessage = MessageParser(input).pluralGenderSelectParse();
    Message expectedMessage = Gender.from(
      'gender_of_host',
      [
        ['female', 'test'],
        ['male', 'test2'],
        ['other', 'test3'],
      ],
      null,
    );
    expect(parsedMessage.toCode(), expectedMessage.toCode());
  });

  test('Plural', () {
    var input = '''{num_guests, plural,
      =0 {Anna does not give a party.}
      =1 {Anna invites Bob to her party.}
      =2 {Anna invites Bob and one other person to her party.}
      other {Anna invites Bob and 2 other people to her party.}}''';
    var parsedMessage = MessageParser(input).pluralGenderSelectParse();
    Message expectedMessage = Plural.from(
      'num_guests',
      [
        ['=0', 'Anna does not give a party.'],
        ['=1', 'Anna invites Bob to her party.'],
        ['=2', 'Anna invites Bob and one other person to her party.'],
        ['other', 'Anna invites Bob and 2 other people to her party.'],
      ],
      null,
    );
    expect(parsedMessage.toCode(), expectedMessage.toCode());
  });

  test('Select', () {
    var input = '''{selector, select,
      type1 {Anna does not give a party.}
      type2 {Anna invites Bob to her party.}}''';
    var parsedMessage = MessageParser(input).pluralGenderSelectParse();
    Message expectedMessage = Select.from(
      'selector',
      [
        ['type1', 'Anna does not give a party.'],
        ['type2', 'Anna invites Bob to her party.'],
      ],
      null,
    );
    expect(parsedMessage.toCode(), expectedMessage.toCode());
  });

  test('Plural with args', () {
    var input = '''{num_guests, plural,
      =0 {{host} does not give a party.}
      =1 {{host} invites {guest} to her party.}
      =2 {{host} invites {guest} and one other person to her party.}
      other {{host} invites {guest} and # other people to her party.}}''';
    var parsedMessage = MessageParser(input).pluralGenderSelectParse();
    Message expectedMessage = Plural.from(
      'num_guests',
      [
        [
          '=0',
          CompositeMessage(
            [
              VariableSubstitution.named('host'),
              LiteralString(' does not give a party.'),
            ],
          )
        ],
        [
          '=1',
          CompositeMessage(
            [
              VariableSubstitution.named('host'),
              LiteralString(' invites '),
              VariableSubstitution.named('guest'),
              LiteralString(' to her party.'),
            ],
          )
        ],
        [
          '=2',
          CompositeMessage(
            [
              VariableSubstitution.named('host'),
              LiteralString(' invites '),
              VariableSubstitution.named('guest'),
              LiteralString(' and one other person to her party.'),
            ],
          )
        ],
        [
          'other',
          CompositeMessage(
            [
              VariableSubstitution.named('host'),
              LiteralString(' invites '),
              VariableSubstitution.named('guest'),
              LiteralString(' and # other people to her party.'),
            ],
          )
        ],
      ],
      null,
    );
    expect(parsedMessage.toCode(), expectedMessage.toCode());
  });
}
