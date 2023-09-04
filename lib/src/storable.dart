library simple_persistence;

import 'dart:convert';

import 'package:meta/meta.dart';

import 'reserved_tokens.dart';
import 'utils.dart';

class StorableId {
  /// The value of the [id] field when the id is empty.
  static const StorableId empty = StorableId(ReservedTokens.emptyIdValue);

  final String id;

  const StorableId(this.id);

  StorableId.uuid() : id = uuidv4();

  bool get isSet => this != empty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StorableId && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'StorableId($id)';
}

abstract class Storable {
  // ignore: prefer_final_fields
  StorableId _id = StorableId.empty;

  /// The unique identifier of the object.
  StorableId get id => _id;

  /// Set the [id] for the object. If the object already has an [id], this
  /// does nothing.
  set id(StorableId value) {
    if (id.isSet) {
      return;
    }
    _id = value;
  }

  /// The object data represented as a map.
  @protected
  dynamic get data;

  /// A unique identifier for the type of object used for deserialization.
  /// By default, this is the hash code of the runtime type.
  String get type => runtimeType.hashCode.toString();

  /// The object fully represented as a map with embedded objects serialized.
  Map<String, dynamic> get asMap => {
        ReservedTokens.id: id,
        ReservedTokens.type: type,
        ...data,
      }.map(
        (key, value) => MapEntry(
            key,
            value is Storable
                ? value.asMap
                : value is StorableId
                    ? value.id
                    : value),
      );

  /// The serialized representation of the object.
  String get asJson => jsonEncode(asMap);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Storable && asJson == other.asJson;

  @override
  int get hashCode => asJson.hashCode;
}
