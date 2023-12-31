library simple_persistence;

import 'dart:async';

import 'package:meta/meta.dart';

import '../storable.dart';
import '../utils.dart';
import '../value_stream_controller.dart';

abstract class StoreDataModifiedEvent<T extends Storable> {
  T get storable;
  String get id => storable.id;
}

class StorableCreatedEvent<T extends Storable>
    extends StoreDataModifiedEvent<T> {
  @override
  final T storable;
  StorableCreatedEvent._(this.storable);

  @override
  String toString() {
    return 'StorableCreatedEvent{storable: $storable}';
  }
}

class StorableUpdatedEvent<T extends Storable>
    extends StoreDataModifiedEvent<T> {
  final T? previous;
  final T current;
  @override
  T get storable => current;
  StorableUpdatedEvent._(this.previous, this.current);

  @override
  String toString() {
    return 'StorableUpdatedEvent{previous: $previous, current: $current}';
  }
}

class StorableDeletedEvent<T extends Storable>
    extends StoreDataModifiedEvent<T> {
  @override
  final T storable;
  StorableDeletedEvent._(this.storable);
}

/// A store is a container for [Storable] objects. It is responsible for loading
/// and persisting data. If and how the data is persisted is up to the store
/// implementation.
///
/// A store can be used to store any type of [Storable] object. The store
/// implementation is responsible for serializing and deserializing the data to
/// and from persistent storage.
abstract class Store<T extends Storable> {
  final StreamController<StoreDataModifiedEvent<T>> _controller =
      StreamController.broadcast();
  Stream<StoreDataModifiedEvent<T>> get eventStream => _controller.stream;

  final _mvsc = MultiValueStreamController<String, T?>();
  final _listStream = ValueStreamController<List<T>>();

  final Map<String, T> _data = {};

  final Completer<void> _loadedCompleter = Completer();
  bool get _loaded => _loadedCompleter.isCompleted;

  /// A [Future] that completes when the store has been loaded.
  Future<void> get loaded => _loadedCompleter.future;

  Store() {
    eventStream.listen((StoreDataModifiedEvent<T> event) {
      _notifyValueStream(
        event.id,
        event is StorableDeletedEvent ? null : event.storable,
      );

      _listStream.add(list());
      persistAll(_data);
    });
    _load();
  }

  /// Persist all data to persistent storage. This method is called whenever
  /// any data changes. A store implementation can choose to implement this
  /// method if applicable or listen on [eventStream] for changes to single
  /// items.
  @protected
  Future<void> persistAll(Map<String, T> data);

  Future<void> _load() async {
    final data = await load();
    _data.addAll(data);
    _loadedCompleter.complete();

    // Notify all value streams that the data has been loaded.
    for (final e in _data.entries) {
      _notifyValueStream(e.key, e.value);
    }
    _listStream.add(list());
  }

  /// Load the data from persistent storage. This method is called once when
  /// the store is created.
  @protected
  Future<Map<String, T>> load();

  /// Get a list of all [Storable] objects in the store.
  List<T> list() {
    return List.unmodifiable(_data.values);
  }

  /// Get a [Storable] by its [id]. If the [Storable] is not found, `null` is
  /// returned.
  T? get(String id) {
    final storable = _data[id];
    return storable;
  }

  /// Listen for changes to a [Storable] by its [id]. If the [Storable] is not
  /// found, a [Stream] with a single `null` value is returned.
  ///
  /// If the [Storable] is found, a new [Stream] is returned that emits the
  /// current value and all future changes to the [Storable]. The [Stream] will
  /// also automatically emit the current value when the [Stream] is first
  /// listened to.
  ///
  /// If the [Storable] is not found and the store has not been loaded yet, the
  /// [Stream] will be created but will not emit any values until the store has
  /// been loaded.
  Stream<T?> listen(String id) {
    final storable = get(id);
    if (storable == null && !_loaded) {
      return Stream.value(null);
    }
    final storableId = storable?.id ?? id;

    final valueStream = _mvsc.getStream(storableId, initiallyNull: true);
    _mvsc.add(id, get(id));

    return valueStream;
  }

  /// Listen for changes to all [Storable] objects in the store. The [Stream]
  /// will emit the current list of [Storable] objects when it's being listened
  /// to and all future changes to the list.
  Stream<List<T>> listenAll() {
    return _listStream.stream;
  }

  T save(T value) {
    if (value == _data[value.id]) {
      return value;
    }

    value.id = uuidv4();

    final previous = _data[value.id];
    _data[value.id] = value;

    if (previous == null) {
      _controller.add(StorableCreatedEvent._(value));
    } else {
      _controller.add(StorableUpdatedEvent._(previous, value));
    }
    return value;
  }

  void delete(String id) {
    if (!_data.containsKey(id)) {
      return;
    }
    final storable = _data[id] as T;
    _data.remove(id);
    _controller.add(StorableDeletedEvent._(storable));
  }

  void clear() {
    if (_data.isEmpty) {
      return;
    }
    final previousData = List.unmodifiable(_data.values);
    _data.clear();
    for (final storable in previousData) {
      _controller.add(StorableDeletedEvent._(storable));
    }
  }

  void _notifyValueStream(String id, T? storable) {
    _mvsc.add(id, storable);

    if (storable == null) {
      _mvsc.close(id);
    }
  }
}
