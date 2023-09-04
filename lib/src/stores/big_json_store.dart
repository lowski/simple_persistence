import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../simple_persistence.dart';

class BigJsonStore<T extends Storable> extends Store<T> {
  final FutureOr<String> path;
  final StorableFactory storableFactory;
  Directory? _dir;

  BigJsonStore({
    required this.path,
    required this.storableFactory,
  }) {
    eventStream.listen(_onEvent);
  }

  @override
  Future<Map<String, T>> load() async {
    // return {};
    final path = await this.path;

    assert(path.isNotEmpty);

    _dir = Directory(path);
    if (!await _dir!.exists()) {
      await _dir!.create(recursive: true);
      return {};
    }

    final paths = (await _dir!.list().map((event) => event.path).toList());

    final data = <String, T>{};
    await Future.wait(
      paths.map(
        (e) async {
          final map = jsonDecode(await File(e).readAsString());
          final storable = storableFactory
              .deserializeMapRepresentation<T>(map as Map<String, dynamic>);
          data[storable.id] = storable;
        },
      ),
    );

    return data;
  }

  /// This is a no-op for [BigJsonStore] as it would be too expensive to
  /// rewrite all files on every change. Instead, the [StoreDataModifiedEvent]
  /// is used to update the files on change.
  @override
  Future<void> persistAll(Map<String, T> data) {
    return Future.value();
  }

  void _onEvent(StoreDataModifiedEvent<T> event) async {
    if (_dir == null) {
      return;
    }

    final file = File(p.join(_dir!.path, '${event.id}.json'));
    if (event is StorableCreatedEvent || event is StorableUpdatedEvent) {
      final json = jsonEncode(event.storable.asMap);
      await file.writeAsString(json);
    } else if (event is StorableDeletedEvent) {
      await file.delete();
    } else {
      throw UnimplementedError('Unknown event: $event');
    }
  }
}
