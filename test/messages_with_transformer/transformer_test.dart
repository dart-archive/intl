import 'package:unittest/unittest.dart';

import 'package:intl/intl.dart';

import 'messages_all.dart';

foo() => Intl.message("foo");

main() async {
  await initializeMessages("zz");

test("Message without name/args", () {
  Intl.defaultLocale = "zz";
  expect(foo(), "bar");
  });
}