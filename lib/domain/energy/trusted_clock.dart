/// A time the player cannot move by changing the device's clock, which the
/// energy recharge is measured on.
abstract interface class TrustedClock {
  /// The trusted instant now, or `null` while none has been obtained yet
  /// (offline since the launch).
  DateTime? now();

  /// Asks the trusted source for the time; whether it answered. A failure is
  /// not an error: [now] stays `null` and the caller tries again later.
  Future<bool> sync();
}
