// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Contains a parser for ICU format plural/gender/select format for localized
/// messages. See extract_to_arb.dart and make_hardcoded_translation.dart.
library message_parser;

import 'messages/composite_message.dart';
import 'messages/literal_string_message.dart';
import 'messages/message.dart';
import 'messages/pair_message.dart';
import 'messages/submessages/gender.dart';
import 'messages/submessages/plural.dart';
import 'messages/submessages/select.dart';
import 'messages/variable_substitution_message.dart';

class MessageParser {
  final _ParserUtil _parser;

  MessageParser(String input) : _parser = _ParserUtil(input);

  Message pluralGenderSelectParse() =>
      (_parser.pluralOrGenderOrSelect(0) ?? _parser.empty(0)).result;

  Message nonIcuMessageParse() =>
      (_parser.simpleText(0) ?? _parser.empty(0)).result;
}

/// Holds a parsed piece of the input
class At<T extends Message> {
  /// Holds the result of parsing this piece of the message
  final T result;

  /// Holds the position of the parser after parsing this piece of the message
  final int at;

  At(this.result, this.at);

  /// Helper method to simplify null checks
  At<S> mapResult<S extends Message>(S Function(T res) callable) =>
      At<S>(callable(result), at);
}

/// Methods for actually parsing a message.
///
/// The parser goes through the message in a DFS kind of way. Whenever a branch
/// fails to parse, it returns null.
class _ParserUtil {
  final String input;
  const _ParserUtil(this.input);

  //Precompiled regexes
  static final RegExp quotedBracketOpen = RegExp(r"'({)'");
  static final RegExp quotedBracketClose = RegExp(r"'(})'");
  static final RegExp doubleQuotes = RegExp(r"'(')");
  static final RegExp numberRegex = RegExp(r'\s*([0-9]+)\s*');
  static final RegExp nonICURegex = RegExp(r'[^\{\}\<]');
  static final RegExp idRegex = RegExp(r'\s*([a-zA-Z][a-zA-Z_0-9]*)\s*');
  static final RegExp nonOpenBracketRegex = RegExp(r'[^\{]+');
  static final RegExp commaWithWhitespace = RegExp(r'\s*(,)\s*');
  static final List<String> pluralKeywords = [
    '=0',
    '=1',
    '=2',
    'zero',
    'one',
    'two',
    'few',
    'many',
    'other'
  ];
  static final Map<String, RegExp> pluralKeywordsToRegex = {
    for (var v in pluralKeywords) v: RegExp('\\s*$v\\s*')
  };
  static final List<String> genderKeywords = ['female', 'male', 'other'];
  static final Map<String, RegExp> genderKeywordsToRegex = {
    for (var v in genderKeywords) v: RegExp('\\s*$v\\s*')
  };

  /// Corresponds to a [+] operator in a regex, matching at least one occurrence
  /// of the [callable].
  static At<CompositeMessage>? oneOrMore(
    At? Function(int s) callable,
    int at,
  ) {
    var newAt = -1;
    var results = <At>[];
    while (newAt != at) {
      newAt = at;
      var parser = callable(newAt);
      if (parser != null) {
        at = parser.at;
        results.add(parser);
      }
    }
    return results.isNotEmpty
        ? At(CompositeMessage(results.map((p) => p.result).toList()), newAt)
        : null;
  }

  /// Corresponds to an [AND] operator, matching all [callables] or failing, i.e.
  /// returning [null].
  static At<CompositeMessage>? and(
    List<At? Function(int s)> callables,
    int at,
  ) {
    var newAt = at;
    var resParser = <At>[];
    for (var i = 0; i < callables.length; i++) {
      var callable = callables[i];
      var parser = callable.call(newAt);
      if (parser != null) {
        resParser.add(parser);
        newAt = parser.at;
      } else {
        return null;
      }
    }
    return At(CompositeMessage(resParser.map((p) => p.result).toList()), newAt);
  }

  /// Match a simple string
  At<LiteralString>? matchString(int at, String t) => input.startsWith(t, at)
      ? At(LiteralString(t, null), at + t.length)
      : null;

  /// Match any of the given keywords
  At<LiteralString>? asKeywords(Map<String, RegExp> keywordsToRegex, int at) {
    if (at < input.length) {
      for (var entry in keywordsToRegex.entries) {
        var match = entry.value.matchAsPrefix(input, at);
        if (match != null) {
          return At(LiteralString(entry.key, null), match.end);
        }
      }
    }
    return null;
  }

  /// Parse whitespace
  At<LiteralString> trimAt(int at) => at < input.length
      ? At(LiteralString(input), RegExp(r'\s*').matchAsPrefix(input, at)!.end)
      : At(LiteralString(''), at);

  At<LiteralString>? openCurly(int at) => matchString(at, '{');
  At<LiteralString>? closeCurly(int at) => matchString(at, '}');

  At<LiteralString>? icuEscapedText(int at) {
    if (at < input.length) {
      var match = quotedBracketOpen.matchAsPrefix(input, at) ??
          quotedBracketClose.matchAsPrefix(input, at) ??
          doubleQuotes.matchAsPrefix(input, at);
      if (match != null) {
        var matchGroup = match.group(1);
        if (matchGroup != null) {
          return At(LiteralString(matchGroup), match.end);
        }
      }
    }
    return null;
  }

  At<LiteralString>? icuText(int at) {
    var match = nonICURegex.matchAsPrefix(input, at);
    return at < input.length && match != null
        ? At(LiteralString(input[at]), at + 1)
        : null;
  }

  At<LiteralString>? messageText(int at) {
    return oneOrMore((s) => icuEscapedText(s) ?? icuText(s), at)
        ?.mapResult((compMsg) {
      return LiteralString(compMsg.pieces
          .whereType<LiteralString>()
          .map((e) => e.string)
          .join());
    });
  }

  At<LiteralString>? nonIcuMessageText(int at) {
    if (at < input.length) {
      var match = nonOpenBracketRegex.matchAsPrefix(input, at);
      if (match != null) {
        var matchGroup = match.group(0);
        if (matchGroup != null) {
          return At(LiteralString(matchGroup), match.end);
        }
      }
    }
    return null;
  }

  At<LiteralString>? number(int at) {
    var match = numberRegex.matchAsPrefix(input, at);
    return match != null && match.group(1) != null
        ? At(LiteralString(int.parse(match.group(1)!).toString()), match.end)
        : null;
  }

  At<LiteralString>? id(int at) {
    if (at < input.length) {
      var match = idRegex.matchAsPrefix(input, at);
      if (match != null) {
        var matchGroup = match.group(1);
        if (matchGroup != null) {
          return At(LiteralString(matchGroup), match.end);
        }
      }
    }
    return null;
  }

  At<LiteralString>? comma(int at) {
    var match = commaWithWhitespace.matchAsPrefix(input, at);
    return at < input.length && match != null
        ? At(LiteralString(','), match.end)
        : null;
  }

  At<LiteralString>? preface(int at) {
    return and(
      [
        (s) => openCurly(s),
        (s) => id(s),
        (s) => comma(s),
      ],
      at,
    )?.mapResult((compMsg) => compMsg.pieces[1] as LiteralString);
  }

  At<PairMessage<LiteralString, Message>>? pluralClausePairs(int at) {
    return and(
      [
        (s) => trimAt(s),
        (s) => asKeywords(pluralKeywordsToRegex, s),
        (s) => openCurly(s),
        (s) => interiorText(s),
        (s) => closeCurly(s),
        (s) => trimAt(s),
      ],
      at,
    )?.mapResult((compMsg) {
      var pluralKeyword = compMsg.pieces[1] as LiteralString;
      var interiorText = compMsg.pieces[3];
      return PairMessage<LiteralString, Message>(pluralKeyword, interiorText);
    });
  }

  At<Plural>? intlPlural(int at) {
    return and(
      [
        (s) => preface(s),
        (s) => matchString(s, 'plural'),
        (s) => comma(s),
        (s) => oneOrMore((s1) => pluralClausePairs(s1), s),
        (s) => closeCurly(s),
      ],
      at,
    )?.mapResult((compMsg) {
      var preface = compMsg.pieces[0] as LiteralString;
      var pluralClause = compMsg.pieces[3] as CompositeMessage;
      return Plural.from(preface.string, pluralClause.pieces, null);
    });
  }

  At<LiteralString>? genderKeyword(int at) =>
      asKeywords(genderKeywordsToRegex, at);

  At<CompositeMessage>? genderClause(int at) {
    return oneOrMore(
      (s1) => and(
        [
          (s) => trimAt(s),
          (s) => genderKeyword(s),
          (s) => openCurly(s),
          (s) => interiorText(s),
          (s) => closeCurly(s),
          (s) => trimAt(s),
        ],
        s1,
      )?.mapResult((compMsg) {
        var genderKeyword = compMsg.pieces[1] as LiteralString;
        var interiorText = compMsg.pieces[3];
        return PairMessage(genderKeyword, interiorText);
      }),
      at,
    );
  }

  At<Gender>? intlGender(int at) {
    return and(
      [
        (s) => preface(s),
        (s) => selectLiteral(s),
        (s) => comma(s),
        (s) => genderClause(s),
        (s) => closeCurly(s),
      ],
      at,
    )?.mapResult((compMsg) {
      var preface = compMsg.pieces[0] as LiteralString;
      var genderClause = (compMsg.pieces[3] as CompositeMessage);
      return Gender.from(preface.string, genderClause.pieces, null);
    });
  }

  At<LiteralString>? selectLiteral(int at) => matchString(at, 'select');

  At<CompositeMessage>? selectClause(int at) {
    return oneOrMore(
      (s1) => and(
        [
          (s) => id(s),
          (s) => openCurly(s),
          (s) => interiorText(s),
          (s) => closeCurly(s),
        ],
        s1,
      )?.mapResult((compMsg) {
        var id = compMsg.pieces[0] as LiteralString;
        var interiorText = compMsg.pieces[2];
        return PairMessage(id, interiorText);
      }),
      at,
    );
  }

  At<Select>? intlSelect(int at) {
    return and(
      [
        (s) => preface(s),
        (s) => selectLiteral(s),
        (s) => comma(s),
        (s) => selectClause(s),
        (s) => closeCurly(s),
      ],
      at,
    )?.mapResult((compMsg) {
      var preface = compMsg.pieces[0] as LiteralString;
      var selectClause = compMsg.pieces[3] as CompositeMessage;
      return Select.from(preface.string, selectClause.pieces, null);
    });
  }

  At<Message>? pluralOrGenderOrSelect(int at) =>
      intlPlural(at) ?? intlGender(at) ?? intlSelect(at);

  At<Message>? contents(int at) =>
      pluralOrGenderOrSelect(at) ?? parameter(at) ?? messageText(at);

  At interiorText(int at) => oneOrMore((s) => contents(s), at) ?? empty(at);

  At<Message>? simpleText(int at) {
    return oneOrMore(
      (s) => nonIcuMessageText(s) ?? parameter(s) ?? openCurly(s),
      at,
    );
  }

  At<LiteralString> empty(int at) => At(LiteralString(''), at);

  At<VariableSubstitution>? parameter(int at) {
    return and(
      [
        (s) => openCurly(s),
        (s) => id(s),
        (s) => closeCurly(s),
      ],
      at,
    )?.mapResult((compMsg) {
      var id = (compMsg.pieces[1] as LiteralString);
      return VariableSubstitution.named(id.string);
    });
  }
}
