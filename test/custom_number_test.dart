// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library fixnum_test;

import 'package:intl/intl.dart';
import 'package:test/test.dart';

var myNumValues = {
  MyNum(0): [
    '0',
    'USD0.00',
    '0%',
    '0',
  ],
  MyNum(12345): [
    '12,345',
    'USD12,345.00',
    '1,234,500%',
    '12.3K',
  ],
  MyNum(12345.6789): [
    '12,345.679',
    'USD12,345.68',
    '1,234,568%',
    '12.3K',
  ],
};

void main() {
  test('decimal', () {
    myNumValues.forEach((number, expected) {
      var wrap = MyNumIntl(number);

      var decimal = NumberFormat.decimalPattern().format(wrap);
      expect(decimal, expected[0]);
      var currency = NumberFormat.currency().format(wrap);
      expect(currency, expected[1]);
      var percent = NumberFormat.percentPattern().format(wrap);
      expect(percent, expected[2]);
      var compact = NumberFormat.compact().format(wrap);
      expect(compact, expected[3]);
    });
  });
}

/// My custom number (like Decimal from decimal package)
class MyNum {
  MyNum(this.value);
  final num value;
  bool get isNegative => value.isNegative;
  MyNum abs() => MyNum(value.abs());
  MyNum operator +(MyNum other) => MyNum(value + other.value);
  MyNum operator -(MyNum other) => MyNum(value - other.value);
  MyNum operator ~/(MyNum other) => MyNum(value ~/ other.value);
  MyNum operator *(MyNum other) => MyNum(value * other.value);
  MyNum operator /(MyNum other) => MyNum(value / other.value);
  MyNum remainder(MyNum other) => MyNum(value.remainder(other.value));
  int toInt() => value.toInt();
  double toDouble() => value.toDouble();
  @override
  bool operator ==(dynamic other) => value == other.value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value.toString();
}

/// Adapter to allow using NumerFormat with a custom MyNum
class MyNumIntl {
  MyNumIntl(this.value);
  final MyNum value;

  MyNum _toMyNum(dynamic other) => other is num
      ? MyNum(other)
      : other is MyNumIntl
          ? other.value
          : other;

  bool get isNegative => value.isNegative;
  MyNumIntl abs() => MyNumIntl(value.abs());
  MyNumIntl operator +(dynamic other) => MyNumIntl(value + _toMyNum(other));
  MyNumIntl operator -(dynamic other) => MyNumIntl(value - _toMyNum(other));
  MyNumIntl operator ~/(dynamic other) => MyNumIntl(value ~/ _toMyNum(other));
  MyNumIntl operator *(dynamic other) => MyNumIntl(value * _toMyNum(other));
  MyNumIntl operator /(dynamic other) => MyNumIntl(value / _toMyNum(other));
  MyNumIntl remainder(dynamic other) =>
      MyNumIntl(value.remainder(_toMyNum(other)));
  int toInt() => value.toInt();
  double toDouble() => value.toDouble();
  @override
  bool operator ==(dynamic other) => value == _toMyNum(other);
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value.toString();
}
