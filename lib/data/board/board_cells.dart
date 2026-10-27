// 📦 Package imports:
import 'package:drift/drift.dart';

/// One row per occupied cell of the board; an empty cell has no row.
///
/// [kind] and [family] hold the names of the domain enums so that the file
/// stays readable and survives a reordering; see `DriftBoardRepository`.
class BoardCells extends Table {
  IntColumn get column => integer()();
  IntColumn get row => integer()();

  /// `queen`, `larva`, `bee` or `hive`.
  TextColumn get kind => text()();

  /// A `Family` name; empty for an empty hive, which has none. A hive that
  /// holds a bee has the bee's.
  TextColumn get family => text()();

  /// The level of a bee, or of the bee a hive holds; 1 for the other items,
  /// which have none to speak of.
  IntColumn get level => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {column, row};
}
