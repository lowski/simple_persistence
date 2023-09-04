import 'dart:async';

import 'package:path/path.dart' as p;

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
    value.addAll(map['v'] as Map<String, dynamic>);
  }
}

/// A simple key-value store that can be used to store any type of primitive.
///
/// [KVStore] is a wrapper around a [JsonFileStore] that stores a single
/// [Storable] object. [KVStore] is not intended to be used for large data sets.
class KVStore {
  static Store<_KVStorable>? _store;

  final String prefix;

  /// Create a new [KVStore] instance with a given prefix. A unique prefix is
  /// important to avoid collisions with other [KVStore] instances.
  const KVStore(this.prefix);

  static void init(FutureOr<String> dir) {
    _store ??= JsonFileStore(
      path: Future.value(dir).then((value) => p.join(value, 'kv_store.json')),
      storableFactory: _KVStorable.storableFactory,
    );
  }

  void delete(String id) {
    _store!.delete('$prefix/$id');
  }

  void clear() {
    _store!.clear();
  }

  void save<T>(String id, T value) {
    _store!.save(_KVStorable(value)..id = '$prefix/$id');
  }

  T? get<T>(String id) {
    return _store!.get('$prefix/$id')?.value as T?;
  }

  Stream<T?> listen<T>(String id) {
    return _store!.listen('$prefix/$id').map((event) => event?.value as T?);
  }
}
