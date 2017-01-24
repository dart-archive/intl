// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Message/plural format library with locale support. This can have different
/// implementations based on the mechanism for finding the localized versions of
/// messages. This version expects them to be in a library named e.g.
/// 'messages_en_US'. The prefix is set in the "initializeMessages" call, which
/// must be made for a locale before any lookups can be done.
///
/// See Intl class comment or `tests/message_format_test.dart` for more
/// examples.
library message_lookup_by_library;

import 'package:intl/intl.dart';
import 'package:intl/src/intl_helpers.dart';

/// This is a message lookup mechanism that delegates to one of a collection
/// of individual [MessageLookupByLibrary] instances.
class CompositeMessageLookup implements MessageLookup {
  /// A map from locale names to the corresponding lookups.
  Map<String, MessageLookupByLibrary> availableMessages = new Map();

  /// Return true if we have a message lookup for [localeName].
  bool localeExists(localeName) => availableMessages.containsKey(localeName);

  /// The last locale in which we looked up messages.
  ///
  ///  If this locale matches the new one then we can skip looking up the
  ///  messages and assume they will be the same as last time.
  String _lastLocale;

  /// Caches the last messages that we found
  MessageLookupByLibrary _lastLookup;

  @override
  String lookupMessage(
    String messageIfAbsent,
    String locale,
    String name,
    List args,
    String meaning, {
    MessageIfAbsent ifAbsent: _useOriginal,
  }) {
    // If passed null, use the default.
    var knownLocale = locale ?? Intl.getCurrentLocale();
    var messages = (knownLocale == _lastLocale)
        ? _lastLookup
        : _lookupMessageCatalog(knownLocale);
    // If we didn't find any messages for this locale, use the original string,
    // faking interpolations if necessary.
    if (messages == null) {
      return ifAbsent(messageIfAbsent, args);
    }
    return messages.lookupMessage(
      messageIfAbsent,
      locale,
      name,
      args,
      meaning,
      ifAbsent: ifAbsent,
    );
  }

  /// Find the right message lookup for [locale].
  MessageLookupByLibrary _lookupMessageCatalog(String locale) {
    var verifiedLocale = Intl.verifiedLocale(locale, localeExists,
        onFailure: (locale) => locale);
    _lastLocale = locale;
    _lastLookup = availableMessages[verifiedLocale];
    return _lastLookup;
  }

  @override
  void addLocale(String name, Function find) {
    if (localeExists(name)) return;
    var canonical = Intl.canonicalizedLocale(name);
    var newLocale = find(canonical);
    if (newLocale != null) {
      availableMessages[name] = newLocale;
      availableMessages[canonical] = newLocale;
      // If there was already a failed lookup for [newLocale], null the cache.
      if (_lastLocale == newLocale) {
        _lastLocale = null;
        _lastLookup = null;
      }
    }
  }
}

/// The default ifAbsent method, just returns the message string.
String _useOriginal(String message_str, List args) => message_str;

/// This provides an abstract class for messages looked up in generated code.
/// Each locale will have a separate subclass of this class with its set of
/// messages. See generate_localized.dart.
abstract class MessageLookupByLibrary {
  /// Lookup the message for the given [name] and [locale].
  ///
  /// The translated message is returned with the value in [args] interpolated.
  ///
  /// If nothing is found, returns [message].
  String lookupMessage(
    String message,
    String locale,
    String name,
    List args,
    String meaning, {
    MessageIfAbsent ifAbsent,
  }) {
    var notFound = false;
    var actualName = computeMessageName(name, message, meaning);
    if (actualName == null) notFound = true;
    var function = this[actualName];
    notFound = notFound || (function == null);
    if (notFound) {
      return ifAbsent == null ? message : ifAbsent(message, args);
    } else {
      return Function.apply(function, args);
    }
  }

  /// Return our message with the given name
  operator [](String messageName) => messages[messageName];

  /// Subclasses should override this to return a list of their message
  /// functions.
  Map<String, Function> get messages;

  /// Subclasses should override this to return their locale, e.g. 'en_US'
  String get localeName;

  @override
  String toString() => localeName;

  /// Return a function that returns the given string.
  /// An optimization for dart2js, used from the generated code.
  static simpleMessage(translatedString) => () => translatedString;
}
