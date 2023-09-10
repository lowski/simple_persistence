import 'package:simple_persistence/simple_persistence.dart';
import 'package:test/test.dart';

import 'src/mock_storables.dart';
import 'src/utils.dart';

void main() {
  group('Serialization', () {
    final user = UserStorable(name: 'John Doe');

    final post = PostStorable(
      title: 'Hello World',
      author: user,
    );

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
    test('does not work if deserializer is not registered', () {
      final user = UserStorable(name: 'John Doe');
      final serialized = user.asJson;

      printOnFailure("Serialized UserStorable: ${user.asJson}");

      expect(() => StorableFactory.I.deserialize(serialized),
          throwsUnsupportedError);
    });

    group(null, () {
      setUpAll(() {
        StorableFactory.I.registerDeserializer(UserStorable.fromMap);
        StorableFactory.I.registerDeserializer(PostStorable.fromMap);
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
