// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library fixnum_test;

import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';

var int64Values = {
  new Int64(12345): ["USD12,345.00", "1,234,500%"],
  new Int64(-12345): ["-USD12,345.00", "-1,234,500%"],
  new Int64(0x7FFFFFFFFFFFF): [
    "USD2,251,799,813,685,247.00",
    "225,179,981,368,524,700%"
  ],
  Int64.parseHex('7FFFFFFFFFFFFFF'): [
    "USD576,460,752,303,423,487.00",
    "57,646,075,230,342,348,700%"
  ],
  Int64.parseHex('8000000000000000'): [
    "-USD9,223,372,036,854,775,808.00",
    "-922,337,203,685,477,580,800%"
  ]
};

var int32Values = {
  new Int32(12345): ["USD12,345.00", "1,234,500%"],
  new Int32(0x7FFFF): ["USD524,287.00", "52,428,700%"],
  Int32.parseHex('7FFFFFF'): ["USD134,217,727.00", "13,421,772,700%"],
  Int32.parseHex('7FFFFFFF'): ["USD2,147,483,647.00", "214,748,364,700%"],
  Int32.parseHex('80000000'): ["-USD2,147,483,648.00", "-214,748,364,800%"]
};

var microMoneyValues = {
  new MicroMoney(new Int64(12345670000)): ["USD12,345.67", "1,234,567%"],
  new MicroMoney(new Int64(12345671000)): ["USD12,345.67", "1,234,567%"],
  new MicroMoney(new Int64(12345678000)): ["USD12,345.68", "1,234,568%"],
  new MicroMoney(new Int64(-12345670000)): ["-USD12,345.67", "-1,234,567%"],
  new MicroMoney(new Int64(-12345671000)): ["-USD12,345.67", "-1,234,567%"],
  new MicroMoney(new Int64(-12345678000)): ["-USD12,345.68", "-1,234,568%"],
  new MicroMoney(new Int64(12340000000)): ["USD12,340.00", "1,234,000%"],
  new MicroMoney(new Int64(0x7FFFFFFFFFFFF)): [
    "USD2,251,799,813.69",
    "225,179,981,369%"
  ],
  new MicroMoney(Int64.parseHex('7FFFFFFFFFFFFFF')): [
    "USD576,460,752,303.42",
    "57,646,075,230,342%"
  ],
  new MicroMoney(Int64.parseHex('7FFFFFFFFFFFFFFF')): [
    "USD9,223,372,036,854.78",
    "922,337,203,685,478%"
  ],
  new MicroMoney(Int64.parseHex('8000000000000000')): [
    "-USD9,223,372,036,854.78",
    "-922,337,203,685,478%"
  ]
};

main() {
  test('int64', () {
    int64Values.forEach((number, expected) {
      var currency = new NumberFormat.currency().format(number);
      expect(currency, expected.first);
      var percent = new NumberFormat.percentPattern().format(number);
      expect(percent, expected[1]);
    });
  });

  test('int32', () {
    int32Values.forEach((number, expected) {
      var currency = new NumberFormat.currency().format(number);
      expect(currency, expected.first);
      var percent = new NumberFormat.percentPattern().format(number);
      expect(percent, expected[1]);
    });
  });

  test('micro money', () {
    microMoneyValues.forEach((number, expected) {
      // ignore: deprecated_member_use
      var currency = new NumberFormat.currencyPattern().format(number);
      expect(currency, expected.first);
      var percent = new NumberFormat.percentPattern().format(number);
      expect(percent, expected[1]);
    });
  });
}
