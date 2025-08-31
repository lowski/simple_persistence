library simple_persistence;

import 'dart:convert';

import 'package:meta/meta.dart';

import 'persistence_manager.dart';
import 'reserved_tokens.dart';

abstract class Storable {
  // ignore: prefer_final_fields
  String _id = ReservedTokens.emptyIdValue;

  /// The unique identifier of the object.
  String get id => _id;

  /// Set the [id] for the object. If the object already has an [id], this
  /// does nothing.
  set id(String value) {
    if (id != ReservedTokens.emptyIdValue) {
      return;
    }
    _id = value;
  }

  bool get hasId => id != ReservedTokens.emptyIdValue;

  /// The object data represented as a map.
  @protected
  Map get data;

  /// The object fully represented as a map with embedded objects serialized.
  Map<String, dynamic> get asMap => {
        ReservedTokens.id: id,
        ReservedTokens.type: PersistenceManager.I.getTypeId(runtimeType),
        ...data,
      }.map(
        (key, value) => MapEntry(
          key,
          value is Storable
              ? value.asMap
              : (value is List && value.firstOrNull is Storable
                  ? value.map((e) => e.asMap).toList()
                  : value),
        ),
      );

  /// The serialized representation of the object.
  String get asJson => jsonEncode(asMap);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Storable && asJson == other.asJson;

  @override
  int get hashCode => asJson.hashCode;
}
