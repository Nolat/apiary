// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';

// 🌎 Project imports:
import 'package:apiary/core/dev/shake_detector.dart';

void main() {
  final start = DateTime(2026, 10, 26, 12);
  const jolt = 20.0;
  const rest = 1.0;

  /// The number of shakes detected in [readings], each an acceleration along
  /// x taken at a number of milliseconds after [start].
  Future<int> shakesIn(List<(int, double)> readings) async {
    final events = StreamController<UserAccelerometerEvent>(sync: true);
    var shakes = 0;
    ShakeDetector(acceleration: events.stream).shakes.listen((_) => shakes++);
    for (final (milliseconds, x) in readings) {
      final at = start.add(Duration(milliseconds: milliseconds));
      events.add(UserAccelerometerEvent(x, 0, 0, at));
    }
    await pumpEventQueue();
    return shakes;
  }

  test('detects jolts in quick succession as one shake', () async {
    expect(await shakesIn([(0, jolt), (200, jolt), (400, jolt)]), 1);
  });

  test('uses the magnitude of the acceleration, not one axis', () async {
    final events = StreamController<UserAccelerometerEvent>(sync: true);
    var shakes = 0;
    ShakeDetector(acceleration: events.stream).shakes.listen((_) => shakes++);
    for (var i = 0; i < 3; i++) {
      final at = start.add(Duration(milliseconds: i * 100));
      events.add(UserAccelerometerEvent(10, 10, 10, at));
    }

    await pumpEventQueue();

    expect(shakes, 1);
  });

  test('ignores a single bump', () async {
    expect(await shakesIn([(0, jolt), (100, rest), (200, rest)]), 0);
  });

  test('ignores jolts too far apart', () async {
    expect(await shakesIn([(0, jolt), (500, jolt), (1000, jolt)]), 0);
  });

  test('ignores gentle movements', () async {
    expect(await shakesIn([for (var i = 0; i < 10; i++) (i * 50, rest)]), 0);
  });

  test('waits for the cooldown before the next shake', () async {
    expect(
      await shakesIn([
        for (var i = 0; i < 6; i++) (i * 100, jolt),
      ]),
      1,
    );
    expect(
      await shakesIn([
        for (var i = 0; i < 3; i++) (i * 100, jolt),
        for (var i = 0; i < 3; i++) (2000 + i * 100, jolt),
      ]),
      2,
    );
  });
}
