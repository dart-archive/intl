## 0.18.1-dev
  * Update analyzer dependency to `5.2.0`.
  * Address analyzer deprecations.
  * Require Dart 2.18.

## 0.18.0
  * Add support for Flutter locale split.
  * Allow null safe code when parsing.
  * Update analyzer dependency.
  * Upgrade to `package:lints/recommended.yaml`.
  * Initial null safety conversion.
  * Remove petit_parser dependency.
  * Address analyzer deprecations, see [#168](https://github.com/dart-lang/intl_translation/issues/168).
  * Migrate to null safety.
  
## 0.17.10+1
  * Generate code that passes analysis with `implicit-casts: false`.
  * Allow use of `MessageExtraction` and `MessageGeneration` without `File`.
  * Move arb generation from bin to lib so it's available to external packages.
  * Update analyzer dependency.

## 0.17.10
  * Update petitparser dependency.

## 0.17.9
  * Fix pub complaint trying to precompile a library file in bin by moving that file to lib/src.

## 0.17.8
  * Add --sources-list-files and --translations-list-file to ARB handling
    utilities to read the input names from files. This is useful for large
    numbers of inputs.

## 0.17.7
  * Fixed the pubspec to allow intl version 0.16.*

## 0.17.6
  * Strip indentation from generated JSON output to improve codesize.
  * Make generated code not trigger most lints, either by fixing issues
    or by using lots of ignore_for_file directives.
  * Added --with-source-text option to include the source text in the extracted
    ARB metadata.

## 0.17.5
  * Allow multiple ARB files with the same locale and combine
    their translations.
  * Update analyzer constraints and stop using deprecated elements2 API.

## 0.17.4
  * Adds --suppress-meta-data on ARB extraction.
  * Allow Dart enums in an Intl.select call. The map of cases
    can either take enums directly, or the short string name
    of the enum.
  * Handles triple quotes in a translation properly when
    generating messages as JSON.

## 0.17.3
  * Make require_description also fail for empty strings.
  * Update analyzer dependency.

## 0.17.2
  * Changes to support new mixin syntax.

## 0.17.1
  * Added --suppress-last-modified flag to suppress output of the
    @@last_modified entry in output file.
  * Add a "package" field in MessageGeneration that can be useful for emitting
    additional information about e.g. which locales are available and which
    package we're generating for. Also makes libraryName public.
  * Silence unnecessary_new lint warnings in generated code.
  * Add --require_description command line option to message extraction.

## 0.17.0
  * Fully move to Dart 2.0
  * Delete the transformer and related code.
  * Minor update to analyzer API.
  * Update pubspec version requirements

## 0.16.8
  * Allow message extraction to find messages from prefixed uses of Intl.
  * Move analyzer dependency up to 0.33.0

## 0.16.7
  * Allow message extraction to find messages in class field declarations
    and top-level declarations.
  * Fix incorrect name and parameters propagation during extraction phase.
  * Still more uppercase constant removal.

## 0.16.6
  * More uppercase constant removal.

## 0.16.5
  * Replace uses of JSON constant for Dart 2 compatibility.

## 0.16.4
  * Update Intl compatibility requirements. This requires at least 0.15.3 of
    Intl, because the tests contain messages with the new "skip" parameter.

## 0.16.3
  * Fix https://github.com/flutter/flutter/issues/15458 - specify concrete type
    for generated map.

## 0.16.2
 * Handle fallback better when we provide translations for locale "xx" but
   initialize "xx_YY", initializing "xx". Previously we would do nothing.
 * Skip extracting messages that pass the 'skip' argument to Intl calls.
 * Move analyzer dependency up to 0.32.0

## 0.16.1
 * Add @@last_modified to extracted ARB files.
 * Handle @@locale in translated ARB files properly, and adds a --locale
   parameter to specify the locale.
 * Adds a --output-file parameter to extract_to_arb
 * Indent the output file for ARB for better readability.
 * A couple of tweaks to satisfy Flutter's default linter rules when run on the
   generated code.

## 0.16.0
  * BREAKING CHANGE: Require that the examples to message/plural/gender/select
    calls be const. DDC does not optimize non-const maps well, so it's a
    significant performance issue if these are non-const.
  * Added a utility to convert examples in calls to be const. See
    bin/make_examples_const.dart
  * Add a codegen_mode flag, which can be either release or debug. In release
    mode a missing translation throws an exception, in debug mode it returns the
    original text, which was the previous behavior.
  * Add support for generating translated messages as JSON rather than
    methods. This can significantly improve dart2js compile times for
    applications with many translations. The JSON is a literal string in the
    deferred library, so usage doesn't change at all.

## 0.15.0
  * Change non-transformer message rewriting to preserve the original message as
    much as possible. Adds --useStringSubstitution command-line arg.
  * Change non-transformer message rewriting to allow multiple input files to be
    specified on the command line. Adds --replace flag to ignore --output option
    and just replace files.
  * Make non-transformer message rewriting also run dartfmt on the output.
  * Make message extraction more robust: error message instead of stack trace
    when an Intl call is made outside a method, when a prefixed expression is
    used in an interpolation, and when a non-required example Map is not a
    literal.
  * Make message extraction more robust: if parsing triggers an exception then
    report it as an error instead of exiting.
  * Move barback to being a normal rather than a dev dependency.
  * Add a check for invalid select keywords.
  * Added a post-message construction validate, moved
    IntlMessageExtractionException into intl_message.dart
  * Make use of analyzer's new AstFactory class (requires analyzer version
    0.29.1).
  * Fix error in transformer, pass the path instead of the asset id.
  * Prefer an explicit =0/=1/=2 to a ZERO/ONE/TWO if both are present. We don't
    distinguish the two as Intl.message arguments, we just have the "one"
    parameter, which we confusingly write out as =1. Tools interpret these
    differently, and in particular, a ONE clause is used for the zero case if
    there's no explicit zero. Translation tools may implement this by filling in
    both ZERO and ONE values with the OTHER clause when there's no ZERO
    provided, resulting in a translation with both =1 and ONE clauses which are
    different. We should prefer the explicit =1 in that case. In future we may
    distinguish the different forms, but that would probably break existing
    translations.
  * Switch to using package:test
  * Give a more specific type in the generated code to keep lints happy.

## 0.14.0
  * Split message extraction and code generation out into a separate
    package. Versioned to match the corresponding Intl version.
