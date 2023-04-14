import 'package:intl/acx_sharded_intl.dart';
import 'package:test/test.dart';
import 'dart:js_util' as js_util;
import 'dart:convert';

void main() {
  setUp(() {
    final testStrings1 = {
      '0': ['Test String 0'],
      '1': ['Test String 1'],
      '2': ['Test String 2']
    };
    final testStrings2 = {
      '3': ['Test String 3'],
      '4': ['Test String 4'],
      '5': ['Test String 5'],
      '6': ['Constructed ', 0, ' String 6']
    };
    final encoding1 = jsonEncode(testStrings1);
    final encoding2 = jsonEncode(testStrings2);
    js_util.setProperty<Object>(js_util.globalThis,
        r'$_intl_pending_translations', js_util.newObject());
    js_util.setProperty(
        js_util.getProperty(js_util.globalThis, r'$_intl_pending_translations'),
        'MyAppId',
        [encoding1, encoding2]);
  });
  test('testIntlMessageTableLookup', () {
    expect(AcxIntlMessageTable.lookup(1), equals('Test String 1'));
    expect(AcxIntlMessageTable.lookup(5), equals('Test String 5'));
    expect(AcxIntlMessageTable.lookup(5), equals('Test String 5'));
    expect(AcxIntlMessageTable.lookupList(6),
        equals(['Constructed ', 0, ' String 6']));
  });
}
