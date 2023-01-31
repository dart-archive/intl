## What's this?

This is an example to demonstrate the output from `bin/generate_from_arb.dart`.

You can see the example generated code in `lib/generated`.

Note that the Dart code using the Intl messages - `lib/example_messages.dart` -
is atypical Dart code. It exists just to have references to the `Intl.message`
messages from the lib/messages ARB files, so the generator will output the
cooresponding messages in `lib/generated`.

## Re-generating the example code

- `cd example`
- `make`
