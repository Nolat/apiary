// 📦 Package imports:
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// 🌎 Project imports:
import 'package:apiary/core/logging/talker_service.dart';
import 'package:apiary/data/board/board_cells.dart';
import 'package:apiary/data/energy/energy_states.dart';
import 'package:apiary/data/local/app_database.steps.dart';
import 'package:apiary/data/orders/day_order_resources.dart';
import 'package:apiary/data/orders/day_orders.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [BoardCells, EnergyStates, DayOrders, DayOrderResources],
)
class AppDatabase extends _$AppDatabase {
  /// [executor] defaults to the on-device SQLite file; tests pass
  /// `NativeDatabase.memory()` instead (see docs/TESTING.md).
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Version 1 had no table: every table is created as it is today, so
        // there is no step left to run.
        await m.createAll();
        return;
      }
      await stepByStep(
        from2To3: (m, schema) async {
          final cells = schema.boardCells;
          try {
            await m.addColumn(cells, cells.remainingLife);
            // A bee already in a hive keeps the whole lifespan it had (5, the
            // provisional one of every species), not the column's default.
            await m.database.customStatement(
              'UPDATE ${cells.aliasedName} '
              'SET ${cells.remainingLife.name} = 5 '
              "WHERE ${cells.kind.name} = 'housed_hive'",
            );
          } on Object catch (error, stackTrace) {
            talker.handle(error, stackTrace, 'Migrating the board v2 to v3');
            rethrow;
          }
        },
        // The energy table is new and starts empty: a first save creates its
        // row, and a game without one starts on a full gauge.
        from3To4: (m, schema) => m.createTable(schema.energyStates),
        // The order tables are new and start empty: a game without orders
        // starts on the first day's.
        from4To5: (m, schema) async {
          await m.createTable(schema.dayOrders);
          await m.createTable(schema.dayOrderResources);
        },
      )(m, from, to);
    },
  );

  /// Empties every table, all or nothing, keeping the schema. For the dev
  /// screen: the next launch is a first game.
  Future<void> reset() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'apiary');
  }
}
