// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../extract_messages.dart';
import '../src/messages/complex_message.dart';
import '../src/messages/message.dart';
import '../src/messages/message_extraction_exception.dart';
import 'plural_gender_visitor.dart';

/// Given an interpolation, find all of its chunks, validate that they are only
/// simple variable substitutions or else Intl.plural/gender calls,
/// and keep track of the pieces of text so that other parts
/// of the program can deal with the simple string sections and the generated
/// parts separately. Note that this is a SimpleAstVisitor, so it only
/// traverses one level of children rather than automatically recursing. If we
/// find a plural or gender, which requires recursion, we do it with a separate
/// special-purpose visitor.
class InterpolationVisitor extends SimpleAstVisitor {
  final Message message;

  /// The message extraction in which we are running.
  final MessageExtraction extraction;

  InterpolationVisitor(this.message, this.extraction);

  final List pieces = [];
  String get extractedMessage => pieces.join();

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    node.visitChildren(this);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    node.visitChildren(this);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    pieces.add(node.value);
  }

  @override
  void visitInterpolationString(InterpolationString node) {
    pieces.add(node.value);
  }

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
    if (node.expression is SimpleIdentifier) {
      handleSimpleInterpolation(node);
    } else {
      lookForPluralOrGender(node);
    }
  }

  void lookForPluralOrGender(InterpolationExpression node) {
    var visitor = PluralAndGenderVisitor(
      pieces,
      message as ComplexMessage,
      extraction,
    );
    node.accept(visitor);
    if (!visitor.foundPluralOrGender) {
      throw MessageExtractionException(
          'Only simple identifiers and Intl.plural/gender/select expressions '
          'are allowed in message '
          'interpolation expressions.\nError at $node');
    }
  }

  void handleSimpleInterpolation(InterpolationExpression node) {
    var index = arguments.indexOf(node.expression.toString());
    if (index == -1) {
      throw MessageExtractionException(
          'Cannot find argument ${node.expression}');
    }
    pieces.add(index);
  }

  List get arguments => message.arguments;
}
