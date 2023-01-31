// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This provides utilities for generating localized versions of
/// messages. It does not stand alone, but expects to be given
/// TranslatedMessage objects and generate code for a particular locale
/// based on them.
///
/// An example of usage can be found
/// in test/message_extract/generate_from_json.dart
library generate_localized;

import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'src/messages/main_message.dart';
import 'src/messages/message.dart';

class MessageGeneration {
  /// If the import path following package: is something else, modify the
  /// [intlImportPath] variable to change the import directives in the generated
  /// code.
  String intlImportPath = 'intl';

  /// If the import path for flutter is not package:flutter, modify the
  /// [flutterImportPath] variable to change the import directives in the
  /// generated code. This is useful to mock out Flutter during tests since
  /// package:flutter cannot be imported from Dart VM.
  String? flutterImportPath = 'package:flutter';

  /// If the path to the generated files is something other than the current
  /// directory, update the [generatedImportPath] variable to change the import
  /// directives in the generated code.
  String generatedImportPath = '';

  /// Given a base file, return the file prefixed with the path to import it.
  /// By default, that is in the current directory, but if [generatedImportPath]
  /// has been set, then use that as a prefix.
  String importForGeneratedFile(String file) =>
      generatedImportPath.isEmpty ? file : '$generatedImportPath/$file';

  /// A list of all the locales for which we have translations. Code that does
  /// the reading of translations should add to this.
  Set<String> allLocales = {};

  /// If we have more than one set of messages to generate in a particular
  /// directory we may want to prefix some to distinguish them.
  String? generatedFilePrefix = '';

  /// Should we use deferred loading for the generated libraries.
  bool useDeferredLoading = true;

  /// Whether to generate null safe code instead of legacy code.
  bool nullSafety = true;

  /// The mode to generate in - either 'release' or 'debug'.
  ///
  /// In release mode, a missing translation is an error. In debug mode, it
  /// falls back to the original string.
  String? codegenMode;

  /// What is the path to the package for which we are generating.
  ///
  /// The exact format of this string depends on the generation mechanism,
  /// so it's left undefined.
  String? package;

  bool get releaseMode => codegenMode == 'release';

  /// Holds the generated translations.
  StringBuffer output = StringBuffer();

  String get orNull => nullSafety ? '?' : '';

  String get notNull => nullSafety ? '!' : '';

  String get orLate => nullSafety ? 'late ' : '';

  String get languageTag => nullSafety ? '' : '// @dart=2.9\n';

  void clearOutput() {
    output = StringBuffer();
  }

  /// Generate a file <[generated_file_prefix]>_messages_<[locale]>.dart
  /// for the [translations] in [locale] and put it in [targetDir].
  void generateIndividualMessageFile(String basicLocale,
      Iterable<TranslatedMessage> translations, String targetDir) {
    final content = contentForLocale(basicLocale, translations);

    // To preserve compatibility, we don't use the canonical version of the
    // locale in the file name.
    final filename = path.join(
        targetDir, '${generatedFilePrefix}messages_$basicLocale.dart');
    File(filename).writeAsStringSync(content);
  }

  /// Generate a string that containts the dart code
  /// with the [translations] in [locale].
  String contentForLocale(
    String basicLocale,
    Iterable<TranslatedMessage> translations,
  ) {
    clearOutput();
    var locale = Message.escapeString(Intl.canonicalizedLocale(basicLocale));
    output.write(prologue(locale));
    // Exclude messages with no translation and translations with no matching
    // original message (e.g. if we're using some messages from a larger
    // catalog)
    var usableTranslations = translations
        .where((translation) => translation.originalMessages.isNotEmpty)
        .toList();
    for (var translation in usableTranslations) {
      for (var original in translation.originalMessages) {
        original.addTranslation(locale, translation.message);
      }
    }
    usableTranslations.sort((a, b) =>
        a.originalMessages.first.name.compareTo(b.originalMessages.first.name));

    writeTranslations(usableTranslations, locale);

    return '$output';
  }

  /// Write out the translated forms.
  void writeTranslations(
    Iterable<TranslatedMessage> usableTranslations,
    String locale,
  ) {
    for (var translation in usableTranslations) {
      // Some messages we generate as methods in this class. Simpler ones
      // we inline in the map from names to messages.
      var messagesThatNeedMethods =
          translation.originalMessages.where(_hasArguments).toSet().toList();
      for (var original in messagesThatNeedMethods) {
        output
          ..write('  ')
          ..write(
              original.toCodeForLocale(locale, _methodNameFor(original.name)))
          ..write('\n\n');
      }
    }
    output.write(messagesDeclaration);

    // Now write the map of names to either the direct translation or to a
    // method.
    var names = (usableTranslations
            .expand((translation) => translation.originalMessages)
            .toSet()
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name)))
        .map((original) => "    '${Message.escapeString(original.name)}'"
            ': ${_mapReference(original, locale)}')
        .join(',\n');
    output
      ..write(names)
      ..write('\n  };\n}\n');
  }

  /// Any additional imports the individual message files need.
  String get extraImports => '';

  String get messagesDeclaration {
    // Includes some gyrations to prevent parts of the deferred libraries from
    // being inlined into the main one, defeating the space savings. Issue
    // 24356
    return '''
  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
  ''';
  }

  /// [generateIndividualMessageFile] for the beginning of the file,
  /// parameterized by [locale].
  String prologue(String locale) => '''
// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a $locale locale. All the
// messages from the main program should be duplicated here with the same
// function name.
$languageTag
// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:$intlImportPath/intl.dart';
import 'package:$intlImportPath/message_lookup_by_library.dart';
$extraImports
final messages = MessageLookup();

typedef String$orNull MessageIfAbsent(
    String$orNull messageStr, List<Object>$orNull args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => '$locale';

${releaseMode ? overrideLookup() : ''}''';

  String overrideLookup() => """
  String$orNull lookupMessage(
      String$orNull message_str,
      String$orNull locale,
      String$orNull name,
      List<Object>$orNull args,
      String$orNull meaning,
      {MessageIfAbsent$orNull ifAbsent}) {
    String$orNull failedLookup(
        String$orNull message_str, List<Object>$orNull args) {
      // If there's no message_str, then we are an internal lookup, e.g. an
      // embedded plural, and shouldn't fail.
      if (message_str == null) return null;
      throw UnsupportedError(
          "No translation found for message '\$name',\\n"
          "  original text '\$message_str'");
    }
    return super.lookupMessage(message_str, locale, name, args, meaning,
        ifAbsent: ifAbsent ?? failedLookup);
  }

""";

  /// This section generates the messages_all_locales.dart file based on the
  /// list of [allLocales].
  String generateLocalesImportFile() {
    clearOutput();
    output.write(localesPrologue);
    for (var locale in allLocales) {
      var baseFile = '${generatedFilePrefix}messages_$locale.dart';
      var file = importForGeneratedFile(baseFile);
      output.write("import '$file' ");
      if (useDeferredLoading) output.write('deferred ');
      output.write('as ${libraryName(locale)};\n');
    }
    output.write('\n');
    output.write('typedef Future<dynamic> LibraryLoader();\n');
    output.write('Map<String, LibraryLoader> _deferredLibraries = {\n');
    for (var rawLocale in allLocales) {
      var locale = Intl.canonicalizedLocale(rawLocale);
      var loadOperation = (useDeferredLoading)
          ? "  '$locale': ${libraryName(locale)}.loadLibrary,\n"
          : "  '$locale': () => Future.value(null),\n";
      output.write(loadOperation);
    }
    output.write('};\n');
    output.write(
        '\nMessageLookupByLibrary$orNull _findExact(String localeName) {\n'
        '  switch (localeName) {\n');
    for (var rawLocale in allLocales) {
      var locale = Intl.canonicalizedLocale(rawLocale);
      output.write(
          "    case '$locale':\n      return ${libraryName(locale)}.messages;\n");
    }
    output.write(localesClosing);
    return output.toString();
  }

  /// Constant string used in [generateLocalesImportFile] for the beginning of
  /// the file.
  String get localesPrologue => """
// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.
$languageTag
// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references

import 'package:$intlImportPath/intl.dart';
import 'package:$intlImportPath/message_lookup_by_library.dart';
import 'package:$intlImportPath/src/intl_helpers.dart';

""";

  /// Constant string used in [generateLocalesImportFile] as the end of the
  /// file.
  String get localesClosing => '''
    default:\n      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String$orNull localeName) async {
  var availableLocale = Intl.verifiedLocale(
    localeName,
    (locale) => _deferredLibraries[locale] != null,
    onFailure: (_) => null);
  if (availableLocale == null) {
    return Future.value(false);
  }
  var lib = _deferredLibraries[availableLocale];
  await (lib == null ? Future.value(false) : lib());
  initializeInternalMessageLookup(() => CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return Future.value(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary$orNull _findGeneratedMessagesFor(String locale) {
  var actualLocale = Intl.verifiedLocale(locale, _messagesExistFor,
      onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
''';

  String generateFlutterImportFile() => throw UnimplementedError();

  /// This section generates the messages_all.dart file.
  String generateMainImportFile({bool flutter = false}) {
    clearOutput();
    output.write(mainPrologue);
    if (flutter) {
      output.write("export '${generatedFilePrefix}messages_flutter.dart'\n"
          "  if (dart.library.js) '${generatedFilePrefix}messages_all_locales.dart'\n"
          '  show initializeMessages;\n\n');
    } else {
      output.write("export '${generatedFilePrefix}messages_all_locales.dart'\n"
          '  show initializeMessages;\n\n');
    }
    output.write(closing);
    return output.toString();
  }

  /// Constant string used in [generateMainImportFile] for the beginning of the
  /// file.
  String get mainPrologue => '''
// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.
$languageTag
''';

  /// Constant string used in [generateMainImportFile] as the end of the file.
  String get closing => '';
}

/// Message generator that parses translations from a `Map<String, dynamic>`.
///
/// [JsonMessageGeneration] and [CodeMapMessageGeneration] extend this
/// class.
abstract class DataMapMessageGeneration extends MessageGeneration {
  /// We import the main file so as to get the shared code to evaluate
  /// the JSON data.
  @override
  String get extraImports => '''
import 'dart:convert';

import '${generatedFilePrefix}messages_all.dart' show evaluateJsonTemplate;
''';

  @override
  String prologue(String locale) => '''${super.prologue(locale)}
  String$orNull evaluateMessage(dynamic translation, List<dynamic> args) {
    return evaluateJsonTemplate(translation, args);
  }
''';

  @override
  void writeTranslations(
      Iterable<TranslatedMessage> usableTranslations, String locale);

  @override
  String get mainPrologue => """${super.mainPrologue}
import 'package:$intlImportPath/intl.dart';
""";

  @override
  String get closing => '''${super.closing}
/// Turn the JSON template into a string.
///
/// We expect one of the following forms for the template.
/// * null -> null
/// * String s -> s
/// * int n -> '\${args[n]}'
/// * List list, one of
///   * ['Intl.plural', int howMany, (templates for zero, one, ...)]
///   * ['Intl.gender', String gender, (templates for female, male, other)]
///   * ['Intl.select', String choice, { 'case' : template, ...} ]
///   * ['text alternating with ', 0 , ' indexes in the argument list']
String$orNull evaluateJsonTemplate(dynamic input, List<dynamic> args) {
  if (input == null) return null;
  if (input is String) return input;
  if (input is int) {
    return '\${args[input]}';
  }

  var template = input as List<dynamic>;
  var messageName = template.first;
  if (messageName == 'Intl.plural') {
     var howMany = args[template[1] as int] as num;
     return evaluateJsonTemplate(
         Intl.pluralLogic(
             howMany,
             zero: template[2],
             one: template[3],
             two: template[4],
             few: template[5],
             many: template[6],
             other: template[7]),
         args);
   }
   if (messageName == 'Intl.gender') {
     var gender = args[template[1] as int] as String;
     return evaluateJsonTemplate(
         Intl.genderLogic(
             gender,
             female: template[2],
             male: template[3],
             other: template[4]),
         args);
   }
   if (messageName == 'Intl.select') {
     var select = args[template[1] as int] as Object;
     var choices = template[2] as Map<Object, Object$orNull>;
     return evaluateJsonTemplate(Intl.selectLogic(select, choices), args);
   }

   // If we get this far, then we are a basic interpolation, just strings and
   // ints.
   var output = StringBuffer();
   for (var entry in template) {
     if (entry is int) {
       output.write('\${args[entry]}');
     } else {
       output.write('\$entry');
     }
   }
   return output.toString();
  }

''';

  @override
  String generateFlutterImportFile() {
    clearOutput();
    output.write(flutterPrologue);
    return output.toString();
  }

  /// Constant string used in [generateFlutterImportFile] for the beginning of
  /// the file.
  String get flutterPrologue => """
// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.
$languageTag
import 'dart:convert';

import 'package:$intlImportPath/intl.dart';
import 'package:$intlImportPath/message_lookup_by_library.dart';
import 'package:$intlImportPath/src/intl_helpers.dart';
import '$flutterImportPath/services.dart';

import '${generatedFilePrefix}messages_all.dart' show evaluateJsonTemplate;

class ResourceMessageLookup extends MessageLookupByLibrary {
  ResourceMessageLookup(this.localeName, String messageText) {
    this.messages =
        const JsonDecoder().convert(messageText) as Map<String, dynamic>;
  }
  final String localeName;

  String$orNull evaluateMessage(dynamic translation, List<dynamic> args) {
    return evaluateJsonTemplate(translation, args);
  }

  ${orLate}Map<String, dynamic> messages;
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String$orNull localeName) async {
  if (localeName == null) {
    return false;
  }

  localeName = Intl.canonicalizedLocale(localeName);

  final localeParts = localeName.split('_');
  initializeInternalMessageLookup(() => CompositeMessageLookup());
  var message = await SystemChannels.localization
      .invokeMethod('Localization.getStringResource', {
    'key': 'flutter_localization_string',
    'locale': localeName,
  });

  if (message == null) {
    try {
      // Normalize the locale name
      localeName = localeName.replaceAll('_', '-');
      message = await rootBundle
          .loadString('__flutter_localization/\${localeName}.json');
    } catch (_) {
      // Locale is not found, return false here to use the default locale.
      return false;
    }
  }

  if (message == null || message.isEmpty) {
    // On Android we include an empty string in the default locale resource,
    // otherwise loading all the other locales would fail. When we encounter an
    // empty string here, we treat it as locale not found. The intl package will
    // fallback to using the default locale.
    return false;
  }

  messageLookup.addLocale(
      localeName, (_) => ResourceMessageLookup(localeName$notNull, message$notNull));
  return true;
}

""";
}

class JsonMessageGeneration extends DataMapMessageGeneration {
  /// Embed the JSON string in a Dart raw string literal.
  ///
  /// In simple cases this just wraps it in a Dart raw triple-quoted
  /// literal. However, a translated message may contain a triple quote,
  /// which would end the Dart literal. So when we encounter this, we turn
  /// it into three adjacent strings, one of which is just the
  /// triple-quote.
  String _embedInLiteral(String jsonMessages) {
    var triple = "'''";
    var result = jsonMessages;
    if (jsonMessages.contains(triple)) {
      var doubleQuote = '"';
      var asAdjacentStrings =
          '$triple  r$doubleQuote$triple$doubleQuote r$triple';
      result = jsonMessages.replaceAll(triple, asAdjacentStrings);
    }
    return "r'''\n$result''';\n}";
  }

  @override
  void writeTranslations(
    Iterable<TranslatedMessage> usableTranslations,
    String locale,
  ) {
    output.write('''
  Map<String, dynamic>$orNull _messages;
  Map<String, dynamic> get messages => _messages ??=
      const JsonDecoder().convert(messageText) as Map<String, dynamic>;
''');

    output.write('  static final messageText = ');
    var messages = usableTranslations
        .expand((translation) => translation.originalMessages);
    var map = <String, dynamic>{
      for (var original in messages)
        original.name: original.toJsonForLocale(locale)
    };
    var jsonEncoded = JsonEncoder().convert(map);
    output.write(_embedInLiteral(jsonEncoded));
  }
}

/// Message generator that stores translations in a constant map.
class CodeMapMessageGeneration extends JsonMessageGeneration {
  @override
  String get extraImports => '''
${super.extraImports}
import 'dart:collection';
''';

  @override
  void writeTranslations(
      Iterable<TranslatedMessage> usableTranslations, String locale) {
    output.write('''
  Map<String, dynamic> get messages => _constMessages;
''');

    var messages = usableTranslations
        .expand((translation) => translation.originalMessages);
    var map = <String, dynamic>{
      for (var original in messages)
        original.name: original.toJsonForLocale(locale)
    };

    output.write('  static const _constMessages = ');
    _writeValue(map);

    output.write(';\n\n');
    output.write('}');
  }

  void _writeValue(dynamic value) {
    if (value == null) {
      output.write('null');
      return;
    }
    if (value is num) {
      output.write(value);
      return;
    }
    if (value is String) {
      _writeString(value);
      return;
    }
    if (value is List) {
      output.write('<Object$orNull>[');
      for (var i = 0; i < value.length - 1; i++) {
        _writeValue(value[i]);
        output.write(',');
      }
      _writeValue(value.last);
      output.write(']');
      return;
    }
    if (value is Map) {
      output.write('<String, Object$orNull>{');
      var isFirst = true;
      value.forEach((k, v) {
        if (isFirst) {
          isFirst = false;
        } else {
          output.write(',');
        }
        _writeValue(k);
        output.write(':');
        _writeValue(v);
      });
      output.write('}');
      return;
    }

    throw 'Unhandled type ${value.runtimeType}';
  }

  void _writeString(String s) {
    final length = s.length;
    output.write('"');
    for (var i = 0; i < length; ++i) {
      final c = s.codeUnitAt(i);
      switch (c) {
        case 0xa:
          output.write(r'\n');
          break;

        case 0xd:
          output.write(r'\r');
          break;

        case 0x22:
          output.write(r'\"');
          break;

        case 0x24:
          output.write(r'\$');
          break;

        case 0x5c:
          output.write(r'\\');
          break;

        default:
          if (c >= 128) {
            final hex = c.toRadixString(16).padLeft(4, '0');
            output.write('\\u$hex');
          } else {
            output.writeCharCode(c);
          }
          break;
      }
    }
    output.write('"');
  }
}

/// This represents a message and its translation. We assume that the
/// translation has some identifier that allows us to figure out the original
/// message it corresponds to, and that it may want to transform the translated
/// text in some way, e.g. to turn whatever format the translation uses for
/// variables into a Dart string interpolation. Specific translation mechanisms
/// are expected to subclass this.
class TranslatedMessage {
  /// The identifier for this message. In the simplest case, this is the name
  /// parameter from the Intl.message call,
  /// but it can be any identifier that this program and the output of the
  /// translation can agree on as identifying a message.
  final String id;

  /// Our translated version of all the [originalMessages].
  final Message translated;

  /// The original messages that we are a translation of. There can
  ///  be more than one original message for the same translation.
  final List<MainMessage> originalMessages;

  /// For backward compatibility, we still have the originalMessage API.
  MainMessage get originalMessage => originalMessages.first;
  set originalMessage(MainMessage m) => originalMessages
    ..clear()
    ..add(m);

  TranslatedMessage(this.id, this.translated, this.originalMessages);

  Message get message => translated;

  @override
  String toString() => id.toString();

  @override
  bool operator ==(Object other) =>
      other is TranslatedMessage && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// We can't use a hyphen in a Dart library name, so convert the locale
/// separator to an underscore.
String libraryName(String x) =>
    'messages_${x.replaceAll('-', '_').toLowerCase()}';

bool _hasArguments(MainMessage message) => message.arguments.isNotEmpty;

///  Simple messages are printed directly in the map of message names to
///  functions as a call that returns a lambda. e.g.
///
///        "foo" : simpleMessage("This is foo"),
///
///  This is helpful for the compiler.
/// */
String _mapReference(MainMessage original, String locale) {
  if (!_hasArguments(original)) {
    // No parameters, can be printed simply.
    return 'MessageLookupByLibrary.simpleMessage('
        "'${original.translations[locale]}')";
  } else {
    return _methodNameFor(original.name);
  }
}

/// Generated method counter for use in [_methodNameFor].
int _methodNameCounter = 0;

/// A map from Intl message names to the generated method names
/// for their translated versions.
Map<String, String> _internalMethodNames = {};

/// Generate a Dart method name of the form "m<number>".
String _methodNameFor(String name) {
  return _internalMethodNames.putIfAbsent(
      name, () => 'm${_methodNameCounter++}');
}
