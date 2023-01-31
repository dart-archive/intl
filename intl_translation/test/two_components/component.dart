// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A component which should have its own separate messages, with their own
/// translations.
import 'package:intl/intl.dart';

import 'component_messages_all.dart';

/// We can just define a normal message, in which case we'll want to pick up
/// our special locale from the zone variable.
String _message1() => Intl.message('Hello from component', desc: 'hi');

/// Or we can explicitly code our locale.
String _message2() => Intl.message('Explicit locale',
    name: '_message2', desc: 'message two', locale: myParticularLocale);

String get myParticularLocale => '${Intl.defaultLocale}_$mySuffix';

const mySuffix = 'xyz123';

/// We can wrap all of our top-level API calls in a zone that stores the locale.
dynamic componentApiFunction() =>
    Intl.withLocale(myParticularLocale, _message1);

dynamic directApiCall() => _message2();

Future<bool> initComponent() async =>
    await initializeMessages(myParticularLocale);
