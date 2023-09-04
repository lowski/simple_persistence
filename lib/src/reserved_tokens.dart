library simple_persistence;

class ReservedTokens {
  /// The value of the [id] field when the id is empty.
  static const String emptyIdValue = '~empty';

  /// A special value for the [id] field that will generate a new [StorableId]
  /// when [Storable.id] is set to this value.
  static const String generateIdValue = '~generate';

  static const String id = '~id';
  static const String type = '~type';
}
