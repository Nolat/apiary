// 📦 Package imports:
import 'package:drift/drift.dart' show Value;
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
    expect(database.schemaVersion, 6);
  });

  test('upgrades a version 1 database with every table', () async {
    final upgraded = AppDatabase(
      NativeDatabase.memory(
        setup: (db) => db.execute('PRAGMA user_version = 1'),
      ),
    );
    addTearDown(upgraded.close);

    expect(await upgraded.select(upgraded.boardCells).get(), isEmpty);
    expect(await upgraded.select(upgraded.energyStates).get(), isEmpty);
    expect(await upgraded.select(upgraded.dayOrders).get(), isEmpty);
    expect(await upgraded.select(upgraded.dayOrderResources).get(), isEmpty);
  });

  test('reset empties every table', () async {
    await database
        .into(database.boardCells)
        .insert(
          BoardCellsCompanion.insert(
            column: 1,
            row: 2,
            kind: 'queen',
            family: 'common',
          ),
        );

    await database
        .into(database.energyStates)
        .insert(EnergyStatesCompanion.insert(value: 40));

    await database
        .into(database.dayOrders)
        .insert(
          DayOrdersCompanion.insert(
            position: const Value(0),
            customer: 'baker',
            coins: 10,
          ),
        );
    await database
        .into(database.dayOrderResources)
        .insert(
          DayOrderResourcesCompanion.insert(
            orderPosition: 0,
            slot: 0,
            branch: 'wax',
            tier: 1,
          ),
        );

    await database.reset();

    expect(await database.select(database.boardCells).get(), isEmpty);
    expect(await database.select(database.energyStates).get(), isEmpty);
    expect(await database.select(database.dayOrders).get(), isEmpty);
    expect(await database.select(database.dayOrderResources).get(), isEmpty);
  });
}
