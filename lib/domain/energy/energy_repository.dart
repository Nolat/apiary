// 🌎 Project imports:
import 'package:apiary/domain/energy/energy.dart';

/// Where the energy gauge of the game in progress is kept between two
/// launches.
abstract interface class EnergyRepository {
  /// The saved gauge, or `null` when none was saved yet (a first game).
  Future<Energy?> load();

  /// Replaces the saved gauge by [energy].
  Future<void> save(Energy energy);
}
