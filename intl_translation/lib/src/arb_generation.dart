// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'messages/main_message.dart';
import 'messages/message.dart';
import 'messages/submessages/submessage.dart';

/// This is a placeholder for transforming a parameter substitution from
/// the translation file format into a Dart interpolation. In our case we
/// store it to the file in Dart interpolation syntax, so the transformation
/// is trivial.
String leaveTheInterpolationsInDartForm(MainMessage msg, dynamic chunk) {
  if (chunk is String) {
    return chunk;
  } else if (chunk is int) {
    return '\$${msg.arguments[chunk]}';
  } else if (chunk is Message) {
    return chunk.toCode();
  } else {
    throw FormatException('Illegal interpolation: $chunk');
  }
}

/// Convert the [MainMessage] to a trivial JSON format.
Map<String, dynamic> toARB({
  required MainMessage message,
  bool suppressMetadata = false,
  bool includeSourceText = false,
}) {
  var out = <String, dynamic>{};
  if (message.messagePieces.isEmpty) return out;

  // Return a version of the message string with ICU parameters
  // "{variable}" rather than Dart interpolations "$variable".
  out[message.name] = message
      .expanded((msg, chunk) => turnInterpolationIntoICUForm(msg, chunk));

  if (!suppressMetadata) {
    var arbMetadataForMessage = arbMetadata(message);
    out['@${message.name}'] = arbMetadataForMessage;
    if (includeSourceText) {
      arbMetadataForMessage['source_text'] = out[message.name];
    }
  }
  return out;
}

Map<String, dynamic> arbMetadata(MainMessage message) {
  var out = <String, dynamic>{};
  var desc = message.description;
  if (desc != null) {
    out['description'] = desc;
  }
  out['type'] = 'text';
  var placeholders = <String, dynamic>{};
  for (var arg in message.arguments) {
    addArgumentFor(message, arg, placeholders);
  }
  out['placeholders'] = placeholders;
  return out;
}

void addArgumentFor(
  MainMessage message,
  String arg,
  Map<String, dynamic> result,
) {
  var extraInfo = <String, dynamic>{};
  if (message.examples[arg] != null) {
    extraInfo['example'] = message.examples[arg];
  }
  result[arg] = extraInfo;
}

String turnInterpolationIntoICUForm(
  Message message,
  dynamic chunk, {
  bool shouldEscapeICU = false,
}) {
  if (chunk is String) {
    return shouldEscapeICU ? escape(chunk) : chunk;
  } else if (chunk is int && chunk >= 0 && chunk < message.arguments.length) {
    return '{${message.arguments[chunk]}}';
  } else if (chunk is SubMessage) {
    return chunk.expanded((message, chunk) => turnInterpolationIntoICUForm(
          message,
          chunk,
          shouldEscapeICU: true,
        ));
  } else if (chunk is Message) {
    return chunk.expanded((message, chunk) => turnInterpolationIntoICUForm(
          message,
          chunk,
          shouldEscapeICU: shouldEscapeICU,
        ));
  }
  throw FormatException('Illegal interpolation: $chunk');
}

String escape(String s) {
  return s.replaceAll("'", "''").replaceAll('{', "'{'").replaceAll('}', "'}'");
}
