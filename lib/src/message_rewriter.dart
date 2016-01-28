// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Code to rewrite Intl.message calls adding the name and args parameters
/// automatically, primarily used by the transformer.
import 'package:analyzer/analyzer.dart';

import 'package:intl/extract_messages.dart';

/// Rewrite all Intl.message/plural/etc. calls in [source], adding "name"
/// and "args" parameters if they are not provided.
///
/// Return the modified source code. If there are errors parsing, list
/// [sourceName] in the error message.
String rewriteMessages(String source, String sourceName) {
  var messages = findMessages(source, sourceName);
  messages.sort((a, b) => a.sourcePosition.compareTo(b.sourcePosition));

  var start = 0;
  var newSource = new StringBuffer();
  for (var message in messages) {
    newSource.write(source.substring(start, message.sourcePosition));
    // TODO(alanknight): We could generate more efficient code than the
    // original here, dispatching more directly to the MessageLookup.
    newSource.write(message.toOriginalCode());
    start = message.endPosition;
  }
  newSource.write(source.substring(start));
  return newSource.toString();
}

/// Find all the messages in the [source] text.
///
/// Report errors as coming from [sourceName]
List<MainMessage> findMessages(String source, String sourceName) {
  try {
    root = parseCompilationUnit(source, name: sourceName);
  } on AnalyzerErrorGroup catch (e) {
    print("Error in parsing $sourceName, no messages extracted.");
    print("  $e");
    return '';
  }
  origin = sourceName;
  var visitor = new MessageFindingVisitor();
  visitor.generateNameAndArgs = true;
  root.accept(visitor);
  return visitor.messages.values.toList();
}
