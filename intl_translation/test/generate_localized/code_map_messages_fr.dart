// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'dart:convert';

import 'code_map_messages_all.dart' show evaluateJsonTemplate;

import 'dart:collection';

final messages = MessageLookup();

typedef String? MessageIfAbsent(String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'fr';

  String? evaluateMessage(dynamic translation, List<dynamic> args) {
    return evaluateJsonTemplate(translation, args);
  }

  Map<String, dynamic> get messages => _constMessages;
  static const _constMessages = <String, Object?>{
    "Hello from application": "Bonjour de l'application"
  };
}
