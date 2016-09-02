// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A transformer for Intl messages, supplying the name and arguments
/// automatically.
library intl_transformer;

import 'package:barback/barback.dart';

import 'src/message_rewriter.dart';

/// Rewrites Intl.message calls to automatically insert the name and args
/// parameters.
class IntlMessageTransformer extends Transformer {
  IntlMessageTransformer.asPlugin();

  String get allowedExtensions => ".dart";

  apply(Transform transform) async {
    var content = await transform.primaryInput.readAsString();
    var id = transform.primaryInput.id;
    var newContent = rewriteMessages(content, '$id');
    transform.addOutput(new Asset.fromString(id, newContent));
  }
}
