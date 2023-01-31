// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout(Duration(seconds: 180))

import 'package:intl_translation/extract_messages.dart';
import 'package:intl_translation/src/message_rewriter.dart';
import 'package:test/test.dart';

void main() {
  group('findMessages denied usages', () {
    test('fails with message on non-literal examples Map', () {
      final messageExtraction = MessageExtraction();
      findMessages('''
final variable = 'foo';

String message(String string) =>
    Intl.select(string, {'foo': 'foo', 'bar': 'bar'},
        name: 'message', args: [string], examples: {'string': variable});
      ''', '', messageExtraction);

      expect(messageExtraction.warnings,
          anyElement(contains('Examples must be a const Map literal.')));
    });

    test('fails with message on prefixed expression in interpolation', () {
      final messageExtraction = MessageExtraction();
      findMessages(
          'String message(object) => Intl.message("\${object.property}");',
          '',
          messageExtraction);

      expect(
          messageExtraction.warnings,
          anyElement(
              contains('Only simple identifiers and Intl.plural/gender/select '
                  'expressions are allowed in message interpolation '
                  'expressions')));
    });

    test('fails on call with name referencing variable name inside a function',
        () {
      final messageExtraction = MessageExtraction();
      findMessages('''
      class MessageTest {
        String functionName() {
          final String variableName = Intl.message('message string',
            name: 'variableName' );
        }
      }''', '', messageExtraction);

      expect(
          messageExtraction.warnings,
          anyElement(contains('The \'name\' argument for Intl.message '
              'must match either the name of the containing function '
              'or <ClassName>_<methodName>')));
    });

    test('fails on referencing a name from listed fields declaration', () {
      final messageExtraction = MessageExtraction();
      findMessages('''
      class MessageTest {
        String first, second = Intl.message('message string',
            name: 'first' );
      }''', '', messageExtraction);

      expect(
          messageExtraction.warnings,
          anyElement(contains('The \'name\' argument for Intl.message '
              'must match either the name of the containing function '
              'or <ClassName>_<methodName>')));
    });
  });

  group('findMessages accepted usages', () {
    test('succeeds on Intl call from class getter', () {
      final messageExtraction = MessageExtraction();
      var messages = findMessages('''
      class MessageTest {
        String get messageName => Intl.message("message string",
          name: 'messageName', desc: 'abc');
      }''', '', messageExtraction);

      expect(messages.map((m) => m.name), anyElement(contains('messageName')));
      expect(messageExtraction.warnings, isEmpty);
    });

    test('succeeds on Intl call in top variable declaration', () {
      final messageExtraction = MessageExtraction();
      var messages = findMessages(
          'List<String> list = [Intl.message("message string", '
              'name: "list", desc: "in list")];',
          '',
          messageExtraction);

      expect(messages.map((m) => m.name), anyElement(contains('list')));
      expect(messageExtraction.warnings, isEmpty);
    });

    test('succeeds on Intl call in member variable declaration', () {
      final messageExtraction = MessageExtraction();
      var messages = findMessages('''
      class MessageTest {
        final String messageName = Intl.message("message string",
          name: 'MessageTest_messageName', desc: 'test');
      }''', '', messageExtraction);

      expect(messages.map((m) => m.name),
          anyElement(contains('MessageTest_messageName')));
      expect(messageExtraction.warnings, isEmpty);
    });

    // Note: this type of usage is not recommended.
    test('succeeds on Intl call inside a function as variable declaration', () {
      final messageExtraction = MessageExtraction();
      var messages = findMessages('''
      class MessageTest {
        String functionName() {
          final String variableName = Intl.message('message string',
            name: 'functionName', desc: 'test' );
        }
      }''', '', messageExtraction);

      expect(messages.map((m) => m.name), anyElement(contains('functionName')));
      expect(messageExtraction.warnings, isEmpty);
    });

    test('succeeds on list field declaration', () {
      final messageExtraction = MessageExtraction();
      var messages = findMessages('''
      class MessageTest {
        String first, second = Intl.message('message string', desc: 'test');
      }''', '', messageExtraction);

      expect(
          messages.map((m) => m.name), anyElement(contains('message string')));
      expect(messageExtraction.warnings, isEmpty);
    });

    test('succeeds on prefixed Intl call', () {
      final messageExtraction = MessageExtraction();
      final messages = findMessages('''
      class MessageTest {
        static final String prefixedMessage =
            prefix.Intl.message('message', desc: 'xyz');
      }
      ''', '', messageExtraction);

      expect(messages.map((m) => m.name), anyElement(contains('message')));
      expect(messageExtraction.warnings, isEmpty);
    });
  });

  group('messages with the same name', () {
    test('are resolved in favour of the earlier one by default', () {
      final messageExtraction = MessageExtraction();
      final messages = findMessages('''
      final msg1 = Intl.message('hello there', desc: 'abc');
      final msg2 = Intl.message('hello there', desc: 'def');
      ''', '', messageExtraction);

      expect(messages.map((m) => m.description), equals(['abc']));
    });

    test('are resolved with custom merger', () {
      final messageExtraction = MessageExtraction();
      messageExtraction.mergeMessages =
          (m1, m2) => m1..description = '${m1.description}/${m2.description}';
      final messages = findMessages('''
      final msg1 = Intl.message('hello there', desc: 'abc');
      final msg2 = Intl.message('hello there', desc: 'def');
      ''', '', messageExtraction);

      expect(messages.map((m) => m.description), equals(['abc/def']));
    });
  });

  group('documentation', () {
    test('is populated from dartdoc', () {
      final messageExtraction = MessageExtraction();
      final messages = findMessages('''
      class MessageTest {
        /// Dartdoc.
        static final fieldMsg = Intl.message('field msg', desc: 'xyz');

        /// A long dartdoc.
        ///
        /// With a paragraph.
        String methodMsg(String arg) => Intl.message('method msg', desc: 'xyz');
      }

      /// Hi.
      String variable = Intl.message('variable msg', desc: 'xyz');

      /// Bye.
      function() {
        return Intl.message('function msg', desc: 'xyz');
      }
      ''', '', messageExtraction);

      expect(
          messages.map((m) => m.documentation),
          unorderedEquals([
            ['/// Dartdoc.'],
            ['/// A long dartdoc.', '///', '/// With a paragraph.'],
            ['/// Hi.'],
            ['/// Bye.'],
          ]));
    });
  });
}
