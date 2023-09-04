import 'package:simple_persistence/simple_persistence.dart';
import 'package:test/test.dart';

import 'src/mock_storables.dart';
import 'src/utils.dart';

void testStoreImplementation(
  Type storeType,
  Store<T> Function<T extends Storable>(StorableFactory sf, String path) create,
) {
  group(storeType.toString(), () {
    late Store<UserStorable> userStore;
    late StorableFactory sf;
    late String path;

    test('loads without errors', () async {
      final store = create<UserStorable>(StorableFactory(), path);
      await store.loaded;
    });

    setUp(() async {
      sf = StorableFactory();
      sf.registerDeserializer(UserStorable.fromMap);
      sf.registerDeserializer(PostStorable.fromMap);

      path = getTempDir().path;

      userStore = create(sf, path);
      await userStore.loaded;
    });

    test('get() returns null if nothing exists', () {
      expect(userStore.get('123'), isNull);
    });

    test('save() sets id', () {
      var user = UserStorable(name: 'John Doe');
      user = userStore.save(user);

      expect(user.id, isNotNull);
      expect(user.id.isSet, true);
    });

    test('save() returns stored value', () async {
      final user = UserStorable(name: 'John Doe');
      user.id = StorableId('123');
      userStore.save(user);

      expect(userStore.get('123'), user);
    });

    test('get() returns null after delete', () {
      final user = UserStorable(name: 'John Doe');
      user.id = StorableId('123');

      userStore.save(user);
      userStore.delete('123');

      expect(userStore.get('123'), isNull);
    });

    test('listen() emits null if nothing exists', () {
      final stream = userStore.listen('123');
      expect(stream, emits(null));
    });

    test('listen() emits stored value', () async {
      final user = UserStorable(name: 'John Doe');
      user.id = StorableId('123');
      userStore.save(user);

      expect(userStore.listen('123'), emits(user));
    });

    test('listen() emits same value as get', () {
      final user = UserStorable(name: 'John Doe');
      user.id = StorableId('123');
      userStore.save(user);

      expect(userStore.listen('123'), emits(userStore.get('123')));
    });

    test('listen() emits updated value', () async {
      final user = UserStorable(name: 'John Doe')..id = StorableId('123');
      final userCopy = user.copyWith(name: 'Jane Doe');

      expect(userStore.listen('123'), emitsInOrder([null, user, userCopy]));

      userStore.save(user);
      userStore.save(userCopy);
    });

    test('listen() emits null after delete', () async {
      final user = UserStorable(name: 'John Doe');
      user.id = StorableId('123');
      userStore.save(user);

      expect(userStore.listen('123'), emitsInOrder([user, null, emitsDone]));

      userStore.delete('123');
    });

    group('after creating new instance', () {
      final user = UserStorable(name: 'John Doe')..id = StorableId('123');
      test('get() returns correct value', () async {
        userStore.save(user);

        await Future.delayed(Duration(milliseconds: 500));
        final store = create<UserStorable>(sf, path);
        await store.loaded;

        expect(store.get('123'), user);
      });

      test('get() returns null after delete', () async {
        userStore.save(user);
        await Future.delayed(Duration(milliseconds: 500));
        userStore.delete('123');

        await Future.delayed(Duration(milliseconds: 500));
        final store = create<UserStorable>(sf, path);
        await store.loaded;

        expect(store.get('123'), isNull);
      });

      test('listen() emits null after delete', () async {
        userStore.save(user);
        await Future.delayed(Duration(milliseconds: 500));
        userStore.delete('123');

        await Future.delayed(Duration(milliseconds: 500));
        final store = create<UserStorable>(sf, path);
        await store.loaded;

        expect(store.listen('123'), emits(null));
      });
    });
  });
}

void main() {
  group('Store implementation', () {
    testStoreImplementation(
      JsonFileStore,
      <T extends Storable>(sf, path) => JsonFileStore<T>(
        path: '$path/test.json',
        storableFactory: sf,
      ),
    );

    testStoreImplementation(
      BigJsonStore,
      <T extends Storable>(sf, path) {
        return BigJsonStore<T>(
          path: path,
          storableFactory: sf,
        );
      },
    );
  });
}
