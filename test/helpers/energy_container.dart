// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/domain/energy/energy_repository.dart';
import 'package:apiary/domain/energy/trusted_clock.dart';
import 'package:apiary/presentation/game/energy_notifier.dart';
import 'package:apiary/presentation/game/energy_repository_provider.dart';
import 'package:apiary/presentation/game/trusted_clock_provider.dart';
import 'memory_energy_repository.dart';

/// A container whose energy is saved in [repository] (in memory by default,
/// holding [saved] when given) and recharged on [clock]; no clock recharges
/// nothing. Disposed with the test. Nothing is loaded: the game does it, or
/// the test calls `load()`.
ProviderContainer energyContainer({
  Energy? saved,
  EnergyRepository? repository,
  TrustedClock? clock,
}) {
  final container = ProviderContainer(
    overrides: [
      energyRepositoryProvider.overrideWithValue(
        repository ?? MemoryEnergyRepository(saved),
      ),
      trustedClockProvider.overrideWithValue(clock),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// What the energy of [container] holds.
Energy energyOf(ProviderContainer container) => container.read(energyProvider);

/// The energy notifier of [container].
EnergyNotifier notifierOf(ProviderContainer container) =>
    container.read(energyProvider.notifier);
