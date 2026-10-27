// 🎯 Dart imports:
import 'dart:math';

// 📦 Package imports:
import 'package:sensors_plus/sensors_plus.dart';

/// Turns the accelerometer into a stream of shakes.
///
/// Reads the acceleration without gravity: a shake is [jolts] readings above
/// [threshold] within [window], so a single bump or a step does not count.
/// Once one fires, the next waits for [cooldown].
class ShakeDetector {
  /// [acceleration] defaults to the device's user accelerometer.
  ShakeDetector({Stream<UserAccelerometerEvent>? acceleration})
    : _acceleration = acceleration ?? userAccelerometerEventStream();

  /// Acceleration in m/s² above which a reading counts as a jolt.
  static const threshold = 15.0;
  static const jolts = 3;
  static const window = Duration(milliseconds: 800);
  static const cooldown = Duration(milliseconds: 1500);

  final Stream<UserAccelerometerEvent> _acceleration;
  final List<DateTime> _recentJolts = [];
  DateTime? _lastShake;

  Stream<void> get shakes => _acceleration.where(_isShake).map((_) {});

  // Timed by the reading's own timestamp, not the clock: readings can be
  // delivered late, and their spacing is what makes a shake.
  bool _isShake(UserAccelerometerEvent event) {
    final now = event.timestamp;
    final lastShake = _lastShake;
    if (lastShake != null && now.difference(lastShake) < cooldown) {
      return false;
    }
    if (sqrt(event.x * event.x + event.y * event.y + event.z * event.z) <
        threshold) {
      return false;
    }
    _recentJolts
      ..removeWhere((at) => now.difference(at) > window)
      ..add(now);
    if (_recentJolts.length < jolts) {
      return false;
    }
    _recentJolts.clear();
    _lastShake = now;
    return true;
  }
}
