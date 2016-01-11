## 0.12.6
  * Update links in README.md to point to current dartdocs.
  * Update locale data to CLDR 28.
  * Remove library directive from generated libraries. Conflicted with linter.
  * Support @@locale in ARB files as well as the older _locale
  * Print a message when generating from ARB files if we guess the locale
    from the file name when there's no explicit @@locale or _locale in the file.

## 0.12.5
  * Parse Eras in DateFormat.
  * Update pubspec.yaml to allow newer version of fixnum and analyzer.
  * Improvements to the compiled size of generated messages code with dart2js.
  * Allow adjacent literal strings to be used for message names/descriptions.
  * Provide a better error message for some cases of bad parameters
    to plural/gender/select messages.
  * Introduce a simple MicroMoney class that can represent currency values
    scaled by a constant factor.

## 0.12.4+3
  * update analyzer to '<0.28.0' and fixnum to '<0.11.0'

## 0.12.4+2
  * update analyzer to '<0.27.0'

## 0.12.4+1
  * Allow the name of an Intl.message to be "ClassName_methodName", as
    well as "functionName". This makes it easier to disambiguate
    messages with the same name but in different classes.

## 0.12.4
  * Handle spaces in ARB files where we didn't handle them before, and
  where Google translation toolkit is now putting them.

## 0.12.3

  * Use latest version of 'analyzer' and 'args' packages.

## 0.12.2+1
  * Adds a special locale name "fallback" in verifiedLocale. So if a translation
  is provided for that locale and has been initialized, anything that doesn't
  find a closer match will use that locale. This can be used instead of having
  it default to the text in the original source messages.

## 0.12.1
  * Adds a DateFormat.parseLoose that accepts mixed case and missing
  delimiters when parsing dates. It also allows arbitrary amounts of
  whitespace anywhere that whitespace is expected. So, for example,
  in en-US locale a yMMMd format would accept "SEP 3   2014", even
  though it would generate "Sep 3, 2014". This is fairly limited, and
  its reliability in other locales is not known.

## 0.12.0+3
  * Update pubspec dependencies to allow analyzer version 23.

## 0.12.0+2
  * No user impacting changes. Tighten up a couple method signatures to specify
  that int is required.

## 0.12.0+1
  * Fixes bug with printing a percent or permille format with no fraction
  part and a number with no integer part. For example, print 0.12 with a
  format pattern of "#%". The test for whether
  there was a printable integer part tested the basic number, so it ignored the
  integer digits. This was introduced in 0.11.2 when we stopped multiplying
  the input number in the percent/permille case.

## 0.12.0
  * Make withLocale and defaultLocale use a zone, so async operations
    inside withLocale also get the correct locale. Bumping the version
    as this might be considered breaking, or at least
    behavior-changing.

## 0.11.12
  * Number formatting now accepts "int-like" inputs that don't have to
    conform to the num interface. In particular, you can now pass an Int64
    from the fixnum package and format it. In addition, this no longer
    multiplies the result, so it won't lose precision on a few additional
    cases in JS.

## 0.11.11
  * Add a -no-embedded-plurals flag to reject plurals and genders that
    have either leading or trailing text around them. This follows the
    ICU recommendation that a plural or gender should contain the
    entire phrase/sentence, not just part of it.

## 0.11.10
  * Fix some style glitches with naming. The only publicly visible one
    is DateFormat.parseUtc, but the parseUTC variant is still retained
    for backward-compatibility.

  * Provide a better error message when generating translated versions
    and the name of a variable substitution in the message doesn't
    match the name in the translation.

## 0.11.9
  * Fix bug with per-mille parsing (only divided by 100, not 1000)

  * Support percent and per-mille formats with both positive and negative
    variations. Previously would throw an exception for too many modifiers.

## 0.11.8

  * Support NumberFormats with two different grouping sizes, e.g.
    1,23,45,67,890

## 0.11.7
  * Moved petitparser into a regular dependency so pub run works.

  * Improved code layout of the package.

  * Added a DateFormat.parseStrict method that rejects DateTimes with invalid
    values and requires it to be the whole string.

## 0.11.6

  * Catch analyzer errors and do not generate messages for that file. Previously
    this would stop the message extraction on syntax errors and not give error
    messages as good as the compiler would produce. Just let the compiler do it.

## 0.11.5

 * Change to work with both petitparser 1.1.x and 1.2.x versions.

## 0.11.4

 * Broaden the pubspec constraints to allow current analyzer versions.

## 0.11.3

 * Add a --[no]-use-deferred-loading flag to generate_from_arb.dart and
   generally make the deferred loading of message libraries optional.

## 0.11.2

 * Missed canonicalization of locales in one place in message library generation.

 * Added a simple debug script for message_extraction_test.

## 0.11.1

 * Negative numbers were being parsed as positive.

## 0.11.0

 * Switch the message format from a custom JSON format to
   the ARB format ( https://code.google.com/p/arb/ )

## 0.10.0

 * Make message catalogs use deferred loading.

 * Update CLDR Data to version 25 for dates and numbers.

 * Update analyzer dependency to allow later versions.

 * Adds workaround for flakiness in DateTime creation, removes debugging code
   associated with that.

## 0.9.9

* Add NumberFormat.parse()

* Allow NumberFormat constructor to take an optional currency name/symbol, so
  you can format for a particular locale without it dictating the currency, and
  also supply the currency symbols which we don't have yet.

* Canonicalize locales more consistently, avoiding a number of problems if you
  use a non-canonical form.

* For locales whose length is longer than 6 change "-" to "_" in position 3 when
  canonicalizing. Previously anything of length > 6 was left completely alone.

## 0.9.8

* Add a "meaning" optional parameter for Intl.message to distinguish between
  two messages with identical text.

* Handle two different messages with the same text.

* Allow complex string literals in arguments (e.g. multi-line)
