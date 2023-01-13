#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
#
# A horribly hacky shell script for updating the Intl data. This doesn't
# fit very nicely with build rules, as we are overwriting source
# files. Assumes that you are running from the google3 directory.
#
# Author: alanknight@google.com (Alan Knight)
set -e

LOCAL_INTL=$(mktemp -d --suffix=_dart_intl)
G3_INTL="third_party/dart/intl"

/bin/mkdir -p "${LOCAL_INTL}/patterns"
/bin/mkdir -p "${LOCAL_INTL}/symbols"

# Generate the Dart source files with the data using the code
# in //i18n/tools. Then we copy them to the appropriate places
# in //third_party/dart/intl, and for the ones that are used in
# generating the JSON data files, also to the local Intl install.
blaze build //i18n/tools:dart_number_test_data
/bin/cp blaze-genfiles/i18n/tools/number_test_data.dart "${G3_INTL}/test"

blaze build //i18n/tools:datetime_pattern_dart
/bin/cp blaze-genfiles/i18n/tools/date_time_patterns.dart "${G3_INTL}/lib"

blaze build //i18n/tools:number_symbols_data_dart
/bin/cp blaze-genfiles/i18n/tools/number_symbols_data.dart "${G3_INTL}/lib"

blaze build //i18n/tools:datetime_constants_dart
/bin/cp blaze-genfiles/i18n/tools/date_symbol_data_local.dart "${G3_INTL}/lib"

blaze build //i18n/tools:dart_compact_number_test_data
/bin/cp blaze-genfiles/i18n/tools/compact_number_test_data.dart "${G3_INTL}/test"

/google/data/ro/teams/dart/bin/dartfmt -w \
    "${G3_INTL}/test/compact_number_test_data.dart" \
    "${G3_INTL}/test/number_test_data.dart" \
    "${G3_INTL}/lib/date_time_patterns.dart" \
    "${G3_INTL}/lib/number_symbols_data.dart" \
    "${G3_INTL}/lib/date_symbol_data_local.dart"

# Run the JSON generation tool in the local Intl version.
blaze run third_party/dart/intl:generate_locale_data_files -- "${LOCAL_INTL}"
/google/data/ro/teams/dart/bin/dartfmt -w "${LOCAL_INTL}/locale_list.dart"

# Copy the results back into google3
/bin/cp -r "${LOCAL_INTL}/patterns" "${G3_INTL}/lib/src/data/dates"
/bin/cp -r "${LOCAL_INTL}/symbols" "${G3_INTL}/lib/src/data/dates"
/bin/cp "${LOCAL_INTL}/locale_list.dart" "${G3_INTL}/lib/src/data/dates"

/bin/rm -rf "${LOCAL_INTL}"

# Generate Plural Rules
blaze run //i18n/tools:generate_dart_pluralrules "$(pwd)/third_party/cldr/common/supplemental/plurals.xml" "$(pwd)/${G3_INTL}/lib/src/data/dates/locale_list.dart" > "${G3_INTL}/lib/src/plural_rules.dart"
dart fix --no-blaze-build --apply "${G3_INTL}/lib/src/plural_rules.dart"
/google/data/ro/teams/dart/bin/dartfmt -w "${G3_INTL}/lib/src/plural_rules.dart"
