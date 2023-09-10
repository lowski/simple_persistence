import 'dart:async';

import '../../simple_persistence.dart';

class _KVStorable extends Storable {
  static final storableFactory = StorableFactory()
    ..registerDeserializer(_KVStorable.fromMap);

  dynamic value;

  _KVStorable(this.value);

  @override
  get data => {
        'v': value,
      };

  _KVStorable.fromMap(Map<String, dynamic> map) {
    value = map['v'];
  }
}

/// A simple key-value store that can be used to store any type of primitive.
///
/// [KVStore] is a wrapper around a [JsonFileStore] that stores a single
/// [Storable] object. [KVStore] is not intended to be used for large data sets.
class KVStore {
  final Store<_KVStorable>? _store;

  /// Create a new [KVStore] instance with a given prefix. A unique prefix is
  /// important to avoid collisions with other [KVStore] instances.
  KVStore(
    FutureOr<String> path, {
    StorableFactory? storableFactory,
  }) : _store = JsonFileStore(
          path: path,
          storableFactory: (storableFactory
                ?..registerDeserializer(_KVStorable.fromMap)) ??
              _KVStorable.storableFactory,
        );

  Future<void> get loaded => _store!.loaded;

  void delete(String id) {
    _store!.delete(id);
  }

  void clear() {
    _store!.clear();
  }

  void save<T>(String id, T value) {
    _store!.save(_KVStorable(value)..id = id);
  }

  T? get<T>(String id) {
    return _store!.get(id)?.value as T?;
  }

  Stream<T?> listen<T>(String id) {
    return _store!.listen(id).map((event) => event?.value as T?);
  }
}
