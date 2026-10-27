// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'energy.freezed.dart';

/// The energy gauge (see "Énergie" in `docs/DESIGN.md`): [value] units, which
/// come back one per [rechargeInterval] up to [maximum].
///
/// Time never comes from the device: [recharged] and [untilNext] take the
/// trusted `now` of a `TrustedClock`, so winding the phone's clock changes
/// nothing. The value may exceed [maximum] (energy bought with gems); the
/// recharge then stops until it is spent back below.
@freezed
abstract class Energy with _$Energy {
  const factory Energy({
    required int value,

    /// The trusted instant the next unit is counted from; `null` while the
    /// gauge is full, or while no trusted time has been known since it left
    /// full (the count then starts at the next [recharged]).
    DateTime? countedFrom,
  }) = _Energy;

  /// The gauge of a first game, and after a day is finished.
  factory Energy.full() => const Energy(value: maximum);

  const Energy._();

  /// The most energy the recharge over time brings the gauge to.
  static const maximum = 100;

  /// How long a unit takes to come back: 1 per minute, so 1 h 40 from empty.
  static const rechargeInterval = Duration(minutes: 1);

  /// What a larva or a resource costs: a working hypothesis of
  /// `docs/DESIGN.md`, to be tuned when balancing.
  static const productionCost = 1;

  /// Whether [cost] can be paid.
  bool canAfford(int cost) => value >= cost;

  /// The gauge after paying [cost], or `null` when there is not enough:
  /// energy never goes negative. Leaving a full gauge starts no count by
  /// itself, since this knows no time: [recharged] does.
  Energy? spend(int cost) {
    assert(cost >= 0, 'A cost cannot be negative: $cost');
    return canAfford(cost) ? copyWith(value: value - cost) : null;
  }

  /// The gauge brought up to the trusted instant [now]: one unit for each
  /// whole [rechargeInterval] since [countedFrom], without going past
  /// [maximum]. A [now] before [countedFrom] changes nothing: time going back
  /// takes no energy away.
  Energy recharged(DateTime now) {
    if (value >= maximum) {
      return countedFrom == null ? this : copyWith(countedFrom: null);
    }
    final from = countedFrom;
    if (from == null) {
      return copyWith(countedFrom: now);
    }
    final elapsed = now.difference(from);
    if (elapsed < rechargeInterval) {
      return this;
    }
    final units = elapsed.inMicroseconds ~/ rechargeInterval.inMicroseconds;
    final recharged = value + units;
    return recharged >= maximum
        ? const Energy(value: maximum)
        : Energy(
            value: recharged,
            countedFrom: from.add(rechargeInterval * units),
          );
  }

  /// How long until the next unit at the trusted instant [now], or `null`
  /// when none is coming: the gauge is full, or no count has started.
  Duration? untilNext(DateTime now) {
    final from = countedFrom;
    if (value >= maximum || from == null) {
      return null;
    }
    final elapsed = now.difference(from);
    if (elapsed.isNegative) {
      return rechargeInterval;
    }
    return rechargeInterval - elapsed;
  }
}
