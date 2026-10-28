// 📦 Package imports:
import 'package:drift/drift.dart';

/// One row per order of the day, [position] being its place among the cards,
/// left to right; see `DriftOrderRepository`.
class DayOrders extends Table {
  IntColumn get position => integer()();

  /// A `Customer` name.
  TextColumn get customer => text()();

  IntColumn get coins => integer()();

  @override
  Set<Column> get primaryKey => {position};
}
