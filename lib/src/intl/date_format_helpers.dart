// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of intl;

/// A class for holding onto the data for a date so that it can be built
/// up incrementally.
class _DateBuilder {
  // Default the date values to the EPOCH so that there's a valid date
  // in case the format doesn't set them.
  int year = 1970,
      month = 1,
      day = 1,
      hour = 0,
      minute = 0,
      second = 0,
      fractionalSecond = 0;
  bool pm = false;
  bool utc = false;

  // Functions that exist just to be closurized so we can pass them to a general
  // method.
  void setYear(x) {
    year = x;
  }

  void setMonth(x) {
    month = x;
  }

  void setDay(x) {
    day = x;
  }

  void setHour(x) {
    hour = x;
  }

  void setMinute(x) {
    minute = x;
  }

  void setSecond(x) {
    second = x;
  }

  void setFractionalSecond(x) {
    fractionalSecond = x;
  }

  get hour24 => pm ? hour + 12 : hour;

  /// Verify that we correspond to a valid date. This will reject out of
  /// range values, even if the DateTime constructor would accept them. An
  /// invalid message will result in throwing a [FormatException].
  verify(String s) {
    _verify(month, 1, 12, "month", s);
    _verify(hour24, 0, 23, "hour", s);
    _verify(minute, 0, 59, "minute", s);
    _verify(second, 0, 59, "second", s);
    _verify(fractionalSecond, 0, 999, "fractional second", s);
    // Verifying the day is tricky, because it depends on the month. Create
    // our resulting date and then verify that our values agree with it
    // as an additional verification. And since we're doing that, also
    // check the year, which we otherwise can't verify, and the hours,
    // which will catch cases like "14:00:00 PM".
    var date = asDate();
    _verify(hour24, date.hour, date.hour, "hour", s);
    _verify(day, date.day, date.day, "day", s);
    _verify(year, date.year, date.year, "year", s);
  }

  _verify(int value, int min, int max, String desc, String originalInput) {
    if (value < min || value > max) {
      throw new FormatException(
          "Error parsing $originalInput, invalid $desc value: $value."
          " Expected value between $min and $max.");
    }
  }

  /// Return a date built using our values. If no date portion is set,
  /// use the "Epoch" of January 1, 1970.
  DateTime asDate({retry: true}) {
    // TODO(alanknight): Validate the date, especially for things which
    // can crash the VM, e.g. large month values.
    var result;
    if (utc) {
      result = new DateTime.utc(
          year, month, day, hour24, minute, second, fractionalSecond);
    } else {
      result = new DateTime(
          year, month, day, hour24, minute, second, fractionalSecond);
      // TODO(alanknight): Issue 15560 means non-UTC dates occasionally come
      // out in UTC. If that happens, retry once. This will always happen if
      // the local time zone is UTC, but that's ok.
      if (result.toUtc() == result) {
        result = asDate(retry: false);
      }
    }
    return result;
  }
}

/// A simple and not particularly general stream class to make parsing
/// dates from strings simpler. It is general enough to operate on either
/// lists or strings.
// TODO(alanknight): With the improvements to the collection libraries
// since this was written we might be able to get rid of it entirely
// in favor of e.g. aString.split('') giving us an iterable of one-character
// strings, or else make the implementation trivial. And consider renaming,
// as _Stream is now just confusing with the system Streams.
class _Stream {
  var contents;
  int index = 0;

  _Stream(this.contents);

  bool atEnd() => index >= contents.length;

  next() => contents[index++];

  /// Return the next [howMany] items, or as many as there are remaining.
  /// Advance the stream by that many positions.
  read([int howMany = 1]) {
    var result = peek(howMany);
    index += howMany;
    return result;
  }

  /// Does the input start with the given string, if we start from the
  /// current position.
  bool startsWith(String pattern) {
    if (contents is String) return contents.startsWith(pattern, index);
    return pattern == peek(pattern.length);
  }

  /// Return the next [howMany] items, or as many as there are remaining.
  /// Does not modify the stream position.
  peek([int howMany = 1]) {
    var result;
    if (contents is String) {
      result = contents.substring(index, min(index + howMany, contents.length));
    } else {
      // Assume List
      result = contents.sublist(index, index + howMany);
    }
    return result;
  }

  /// Return the remaining contents of the stream
  rest() => peek(contents.length - index);

  /// Find the index of the first element for which [f] returns true.
  /// Advances the stream to that position.
  int findIndex(Function f) {
    while (!atEnd()) {
      if (f(next())) return index - 1;
    }
    return null;
  }

  /// Find the indexes of all the elements for which [f] returns true.
  /// Leaves the stream positioned at the end.
  List findIndexes(Function f) {
    var results = [];
    while (!atEnd()) {
      if (f(next())) results.add(index - 1);
    }
    return results;
  }

  /// Assuming that the contents are characters, read as many digits as we
  /// can see and then return the corresponding integer. Advance the stream.
  var digitMatcher = new RegExp(r'^\d+');
  int nextInteger() {
    var string = digitMatcher.stringMatch(rest());
    if (string == null || string.isEmpty) return null;
    read(string.length);
    return int.parse(string);
  }
}
