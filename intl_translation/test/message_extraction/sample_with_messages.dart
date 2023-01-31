// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is a program with various [Intl.message] messages. It just prints
/// all of them, and is used for testing of message extraction, translation,
/// and code generation.
library sample;

import 'package:intl/intl.dart';

import 'foo_messages_all.dart';
import 'print_to_list.dart';

part 'part_of_sample_with_messages.dart';

String message1() =>
    Intl.message('This is a message', name: 'message1', desc: 'foo');

String message2(String x) => Intl.message('Another message with parameter $x',
    name: 'mess' 'age2',
    desc: 'Description ' '2',
    args: [x],
    examples: const {'x': 3});

// A string with multiple adjacent strings concatenated together, verify
// that the parser handles this properly.
String multiLine() => Intl.message(
    'This '
    'string '
    'extends '
    'across '
    'multiple '
    'lines.',
    desc: 'multi-line');

String get interestingCharactersNoName =>
    Intl.message("'<>{}= +-_\$()&^%\$#@!~`'", desc: 'interesting characters');

// Have types on the enclosing function's arguments.
String types(int a, String b, List c) =>
    Intl.message('$a, $b, $c', name: 'types', args: [a, b, c], desc: 'types');

// This string will be printed with a French locale, so it will always show
// up in the French version, regardless of the current locale.
String alwaysTranslated() => Intl.message('This string is always translated',
    locale: 'fr', name: 'alwaysTranslated', desc: 'always translated');

// Test interpolation with curly braces around the expression, but it must
// still be just a variable reference.
String trickyInterpolation(String s) =>
    Intl.message('Interpolation is tricky when it ends a sentence like $s.',
        name: 'trickyInterpolation', args: [s], desc: 'interpolation');

String get leadingQuotes => Intl.message('"So-called"', desc: 'so-called');

// A message with characters not in the basic multilingual plane.
String originalNotInBMP() =>
    Intl.message('Ancient Greek hangman characters: 𐅆𐅇.', desc: 'non-BMP');

// A string for which we don't provide all translations.
String notAlwaysTranslated() =>
    Intl.message('This is missing some translations',
        name: 'notAlwaysTranslated', desc: 'Not always translated');

// This is invalid and should be recognized as such, because the message has
// to be a literal. Otherwise, interpolations would be outside of the function
// scope.
String someString = 'No, it has to be a literal string';
String noVariables() => Intl.message(someString,
    name: 'noVariables', desc: 'Invalid. Not a literal');

// This is unremarkable in English, but the translated versions will contain
// characters that ought to be escaped during code generation.
String escapable() => Intl.message('Escapable characters here: ',
    name: 'escapable', desc: 'Escapable characters');

String outerPlural(num n) => Intl.plural(n,
    zero: 'none',
    one: 'one',
    other: 'some',
    name: 'outerPlural',
    desc: 'A plural with no enclosing message',
    args: [n]);

String outerGender(String g) => Intl.gender(g,
    male: 'm',
    female: 'f',
    other: 'o',
    name: 'outerGender',
    desc: 'A gender with no enclosing message',
    args: [g]);

String pluralThatFailsParsing(num noOfThings) => Intl.plural(noOfThings,
    one: '1 thing:',
    other: '$noOfThings things:',
    name: 'pluralThatFailsParsing',
    args: [noOfThings],
    desc: 'How many things are there?');

// A standalone gender message where we don't provide name or args. This should
// be rejected by validation code.
String invalidOuterGender(String g) =>
    Intl.gender(g, other: 'o', desc: 'Invalid outer gender');

// A general select
String outerSelect(String currency, num amount) => Intl.select(
    currency,
    {
      'CDN': '$amount Canadian dollars',
      'other': '$amount some currency or other.'
    },
    name: 'outerSelect',
    desc: 'Select',
    args: [currency, amount]);

// An invalid select which should never appear. Unfortunately
// it's difficult to write an automated test for this, you
// just should be able to note a warning for it when extracting.
String failedSelect(String currency) => Intl.select(
    currency, {'this.should.fail': 'not valid', 'other': "doesn't matter"},
    name: 'failedSelect', args: [currency], desc: 'Invalid select');

// A select with a plural inside the expressions.
String nestedSelect(String currency, num amount) => Intl.select(
    currency,
    {
      'CDN': Intl.plural(amount,
          one: '$amount Canadian dollar', other: '$amount Canadian dollars'),
      'other': 'Whatever',
    },
    name: 'nestedSelect',
    args: [currency, amount],
    desc: 'Plural inside select');

// A trivial nested plural/gender where both are done directly rather than
// in interpolations.
String nestedOuter(num number, String gen) => Intl.plural(number,
    other: Intl.gender(gen, male: '$number male', other: '$number other'),
    name: 'nestedOuter',
    args: [number, gen],
    desc: 'Gender inside plural');

String sameContentsDifferentName() => Intl.message('Hello World',
    name: 'sameContentsDifferentName',
    desc: 'One of two messages with the same contents, but different names');

String differentNameSameContents() => Intl.message('Hello World',
    name: 'differentNameSameContents',
    desc: 'One of two messages with the same contents, but different names');

/// Distinguish two messages with identical text using the meaning parameter.
String rentToBePaid() => Intl.message('rent',
    name: 'rentToBePaid',
    meaning: 'Money for rent',
    desc: 'Money to be paid for rent');

String rentAsVerb() => Intl.message('rent',
    name: 'rentAsVerb',
    meaning: 'rent as a verb',
    desc: 'The action of renting, as in rent a car');

String literalDollar() => Intl.message('Five cents is US\$0.05',
    name: 'literalDollar', desc: 'Literal dollar sign with valid number');

/// Messages for testing the skip flag.
String extractable() => Intl.message('This message should be extractable',
    name: 'extractable', skip: false, desc: 'Not skipped message');

String skipMessage() => Intl.message('This message should skip extraction',
    skip: true, desc: 'Skipped message');

String skipPlural(num n) => Intl.plural(n,
    zero: 'Extraction skipped plural none',
    one: 'Extraction skipped plural one',
    other: 'Extraction skipped plural some',
    name: 'skipPlural',
    desc: 'A skipped plural',
    args: [n],
    skip: true);

String skipGender(String g) => Intl.gender(g,
    male: 'Extraction skipped gender m',
    female: 'Extraction skipped gender f',
    other: 'Extraction skipped gender o',
    name: 'skipGender',
    desc: 'A skipped gender',
    args: [g],
    skip: true);

String skipSelect(String name) => Intl.select(
    name,
    {
      'Bob': 'Extraction skipped select specified Bob!',
      'other': 'Extraction skipped select other $name'
    },
    name: 'skipSelect',
    desc: 'Skipped select',
    args: [name],
    skip: true);

String skipMessageExistingTranslation() =>
    Intl.message('This message should skip translation',
        name: 'skipMessageExistingTranslation',
        skip: true,
        desc: 'Skip with existing translation');

void printStuff(Intl locale) {
  // Use a name that's not a literal so this will get skipped. Then we have
  // a name that's not in the original but we include it in the French
  // translation. Because it's not in the original it shouldn't get included
  // in the generated catalog and shouldn't get translated.
  if (locale.locale == 'fr') {
    var badName = 'thisNameIsNotInTheOriginal';
    var notInOriginal = Intl.message('foo', name: badName);
    if (notInOriginal != 'foo') {
      throw "You shouldn't be able to introduce a new message in a translation";
    }
  }

  // A function that is assigned to a variable. It's also nested
  // within another function definition.
  String message3(a, b, c) => Intl.message(
      'Characters that need escaping, e.g slashes \\ dollars \${ (curly braces '
      'are ok) and xml reserved characters <& and quotes " '
      'parameters $a, $b, and $c',
      desc: 'Lots of escapes',
      name: 'message3',
      args: [a, b, c]);
  var messageVariable = message3;

  printOut('-------------------------------------------');
  printOut('Printing messages for ${locale.locale}');
  Intl.withLocale(locale.locale, () {
    printOut(message1());
    printOut(message2('hello'));
    printOut(messageVariable(1, 2, 3));
    printOut(multiLine());
    printOut(types(1, 'b', ['c', 'd']));
    printOut(leadingQuotes);
    printOut(alwaysTranslated());
    printOut(trickyInterpolation('this'));
    var thing = YouveGotMessages();
    printOut(thing.method());
    printOut(thing.nonLambda());
    printOut(YouveGotMessages.staticMessage());
    printOut(notAlwaysTranslated());
    printOut(originalNotInBMP());
    printOut(escapable());

    printOut(thing.plurals(0));
    printOut(thing.plurals(1));
    printOut(thing.plurals(2));
    printOut(thing.plurals(3));
    printOut(thing.plurals(4));
    printOut(thing.plurals(5));
    printOut(thing.plurals(6));
    printOut(thing.plurals(7));
    printOut(thing.plurals(8));
    printOut(thing.plurals(9));
    printOut(thing.plurals(10));
    printOut(thing.plurals(11));
    printOut(thing.plurals(20));
    printOut(thing.plurals(100));
    printOut(thing.plurals(101));
    printOut(thing.plurals(100000));
    var alice = Person('Alice', 'female');
    var bob = Person('Bob', 'male');
    var cat = Person('cat', null);
    printOut(thing.whereTheyWent(alice, 'house'));
    printOut(thing.whereTheyWent(bob, 'house'));
    printOut(thing.whereTheyWent(cat, 'litter box'));
    printOut(thing.nested([alice, bob], 'magasin'));
    printOut(thing.nested([alice], 'magasin'));
    printOut(thing.nested([], 'magasin'));
    printOut(thing.nested([bob, bob], 'magasin'));
    printOut(thing.nested([alice, alice], 'magasin'));

    printOut(outerPlural(0));
    printOut(outerPlural(1));
    printOut(outerGender('male'));
    printOut(outerGender('female'));
    printOut(nestedOuter(7, 'male'));
    printOut(outerSelect('CDN', 7));
    printOut(outerSelect('EUR', 5));
    printOut(nestedSelect('CDN', 1));
    printOut(nestedSelect('CDN', 2));
    printOut(pluralThatFailsParsing(1));
    printOut(pluralThatFailsParsing(2));
    printOut(differentNameSameContents());
    printOut(sameContentsDifferentName());
    printOut(rentAsVerb());
    printOut(rentToBePaid());
    printOut(literalDollar());
    printOut(interestingCharactersNoName);

    printOut(extractable());
    printOut(skipMessage());
    printOut(skipPlural(1));
    printOut(skipGender('female'));
    printOut(skipSelect('Bob'));
    printOut(skipMessageExistingTranslation());
  });
}

String localeToUse = 'en_US';

Future<List> main() {
  var fr = Intl('fr');
  var english = Intl('en_US');
  var de = Intl('de_DE');
  // Throw in an initialize of a null locale to make sure it doesn't throw.
  initializeMessages(null);

  // Verify that a translated message isn't initially present.
  var messageInGerman = Intl.withLocale('de_DE', message1);
  if (messageInGerman != 'This is a message') {
    throw AssertionError('Translation error');
  }

  var f1 = initializeMessages(fr.locale)
      // Since English has the one message which is always translated, we
      // can't print it until French is ready.
      .then((_) => printStuff(english))
      .then((_) => printStuff(fr));
  var f2 = initializeMessages('de-de').then((_) => printStuff(de));
  return Future.wait(<Future>[f1, f2]);
}
