// 📦 Package imports:
import 'package:drift/drift.dart';

/// The energy gauge: a single row, [id] being always [singleRow]; no row
/// until the first save (a first game).
class EnergyStates extends Table {
  /// The only value of [id].
  static const singleRow = 1;

  IntColumn get id => integer()();

  IntColumn get value => integer()();

  /// The trusted instant the next unit is counted from, in milliseconds since
  /// the epoch; `null` while the gauge is full or no trusted time was known.
  IntColumn get countedFromMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
