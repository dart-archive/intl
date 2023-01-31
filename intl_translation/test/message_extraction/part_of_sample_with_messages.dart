// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.part of sample;

part of sample;

class Person {
  String name;
  String? gender;
  Person(this.name, this.gender);
}

class YouveGotMessages {
  // A static message, rather than a standalone function.
  static String staticMessage() =>
      Intl.message('This comes from a static method',
          name: 'staticMessage', desc: 'Static');

  // An instance method, rather than a standalone function.
  String method() => Intl.message('This comes from a method',
      name: 'YouveGotMessages_method',
      desc: 'This is a method with a '
          'long description which spans '
          'multiple lines.');

  // A non-lambda, i.e. not using => syntax, and with an additional statement
  // before the Intl.message call.
  String nonLambda() {
    var aTrueValue = true;
    var msg = Intl.message('This method is not a lambda',
        name: 'nonLambda', desc: 'Not a lambda');
    if (aTrueValue) {
      var s = 'Parser should not fail with additional code.';
      s.toString();
    }
    return msg;
  }

  String plurals(num num) => Intl.message(
      """${Intl.plural(
        num,
        zero: 'Is zero plural?',
        one: 'This is singular.',
        other: 'This is plural ($num).',
      )}""",
      name: 'plurals',
      args: [num],
      desc: 'Basic plurals');

  dynamic whereTheyWent(Person person, String place) =>
      whereTheyWentMessage(person.name, person.gender ?? 'other', place);

  String whereTheyWentMessage(String name, String gender, String place) {
    return Intl.message(
        "${Intl.gender(
          gender,
          male: '$name went to his $place',
          female: '$name went to her $place',
          other: '$name went to its $place',
        )}",
        name: 'whereTheyWentMessage',
        args: [name, gender, place],
        desc: 'A person went to some place that they own, e.g. their room');
  }

  // English doesn't do enough with genders, so this example is French.
  String nested(List people, String place) {
    var names = people.map((x) => x.name).join(', ');
    var number = people.length;
    var combinedGender =
        people.every((x) => x.gender == 'female') ? 'female' : 'other';
    if (number == 0) combinedGender = 'other';

    String nestedMessage(names, number, combinedGender, place) => Intl.message(
        '''${Intl.gender(
          combinedGender,
          other: '${Intl.plural(
            number,
            zero: "Personne n'est allé au $place",
            one: "$names est allé au $place",
            other: "$names sont allés au $place",
          )}',
          female: '${Intl.plural(
            number,
            one: "$names est allée au $place",
            other: "$names sont allées au $place",
          )}',
        )}''',
        desc: 'Nested message example',
        name: 'nestedMessage',
        args: [names, number, combinedGender, place]);
    return nestedMessage(names, number, combinedGender, place);
  }
}
