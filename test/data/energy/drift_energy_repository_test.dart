// 📦 Package imports:
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/data/energy/drift_energy_repository.dart';
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/domain/energy/energy.dart';

void main() {
  late AppDatabase database;
  late DriftEnergyRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftEnergyRepository(database);
  });

  tearDown(() => database.close());

  test('finds nothing before the first save', () async {
    expect(await repository.load(), isNull);
  });

  test('gives back the gauge it saved, with its count', () async {
    final energy = Energy(
      value: 37,
      countedFrom: DateTime.utc(2026, 10, 27, 8, 30, 15),
    );

    await repository.save(energy);

    expect(await repository.load(), energy);
  });

  test('gives back a full gauge with no count', () async {
    await repository.save(Energy.full());

    expect(await repository.load(), Energy.full());
  });

  test('a second save replaces the first', () async {
    await repository.save(Energy.full());
    await repository.save(const Energy(value: 12));

    expect(await repository.load(), const Energy(value: 12));
    expect(await database.select(database.energyStates).get(), hasLength(1));
  });

  test('keeps energy above the maximum bought with gems', () async {
    await repository.save(const Energy(value: 130));

    expect(await repository.load(), const Energy(value: 130));
  });

  test('never loads a negative value', () async {
    await database
        .into(database.energyStates)
        .insert(EnergyStatesCompanion.insert(value: -5));

    expect(await repository.load(), const Energy(value: 0));
  });
}
