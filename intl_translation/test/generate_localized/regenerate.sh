#!/bin/sh
# Regenerate the messages Dart files.
dart ../../bin/generate_from_arb.dart \
  --code-map --generated-file-prefix=code_map_ \
  code_map_test.dart app_translation_getfromthelocale.arb \
  --null-safety
