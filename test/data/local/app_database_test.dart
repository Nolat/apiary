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
    expect(database.schemaVersion, 1);
  });
}
