// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

import 'package:intl/intl.dart';
export 'code_map_messages_all_locales.dart' show initializeMessages;

/// Turn the JSON template into a string.
///
/// We expect one of the following forms for the template.
/// * null -> null
/// * String s -> s
/// * int n -> '${args[n]}'
/// * List list, one of
///   * ['Intl.plural', int howMany, (templates for zero, one, ...)]
///   * ['Intl.gender', String gender, (templates for female, male, other)]
///   * ['Intl.select', String choice, { 'case' : template, ...} ]
///   * ['text alternating with ', 0 , ' indexes in the argument list']
String? evaluateJsonTemplate(dynamic input, List<dynamic> args) {
  if (input == null) return null;
  if (input is String) return input;
  if (input is int) {
    return '${args[input]}';
  }

  var template = input as List<dynamic>;
  var messageName = template.first;
  if (messageName == 'Intl.plural') {
    var howMany = args[template[1] as int] as num;
    return evaluateJsonTemplate(
        Intl.pluralLogic(howMany,
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
        Intl.genderLogic(gender,
            female: template[2], male: template[3], other: template[4]),
        args);
  }
  if (messageName == 'Intl.select') {
    var select = args[template[1] as int] as Object;
    var choices = template[2] as Map<Object, Object?>;
    return evaluateJsonTemplate(Intl.selectLogic(select, choices), args);
  }

  // If we get this far, then we are a basic interpolation, just strings and
  // ints.
  var output = StringBuffer();
  for (var entry in template) {
    if (entry is int) {
      output.write('${args[entry]}');
    } else {
      output.write('$entry');
    }
  }
  return output.toString();
}
