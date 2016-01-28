#!/bin/bash
#
# This test is just trying to verify that the transformer runs,
# so we generate the translated messages once and just use them.
# If the transformer successfully invokes them then we're good.
#
# To regenerate the code you can run the lines in this script,
# although translation_zz.arb must be manually created.
dart ../../bin/extract_to_arb.dart --transformer main.dart
# manually edit to create translation_zz.arb
dart ../../bin/generate_from_arb.dart translation_zz.arb transformer_test.dart
