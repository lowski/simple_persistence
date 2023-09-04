import 'package:simple_persistence/src/reserved_tokens.dart';
import 'package:simple_persistence/src/utils.dart';
import 'package:test/test.dart';

import 'src/mock_storables.dart';

void main() {
  group('StorableId', () {
    test('is empty by default', () {
      final user = UserStorable(name: 'John Doe');
      expect(user.id, ReservedTokens.emptyIdValue);
    });
    test('is settable', () {
      final user = UserStorable(name: 'John Doe');

      user.id = '123';
      expect(user.id, '123');
    });

    test('is settable to generate', () {
      final user = UserStorable(name: 'John Doe');

      user.id = uuidv4();
      expect(user.id, isNot(equals(ReservedTokens.emptyIdValue)));
      expect(user.hasId, true);
    });

    test('will not be overridden after being set', () {
      final user = UserStorable(name: 'John Doe');

      final id = uuidv4();
      user.id = id;
      expect(user.id, id);
      user.id = uuidv4();
      expect(user.id, id);
    });
  });
}
