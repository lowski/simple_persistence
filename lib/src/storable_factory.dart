library simple_persistence;

import 'dart:convert';

import 'reserved_tokens.dart';
import 'storable.dart';

typedef StorableDeserializer<T extends Storable> = T Function(
  Map<String, dynamic> mapRepresentation,
);

/// A factory for deserializing [Storable] objects.
class StorableFactory {
  final Map<Type, StorableDeserializer> _deserializers = {};
  final Map<String, Type> _types = {};

  void registerDeserializer<T extends Storable>(
    StorableDeserializer<T> deserializer, {
    String? typeId,
  }) {
    _deserializers[T] = deserializer;
    typeId ??= T.hashCode.toString();
    _types[typeId] = T;
  }

  T deserialize<T extends Storable>(String serialized) {
    final map = Map<String, dynamic>.from(
        jsonDecode(serialized) as Map<String, dynamic>);
    return deserializeMapRepresentation(map);
  }

  T deserializeMapRepresentation<T extends Storable>(Map<String, dynamic> map) {
    final typeId = map[ReservedTokens.type] as String;
    final type = _types[typeId];
    if (type == null) {
      throw UnsupportedError(
        'The type with id $typeId is not registered and can not be deserialized to a $T.',
      );
    }
    if (T != Storable && type != T) {
      throw UnsupportedError(
        'The type with id $typeId is registered as a ${type.toString()} and can not be deserialized to a $T.',
      );
    }
    final deserializer = _deserializers[type];
    if (deserializer == null) {
      throw UnsupportedError(
        'The type with id $typeId is not registered and can not be deserialized to a $T.',
      );
    }
    for (final entry in map.entries) {
      if (entry.value is Map<String, dynamic> &&
          entry.value.containsKey(ReservedTokens.type)) {
        map[entry.key] = deserializeMapRepresentation(entry.value);
      }
    }

    final storable = deserializer(map) as T;
    // ignore: invalid_use_of_protected_member
    storable.id = map[ReservedTokens.id];
    return storable;
  }
}
