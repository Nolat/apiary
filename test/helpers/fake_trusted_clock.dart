// 🌎 Project imports:
import 'package:apiary/domain/energy/trusted_clock.dart';

/// A [TrustedClock] the test moves by hand. It knows no time until [sync]
/// succeeds, as a phone that opens offline.
class FakeTrustedClock implements TrustedClock {
  FakeTrustedClock({this._time, this.reachable = true});

  DateTime? _time;

  /// What the next [sync] finds: the time of the server.
  DateTime serverTime = DateTime.utc(2026, 10, 27, 8);

  /// Whether the server answers.
  bool reachable;

  int syncs = 0;

  /// Makes the trusted time pass.
  void advance(Duration duration) => _time = _time?.add(duration);

  @override
  DateTime? now() => _time;

  @override
  Future<bool> sync() async {
    syncs++;
    if (!reachable) {
      return false;
    }
    _time = serverTime;
    return true;
  }
}
