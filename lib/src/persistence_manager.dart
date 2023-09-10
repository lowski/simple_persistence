import 'package:meta/meta.dart';

import '../simple_persistence.dart';
import 'utils.dart';

class PersistenceManager {
  // ignore: deprecated_member_use_from_same_package
  static final PersistenceManager _instance = PersistenceManager();

  static PersistenceManager get I => _instance;

  /// Do not instantiate this class directly. Use [PersistenceManager.I]
  /// instead.
  @Deprecated('Use [PersistenceManager.I] instead.')
  PersistenceManager();

  final Map<Type, StorableDeserializer> _deserializers = {};
  final Map<String, Type> _typeIds = {};

  /// Get the [StorableDeserializer] for a given [typeId]. If no [typeId] is
  /// given [T] will be used to find the deserializer.
  @protected
  StorableDeserializer<T> getDeserializer<T extends Storable>(String typeId) {
    final type = _getType(typeId);
    if (!_deserializers.containsKey(type)) {
      throw StateError(
        'No deserializer for type $T registered. Please register a deserializer for $T before using it.',
      );
    }
    return _deserializers[type] as StorableDeserializer<T>;
  }

  /// Register a [StorableDeserializer] for a given [Storable] type.
  ///
  /// This method will also register the type name for the given [Storable]
  /// type. The type name will be the hash of the type name. If you want to
  /// register a custom type name use [registerTypeName]. This is recommended.
  void register<T extends Storable>(
    StorableDeserializer<T> deserializer, {
    String? typeName,
  }) {
    _throwIfTStorable<T>();

    _deserializers[T] = deserializer;
    typeName ??= T.toString();
    _typeIds[getInternalTypeId(typeName)] = T;
  }

  /// Get the [Type] for a given typeId.
  Type _getType(String typeId) {
    if (!_typeIds.containsKey(typeId)) {
      throw StateError(
        'No type with id $typeId registered. Register the Storable using [PersistenceManager.register()].',
      );
    }
    return _typeIds[typeId]!;
  }

  /// Get the registered type id for a given [Type].
  String getTypeId(Type type) {
    final typeId = _typeIds.entries
        .firstWhere((entry) => entry.value == type,
            orElse: () => throw UnsupportedError(
                'The type $type was not registered. Please register the type using [PersistenceManager.registerTypeName()].'))
        .key;
    return typeId;
  }

  /// Throw an [ArgumentError] if [T] is [Storable].
  void _throwIfTStorable<T>() {
    if (T == Storable) {
      final functionName = StackTrace.current
          .toString()
          .split('\n')[1]
          .split('PersistenceManager.')
          .last
          .split('(')
          .first
          .trim();
      throw ArgumentError(
        'The type [Storable] cannot be used. Call [PersistenceManager.$functionName()] with the Storable subtype.',
      );
    }
  }
}
