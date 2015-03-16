// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Tests for the loose option when parsing dates and times, which accept
/// mixed-case input and are able to skip missing delimiters. This is only
/// tested in basic US locale, it's hard to define for others.
library date_time_loose_test;

import 'package:intl/intl.dart';
import 'package:unittest/unittest.dart';

main() {
  var format;

  var date = new DateTime(2014, 9, 3);

  check(String s) {
    expect(() => format.parse(s), throwsFormatException);
    expect(format.parseLoose(s), date);
  }

  test("Loose parsing yMMMd", () {
    // Note: We can't handle e.g. Sept, we don't have those abbreviations
    // in our data.
    // Also doesn't handle "sep3,2014", or "sep 3.2014"
    format = new DateFormat.yMMMd("en_US");
    check("Sep 3 2014");
    check("sep 3 2014");
    check("sep 3  2014");
    check("sep  3 2014");
    check("sep  3       2014");
    check("sep3 2014");
    check("september 3, 2014");
    check("sEPTembER 3, 2014");
    check("seP 3, 2014");
  });

  test("Loose parsing yMMMd that parses strict", () {
    expect(format.parseLoose("Sep 3, 2014"), date);
  });

  test("Loose parsing yMd", () {
    format = new DateFormat.yMd("en_US");
    check("09 3 2014");
    check("09 00003    2014");
    check("09/    03/2014");
    expect(() => format.parseLoose("09 / 03 / 2014"), throwsA(new isInstanceOf<FormatException>()));
  });

  test("Loose parsing yMd that parses strict", () {
    expect(format.parseLoose("09/03/2014"), date);
    expect(format.parseLoose("09/3/2014"), date);
  });
}
