import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:simple_persistence/simple_persistence.dart';
import 'package:test/test.dart';

import 'src/mock_storables.dart';
import 'src/utils.dart';

void main() {
  KVStore create(FutureOr<String> path) => KVStore(
        Future.value(path).then(
          (v) => p.join(v, 'kv_store.json'),
        ),
      );

  group('KVStore', () {
    late KVStore store;
    late String path;

    final key = '123';
    final value = 'abc';
    final value2 = 'abcd';
    final valueStorable = UserStorable(name: 'John Doe');

    setUp(() async {
      PersistenceManager.I.register(UserStorable.fromMap);

      path = getTempDir().path;

      store = create(path);
      await store.loaded;
    });

    test('get() returns null if nothing exists', () {
      expect(store.get('boolean'), isNull);
    });

    test('save() returns stored value', () async {
      store.save(key, value);

      expect(store.get(key), value);
    });

    test('get() returns null after delete', () {
      store.save(key, value);
      store.delete(key);

      expect(store.get(key), isNull);
    });

    test('listen() emits null if nothing exists', () {
      final stream = store.listen(key);
      expect(stream, emits(null));
    });

    test('listen() emits stored value', () async {
      store.save(key, value);

      expect(store.listen(key), emits(value));
    });

    test('listen() emits same value as get', () {
      store.save(key, value);

      expect(store.listen(key), emits(store.get(key)));
    });

    test('listen() emits updated value', () async {
      expect(store.listen(key), emitsInOrder([null, value, value2]));

      store.save(key, value);
      store.save(key, value2);
    });

    test('listen() emits null after delete', () async {
      store.save(key, value);

      expect(store.listen(key), emitsInOrder([value, null, emitsDone]));

      store.delete(key);
    });

    test('save() and get() work with Storable', () async {
      store.save(key, valueStorable);

      expect(store.get<UserStorable>(key), valueStorable);
    });

    group('after creating new instance', () {
      test('save() and get() work with Storable', () async {
        store.save(key, valueStorable);

        await Future.delayed(Duration(milliseconds: 500));
        final store2 = create(path);
        await store2.loaded;

        expect(store.get(key), valueStorable);
      });

      test('get() returns correct value', () async {
        store.save(key, value);

        await Future.delayed(Duration(milliseconds: 500));
        final store2 = create(path);
        await store2.loaded;

        expect(store.get(key), value);
      });

      test('get() returns null after delete', () async {
        store.save(key, value);
        await Future.delayed(Duration(milliseconds: 500));
        store.delete(key);

        await Future.delayed(Duration(milliseconds: 500));
        final store2 = create(path);
        await store2.loaded;

        expect(store2.get(key), isNull);
      });

      test('listen() emits null after delete', () async {
        store.save(key, value);
        await Future.delayed(Duration(milliseconds: 500));
        store.delete(key);

        await Future.delayed(Duration(milliseconds: 500));
        final store2 = create(path);
        await store2.loaded;

        expect(store2.listen(key), emits(null));
      });
    });
  });
}
