library simple_persistence;

import 'dart:math';

/// Generate a random UUID v4 without using external dependencies.
String uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replaceAllMapped(
    RegExp(r'[xy]'),
    (match) {
      final random = (Random().nextDouble() * 16).floor();
      final value = match.group(0);
      return (value == 'x' ? random : (random & 0x3 | 0x8)).toRadixString(16);
    },
  );
}
