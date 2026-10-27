// 📦 Package imports:
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// 🌎 Project imports:
import 'package:apiary/data/board/board_cells.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [BoardCells])
class AppDatabase extends _$AppDatabase {
  /// [executor] defaults to the on-device SQLite file; tests pass
  /// `NativeDatabase.memory()` instead (see docs/TESTING.md).
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(boardCells);
      }
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
