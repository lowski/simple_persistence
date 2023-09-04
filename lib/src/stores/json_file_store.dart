library simple_persistence;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../simple_persistence.dart';

/// A [Store] that persists all to a single JSON file. This is not recommended
/// for large data sets as the entire file must be read and written on every
/// change.
class JsonFileStore<T extends Storable> extends Store<T> {
  final FutureOr<String> path;
  final StorableFactory storableFactory;
  File? _file;

  JsonFileStore({
    required this.path,
    required this.storableFactory,
  });

  @override
  Future<Map<StorableId, T>> load() async {
    final path = await this.path;

    assert(path.isNotEmpty);
    assert(path.endsWith('.json'));

    _file = File(path);
    if (!await _file!.exists()) {
      return {};
    }

    final json = await _file!.readAsString();
    if (json.isEmpty) {
      return {};
    }

    final list = List<Map>.from(jsonDecode(json));
    final data = <StorableId, T>{};
    for (final map in list) {
      final storable = storableFactory
          .deserializeMapRepresentation<T>(map as Map<String, dynamic>);
      data[storable.id] = storable;
    }

    return data;
  }

  @override
  Future<void> persistAll(Map<StorableId, T> data) async {
    if (_file == null) {
      return;
    }
    final list = data.values.map((e) => e.asMap).toList();
    final json = jsonEncode(list);

    await _file!.writeAsString(json);
  }
}
