// 📦 Package imports:
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/data/local/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // Real SQLite engine, in memory: no mocks, fresh database per test.
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('opens and reports the current schema version', () async {
    final result = await database.customSelect('SELECT 1 AS one').getSingle();

    expect(result.read<int>('one'), 1);
    expect(database.schemaVersion, 2);
  });

  test('upgrades a version 1 database with the board table', () async {
    final upgraded = AppDatabase(
      NativeDatabase.memory(
        setup: (db) => db.execute('PRAGMA user_version = 1'),
      ),
    );
    addTearDown(upgraded.close);

    final rows = await upgraded.select(upgraded.boardCells).get();

    expect(rows, isEmpty);
  });
}
