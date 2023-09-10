import 'package:simple_persistence/simple_persistence.dart';
import 'package:test/test.dart';

import 'src/mock_storables.dart';
import 'src/utils.dart';

void main() {
  test('PersistenceManager does not work without registration', () {
    expect(
      () {
        final user = UserStorable(name: 'John Doe');
        user.asJson;
      },
      throwsUnsupportedError,
    );
  });

  group('Serialization', () {
    final user = UserStorable(name: 'John Doe');

    final post = PostStorable(
      title: 'Hello World',
      author: user,
    );

    setUpAll(() {
      PersistenceManager.I.register(UserStorable.fromMap);
      PersistenceManager.I.register(PostStorable.fromMap);
    });

    test('map representation on simple object', () {
      user.data.expectKV('name', 'John Doe');

      user.asMap.expectKeyExists('~id');
      user.asMap.expectKeyExists('~type');
      user.asMap.expectKV('name', 'John Doe');
    });

    test('data on nested embedded object', () {
      post.data.expectKV('author', user);
    });

    test('map representation on complex embedded object', () {
      post.asMap.expectKV('author', isA<Map>());
      post.asMap.expectKV('author.name', 'John Doe');
      post.asMap.expectKeyExists('author.~id');
    });
  });

  group('Deserialization', () {
    group(null, () {
      setUpAll(() {
        PersistenceManager.I.register(UserStorable.fromMap);
        PersistenceManager.I.register(PostStorable.fromMap);
      });

      test('creates identical simple object', () {
        final user = UserStorable(name: 'John Doe');
        final serialized = user.asJson;

        printOnFailure("Original UserStorable: ${user.asJson}");

        final deserialized = StorableFactory.I.deserialize(serialized);

        printOnFailure("Deserialized UserStorable: ${deserialized.asJson}");

        expect(deserialized, isA<UserStorable>());
        expect(deserialized, user);
      });

      test('creates identical nested object', () {
        final user = UserStorable(name: 'John Doe');
        final post = PostStorable(
          title: 'Hello World',
          author: user,
        );

        final serialized = post.asJson;

        printOnFailure("Serialized PostStorable: ${post.asJson}");

        final deserialized = StorableFactory.I.deserialize(serialized);

        expect(deserialized, isA<PostStorable>());
        expect(deserialized, post);
      });
    });
  });
}
