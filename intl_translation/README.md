[![Dart](https://github.com/dart-lang/intl_translation/actions/workflows/build.yaml/badge.svg)](https://github.com/dart-lang/intl_translation/actions/workflows/build.yaml)
[![Pub](https://img.shields.io/pub/v/intl_translation.svg)](https://pub.dev/packages/intl_translation)

Provides message extraction and code generation from translated messages for the
[intl][intl] package. It's a separate package so as to not require a dependency
on analyzer for all users.

## Extracting And Using Translated Messages

When your program contains messages that need translation, these must be
extracted from the program source, sent to human translators, and the results
need to be incorporated.

To extract messages, run the `extract_to_arb.dart` program.

```
dart run intl_translation:extract_to_arb --output-dir=target/directory \
    my_program.dart more_of_my_program.dart
```

This supports wildcards. For example, to extract messages from a series of files in path `lib/**/*.dart`, you can run
```dart
dart run intl_translation:extract_to_arb --output-dir=target/directory
      lib/**/*.dart
```

This will produce a file `intl_messages.arb` with the messages from all of these
programs. This is an [ARB][arb] format file which can be used for input to
translation tools like [Localizely][localizely]. The resulting translations can
be used to generate a set of libraries using the `generate_from_arb.dart`
program.

This expects to receive a series of files, one per locale.

```
dart run intl_translation:generate_from_arb --generated-file-prefix=<prefix> \
    <my_dart_files> <translated_ARB_files>
```

This will generate Dart libraries, one per locale, which contain the translated
versions. Your Dart libraries can import the primary file, named
`<prefix>messages_all.dart`, and then call the initialization for a specific
locale. Once that's done, any [Intl.message][intl.message] calls made in the
context of that locale will automatically print the translated version instead
of the original.

```dart
import "my_prefix_messages_all.dart";
...
initializeMessages("dk").then(printSomeMessages);
```

Once the `Future` returned from the initialization call completes, the message
data is available.

[intl]: https://pub.dev/packages/intl
[intl.message]: https://pub.dev/documentation/intl/latest/intl/Intl/message.html
[arb]:
  https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification
[localizely]: https://localizely.com/
