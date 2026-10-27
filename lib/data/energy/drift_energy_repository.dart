// 📦 Package imports:
import 'package:drift/drift.dart';

// 🌎 Project imports:
import 'package:apiary/data/energy/energy_states.dart';
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/domain/energy/energy_repository.dart';

/// Keeps the energy gauge in the local SQLite database, in a single row.
class DriftEnergyRepository implements EnergyRepository {
  DriftEnergyRepository(this._database);

  final AppDatabase _database;

  @override
  Future<Energy?> load() async {
    final row =
        await (_database.select(
              _database.energyStates,
            )..where((state) => state.id.equals(EnergyStates.singleRow)))
            .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final countedFromMs = row.countedFromMs;
    return Energy(
      // Never below zero, whatever the file holds.
      value: row.value < 0 ? 0 : row.value,
      countedFrom: countedFromMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(countedFromMs, isUtc: true),
    );
  }

  @override
  Future<void> save(Energy energy) => _database
      .into(_database.energyStates)
      .insertOnConflictUpdate(
        EnergyStatesCompanion.insert(
          id: const Value(EnergyStates.singleRow),
          value: energy.value,
          countedFromMs: Value(energy.countedFrom?.millisecondsSinceEpoch),
        ),
      );
}
