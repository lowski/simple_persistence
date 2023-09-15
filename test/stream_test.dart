import 'package:simple_persistence/src/value_stream_controller.dart';
import 'package:test/test.dart';

void main() {
  group('ValueStream', () {
    test('emits initial value', () {
      final stream = ValueStreamController<int>(initialValue: 42);
      expect(stream.value, 42);
      expect(stream.stream, emits(42));

      stream.close();
    });

    test('never emits null if not initiallyNull', () {
      final stream = ValueStreamController<int?>();
      expect(stream.stream, neverEmits(null));
      stream.close();
    });

    test('never emits null if initiallyNull', () {
      final stream = ValueStreamController<int?>(initiallyNull: true);
      expect(stream.stream, emits(null));
      stream.close();
    });

    test('emits value to multiple listeners', () async {
      final stream = ValueStreamController<int>(initialValue: 42);
      expect(stream.stream, emits(42));
      expect(stream.stream, emits(42));

      await Future.microtask(() => null);

      stream.add(43);
      expect(stream.stream, emits(43));
      expect(stream.stream, emits(43));
      stream.close();
    });
  });
}
