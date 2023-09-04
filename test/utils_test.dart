import 'package:test/test.dart';

import 'src/utils.dart';

void main() {
  group('utils.getNested()', () {
    final map = {
      'a': {
        'b': {
          'c': 'd',
        },
      },
    };

    test('returns null for non-existing key', () {
      expect(map.getNested('x'), null);
    });
    test('returns value for existing key', () {
      expect(map.getNested('a'), map['a']);
    });
    test('returns value for nested key', () {
      expect(map.getNested('a.b.c'), 'd');
    });
    test('returns null for nested non-existing key', () {
      expect(map.getNested('a.b.x'), null);
    });
    test('returns null for nested key with non-map value', () {
      expect(map.getNested('a.b.c.d'), null);
    });
    test('returns null for nested key with trailing dot', () {
      expect(map.getNested('a.b.'), null);
    });
  });
}
