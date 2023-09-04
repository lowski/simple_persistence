import 'package:simple_persistence/simple_persistence.dart';
import 'package:test/test.dart';

import 'src/mock_storables.dart';

void main() {
  group('StorableId', () {
    test('is empty by default', () {
      final user = UserStorable(name: 'John Doe');
      expect(user.id, StorableId.empty);
    });
    test('is settable', () {
      final user = UserStorable(name: 'John Doe');

      user.id = StorableId('123');
      expect(user.id, StorableId('123'));
    });

    test('is settable to generate', () {
      final user = UserStorable(name: 'John Doe');

      user.id = StorableId.uuid();
      expect(user.id, isNot(equals(StorableId.empty)));
      expect(user.id.isSet, true);
    });

    test('will not be overridden after being set', () {
      final user = UserStorable(name: 'John Doe');

      final id = StorableId.uuid();
      user.id = id;
      expect(user.id, id);
      user.id = StorableId.uuid();
      expect(user.id, id);
    });
  });
}
