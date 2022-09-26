import 'dart:math';

// Import BenchmarkBase class.
import 'package:benchmark_harness/benchmark_harness.dart';

const int asciiZeroCodeUnit = 2;
const int listlength = 10000;

// Create a new benchmark by extending BenchmarkBase
class NewMethod extends BenchmarkBase {
  late String string;
  late String string2;
  int zeroDigit = 15;
  NewMethod() : super('New');

  static void main() {
    NewMethod().report();
  }

  @override
  void setup() => string = String.fromCharCodes(Iterable.generate(
        listlength,
        (index) => Random().nextInt(80) + zeroDigit,
      ));
  // The benchmark code.
  @override
  void run() {
    var codeUnits = string.codeUnits;
    string2 = String.fromCharCodes(List.generate(
      codeUnits.length,
      (index) => codeUnits[index] - zeroDigit + asciiZeroCodeUnit,
      growable: false,
    ));

    // var codeUnits = string.codeUnits;
    // string2 = String.fromCharCodes(codeUnits
    //     .map((c) => c - zeroDigit + asciiZeroCodeUnit)
    //     .toList(growable: false));
  }
}

// Create a new benchmark by extending BenchmarkBase
class OldMethod extends BenchmarkBase {
  late String string;
  late String string2;
  int zeroDigit = 15;
  OldMethod() : super('Old');

  static void main() {
    OldMethod().report();
  }

  @override
  void setup() => string = String.fromCharCodes(Iterable.generate(
        listlength,
        (index) => Random().nextInt(80) + zeroDigit,
      ));
  // The benchmark code.
  @override
  void run() {
    var oldDigits = string.codeUnits;
    var newDigits = List<int>.filled(string.length, 0);
    for (var i = 0; i < string.length; i++) {
      newDigits[i] = oldDigits[i] - zeroDigit + asciiZeroCodeUnit;
    }
    string2 = String.fromCharCodes(newDigits);
  }
}

void main() {
  // Run TemplateBenchmark
  print("Old");
  OldMethod.main();
  // Run TemplateBenchmark
  print("New");
  NewMethod.main();
}
