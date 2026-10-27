// dart format width=80

// 📦 Package imports:
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/data/local/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Checks that the rows of a v2 board survive, and that a bee already in a
  // hive gets its whole lifespan rather than the column's default.
  test('migration from v2 to v3 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    final oldBoardCellsData = <v2.BoardCellsData>[
      const v2.BoardCellsData(
        column: 3,
        row: 4,
        kind: 'queen',
        family: 'common',
        level: 1,
      ),
      const v2.BoardCellsData(
        column: 3,
        row: 7,
        kind: 'housed_hive',
        family: 'common',
        level: 2,
      ),
    ];
    final expectedNewBoardCellsData = <v3.BoardCellsData>[
      const v3.BoardCellsData(
        column: 3,
        row: 4,
        kind: 'queen',
        family: 'common',
        level: 1,
        remainingLife: 1,
      ),
      const v3.BoardCellsData(
        column: 3,
        row: 7,
        kind: 'housed_hive',
        family: 'common',
        level: 2,
        remainingLife: 5,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.boardCells, oldBoardCellsData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewBoardCellsData,
          await newDb.select(newDb.boardCells).get(),
        );
      },
    );
  });
}
