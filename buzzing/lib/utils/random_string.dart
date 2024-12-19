library random_string;

import 'dart:math';

const ASCII_START = 33;
const ASCII_END = 126;
const NUMERIC_START = 48;
const NUMERIC_END = 57;
const LOWOR_ALPHA_START = 97;
const LOWOR_ALPHA_END = 122;
const UPPER_ALPHA_START = 65;
const UPPER_ALPHA_END = 90;

int randomBetween(int from, int to) {
  var rand = Random();
  if (from > to) {
    var t = to;
    from = to;
    to = t;
  }
  return ((to - from) * rand.nextDouble()).toInt() + from;
}

String randomString(int length, {int from = ASCII_START, int to = ASCII_END}) {
  return String.fromCharCodes(
      List.generate(length, (index) => randomBetween(from, to)));
}

String randomNumeric(int length) =>
    randomString(length, from: NUMERIC_START, to: NUMERIC_END);
