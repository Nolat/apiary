// 📦 Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/energy/energy_repository.dart';

part 'energy_repository_provider.g.dart';

/// Where the energy gauge is saved; `null` keeps it in memory, as in tests.
/// The app assembles the real one by overriding this provider (`bootstrap()`),
/// so that a read before the launch has registered it fails loudly instead of
/// settling on `null` for the whole session.
@Riverpod(keepAlive: true)
EnergyRepository? energyRepository(Ref ref) => null;
