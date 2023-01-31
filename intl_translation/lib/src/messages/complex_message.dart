// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'message.dart';

/// Abstract class for messages with internal structure, representing the
/// main Intl.message call, plurals, and genders.
abstract class ComplexMessage extends Message {
  ComplexMessage(parent) : super(parent);

  /// When we create these from strings or from AST nodes, we want to look up
  /// and set their attributes by string names, so we override the indexing
  /// operators so that they behave like maps with respect to those attribute
  /// names.
  dynamic operator [](String attributeName);

  /// When we create these from strings or from AST nodes, we want to look up
  /// and set their attributes by string names, so we override the indexing
  /// operators so that they behave like maps with respect to those attribute
  /// names.
  void operator []=(String attributeName, dynamic rawValue);

  List<String> get attributeNames;

  /// Return the name of the message type, as it will be generated into an
  /// ICU-type format. e.g. choice, select
  String get icuMessageName;

  /// Return the message name we would use for this when doing Dart code
  /// generation, e.g. "Intl.plural".
  String get dartMessageName;
}
