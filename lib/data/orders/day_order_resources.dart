// 📦 Package imports:
import 'package:drift/drift.dart';

/// One row per resource an order asks for: the [orderPosition] of its order
/// (see `DayOrders`) and its own [slot] among that order's resources.
class DayOrderResources extends Table {
  IntColumn get orderPosition => integer()();
  IntColumn get slot => integer()();

  /// A `ResourceBranch` name.
  TextColumn get branch => text()();

  IntColumn get tier => integer()();

  @override
  Set<Column> get primaryKey => {orderPosition, slot};
}
