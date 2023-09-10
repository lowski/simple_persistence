library simple_persistence;

import 'dart:convert';

import 'persistence_manager.dart';
import 'reserved_tokens.dart';
import 'storable.dart';

typedef StorableDeserializer<T extends Storable> = T Function(
  Map<String, dynamic> mapRepresentation,
);

/// A factory for deserializing [Storable] objects.
class StorableFactory {
  static final _instance = StorableFactory._();

  /// Get the [StorableFactory] instance.
  static StorableFactory get I => _instance;

  StorableFactory._();

  T deserialize<T extends Storable>(String serialized) {
    final map = Map<String, dynamic>.from(
        jsonDecode(serialized) as Map<String, dynamic>);
    return deserializeMapRepresentation(map);
  }

  T deserializeMapRepresentation<T extends Storable>(Map<String, dynamic> map) {
    final typeId = map[ReservedTokens.type] as String;
    // ignore: invalid_use_of_protected_member
    final deserializer = PersistenceManager.I.getDeserializer(typeId);

    for (final entry in map.entries) {
      if (entry.value is Map<String, dynamic> &&
          entry.value.containsKey(ReservedTokens.type)) {
        map[entry.key] = deserializeMapRepresentation(entry.value);
      }
    }

    final storable = deserializer(map);

    // check if the deserializer returned the correct type
    if (T != Storable && storable is! T) {
      throw UnsupportedError(
        'The type with id $typeId was deserialized to ${storable.runtimeType} but $T was expected.',
      );
    }

    storable.id = map[ReservedTokens.id];
    return storable as T;
  }
}
