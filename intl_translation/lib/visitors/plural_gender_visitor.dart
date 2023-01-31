// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../extract_messages.dart';
import '../src/messages/complex_message.dart';
import '../src/messages/message.dart';
import '../src/messages/message_extraction_exception.dart';
import '../src/messages/submessages/gender.dart';
import '../src/messages/submessages/plural.dart';
import '../src/messages/submessages/select.dart';
import '../src/messages/submessages/submessage.dart';
import 'interpolation_visitor.dart';

/// A visitor to extract information from Intl.plural/gender sends. Note that
/// this is a SimpleAstVisitor, so it doesn't automatically recurse. So this
/// needs to be called where we expect a plural or gender immediately below.
class PluralAndGenderVisitor extends SimpleAstVisitor<void> {
  /// The message extraction in which we are running.
  final MessageExtraction extraction;

  /// A plural or gender always exists in the context of a parent message,
  /// which could in turn also be a plural or gender.
  final ComplexMessage parent;

  /// The pieces of the message. We are given an initial version of this
  /// from our parent and we add to it as we find additional information.
  List pieces;

  /// This will be set to true if we find a plural or gender.
  bool foundPluralOrGender = false;

  PluralAndGenderVisitor(this.pieces, this.parent, this.extraction) : super();

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
    // TODO(alanknight): Provide better errors for malformed expressions.
    if (!looksLikePluralOrGender(node.expression)) return;
    var nodeMethod = node.expression as MethodInvocation;
    var reason = checkValidity(nodeMethod);
    if (reason != null) {
      throw reason;
    }
    var message = messageFromMethodInvocation(nodeMethod);
    foundPluralOrGender = true;
    pieces.add(message);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    pieces.add(messageFromMethodInvocation(node));
  }

  /// Return true if [node] matches the pattern for plural or gender message.
  bool looksLikePluralOrGender(Expression expression) {
    if (expression is! MethodInvocation) return false;
    final node = expression;
    if (!['plural', 'gender', 'select'].contains(node.methodName.name)) {
      return false;
    }
    if (node.target is! SimpleIdentifier) return false;
    var target = node.target as SimpleIdentifier;
    return target.token.toString() == 'Intl';
  }

  /// Returns a String describing why the node is invalid, or null if no
  /// reason is found, so it's presumed valid.
  String? checkValidity(MethodInvocation node) {
    // TODO(alanknight): Add reasonable validity checks.
    return null;
  }

  /// Create a MainMessage from [node] using the name and
  /// parameters of the last function/method declaration we encountered
  /// and the parameters to the Intl.message call.
  Message? messageFromMethodInvocation(MethodInvocation node) {
    SubMessage message;
    Map<String, Expression> arguments;
    switch (node.methodName.name) {
      case 'gender':
        message = Gender();
        arguments = SubMessage.argumentsOfInterestFor(node);
        break;
      case 'plural':
        message = Plural();
        arguments = SubMessage.argumentsOfInterestFor(node);
        break;
      case 'select':
        message = Select();
        arguments = Select.argumentsOfInterestFor(node);
        break;
      default:
        throw MessageExtractionException(
            'Invalid plural/gender/select message ${node.methodName.name} '
            'in $node');
    }
    message.parent = parent;

    var buildNotJustCollectErrors = true;
    arguments.forEach((key, Expression value) {
      try {
        var interpolation = InterpolationVisitor(
          message,
          extraction,
        );
        value.accept(interpolation);
        if (buildNotJustCollectErrors) {
          message[key] = interpolation.pieces;
        }
      } on MessageExtractionException catch (e) {
        buildNotJustCollectErrors = false;
        var errString = (StringBuffer()
              ..writeAll(['Error ', e, '\nProcessing <', node, '>'])
              ..write(extraction.reportErrorLocation(node)))
            .toString();
        extraction.onMessage(errString);
        extraction.warnings.add(errString);
      }
    });
    var mainArg = node.argumentList.arguments
        .firstWhere((each) => each is! NamedExpression);
    if (mainArg is SimpleStringLiteral) {
      message.mainArgument = mainArg.toString();
    } else if (mainArg is SimpleIdentifier) {
      message.mainArgument = mainArg.name;
    } else {
      var errString = (StringBuffer()
            ..write('Error (Invalid argument to plural/gender/select, '
                'must be simple variable reference) '
                '\nProcessing <$node>')
            ..write(extraction.reportErrorLocation(node)))
          .toString();
      extraction.onMessage(errString);
      extraction.warnings.add(errString);
    }

    return message;
  }
}
