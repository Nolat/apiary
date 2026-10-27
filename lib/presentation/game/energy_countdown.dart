// 📦 Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'energy_countdown.g.dart';

/// How long until the next unit of energy, in whole seconds (rounded up, so
/// it never shows 0:00); `null` when the gauge is full or no trusted time is
/// known.
@Riverpod(keepAlive: true)
class EnergyCountdown extends _$EnergyCountdown {
  @override
  Duration? build() => null;

  // Only a change notifies: the HUD redraws once a second, not every frame.
  void show(Duration? left) {
    if (left != state) {
      state = left;
    }
  }
}
