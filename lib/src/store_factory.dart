import 'storable.dart';
import 'stores/store.dart';

class StoreFactory<T extends Storable> {
  final Map<Type, Store> _stores = {};

  Store<T> getStore() {
    if (!_stores.containsKey(T)) {
      throw StateError(
        'No store for type $T registered. Please register a store for $T before using it.',
      );
    }
    return _stores[T] as Store<T>;
  }
}
