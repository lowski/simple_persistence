import 'dart:io';

import 'package:test/test.dart';

dynamic _getNested(Map map, String key) {
  String k = '';
  if (!key.contains('.')) {
    return map[key];
  }
  for (final segment in key.split('.')) {
    k += segment;
    if (map.containsKey(k)) {
      if (k.length == key.length) {
        return map[k];
      }
      if (k.length < key.length && map[k] is Map) {
        final rest = key.substring(k.length + 1);
        return _getNested(map[k], rest);
      } else {
        return null;
      }
    }
    k += '.';
  }
  return map[key];
}

bool _containsNestedKey(Map map, String key) {
  String k = '';
  if (!key.contains('.')) {
    return map.containsKey(key);
  }
  for (final segment in key.split('.')) {
    k += segment;
    if (map.containsKey(k)) {
      if (k.length == key.length) {
        return true;
      }
      if (k.length < key.length && map[k] is Map) {
        final rest = key.substring(k.length + 1);
        return _containsNestedKey(map[k], rest);
      } else {
        return false;
      }
    }
    k += '.';
  }
  return map.containsKey(key);
}

extension MapExpectExtension on Map {
  expectKeyExists(dynamic key) => expect(containsNestedKey(key), true);
  expectKV(dynamic key, dynamic matcher) => expect(getNested(key), matcher);

  dynamic getNested(String key) => _getNested(this, key);
  bool containsNestedKey(String key) => _containsNestedKey(this, key);
}

Directory getTempDir() {
  final dir = Directory.systemTemp.createTempSync('simple_persistence_test');
  addTearDown(() {
    dir.deleteSync(recursive: true);
  });
  return dir;
}
