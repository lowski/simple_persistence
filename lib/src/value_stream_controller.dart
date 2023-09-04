import 'dart:async';

/// A [ValueStreamController] is a [StreamController] that emits the last
/// emitted value to any listener when the listener first subscribes to the
/// [Stream].
class ValueStreamController<T> implements StreamController<T> {
  final StreamController<T> _controller;
  @override
  Stream<T> get stream => _controller.stream;

  bool _hasValue = false;
  T? _lastValue;

  /// The last emitted value.
  T? get value => _lastValue;

  /// Create a new [ValueStreamController] with an optional initial value.
  ///
  /// [initialValueIsNull] must be set to [true], if the initial value is
  /// [null]. This ensures that the [Stream] emits a `null` value when a
  /// listener subscribes.
  ValueStreamController({
    T? initialValue,
    bool initiallyNull = false,
  }) : _controller = StreamController<T>.broadcast() {
    if (initialValue != null || initiallyNull) {
      _lastValue = initialValue;
      _hasValue = true;
    }

    _controller.onListen = () {
      if (_hasValue) {
        _controller.add(_lastValue as T);
      }
      onListen?.call();
    };
    _controller.onCancel = () {
      onCancel?.call();
    };
  }

  /// Add a new value to the [ValueStreamController].
  @override
  void add(T value) {
    _hasValue = true;
    if (value == _lastValue) {
      return;
    }
    _lastValue = value;
    _controller.add(value);
  }

  @override
  Future<dynamic> close() => _controller.close();

  @override
  void Function()? onCancel;

  @override
  void Function()? onListen;

  @override
  void Function()? onPause;

  @override
  void Function()? onResume;

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _controller.addError(error, stackTrace);

  @override
  Future addStream(Stream<T> source, {bool? cancelOnError}) =>
      _controller.addStream(source, cancelOnError: cancelOnError);

  @override
  Future get done => _controller.done;

  @override
  bool get hasListener => _controller.hasListener;

  @override
  bool get isClosed => _controller.isClosed;

  @override
  bool get isPaused => _controller.isPaused;

  @override
  StreamSink<T> get sink => _controller.sink;
}

/// A wrapper that manages multiple [ValueStreamController]s.
///
/// This is useful for managing multiple streams of the same type that are
/// identified by a key.
class MultiValueStreamController<K, T> {
  final Map<K, ValueStreamController<T>> _controllers = {};

  /// Get the [ValueStreamController] for [id]. If no [ValueStreamController]
  /// exists for [id], a new one is created.
  Stream<T> getStream(
    K id, {
    T? initialValue,
    bool initiallyNull = false,
  }) {
    final controller = _controllers[id] ??= ValueStreamController<T>(
      initialValue: initialValue,
      initiallyNull: initiallyNull,
    );

    controller.onCancel = () {
      _controllers.remove(id);
    };

    return controller.stream;
  }

  /// Add a new value to the [ValueStreamController] for [id].
  void add(K id, T value) {
    _controllers[id]?.add(value);
  }

  /// Close the [ValueStreamController] for [id].
  void close(K id) {
    _controllers[id]?.close();
    _controllers.remove(id);
  }
}
