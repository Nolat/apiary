// 🌎 Project imports:
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/domain/energy/energy_repository.dart';

/// An [EnergyRepository] in memory, which counts its saves.
class MemoryEnergyRepository implements EnergyRepository {
  MemoryEnergyRepository([this.saved]);

  Energy? saved;
  int saves = 0;

  @override
  Future<Energy?> load() async => saved;

  @override
  Future<void> save(Energy energy) async {
    saved = energy;
    saves++;
  }
}
