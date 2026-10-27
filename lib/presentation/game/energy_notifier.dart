// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/core/logging/talker_service.dart';
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/domain/energy/energy_repository.dart';
import 'package:apiary/domain/energy/trusted_clock.dart';
import 'package:apiary/presentation/game/energy_countdown.dart';
import 'package:apiary/presentation/game/energy_repository_provider.dart';
import 'package:apiary/presentation/game/trusted_clock_provider.dart';

part 'energy_notifier.g.dart';

/// The energy gauge of the game in progress, shared by what spends it (the
/// board) and what shows it (the HUD): the state is the single copy, saved
/// after each change, and recharged over time on the [trustedClock]'s time.
/// The game calls [update] every frame.
///
/// Without a repository nothing is saved, and without a clock nothing is
/// recharged: tests play on a gauge that only goes down.
@Riverpod(keepAlive: true)
class EnergyNotifier extends _$EnergyNotifier {
  /// How long to wait before asking the trusted clock again after a failure.
  static const retryDelay = 30.0;

  /// How often, in seconds, the recharge and the countdown are brought up to
  /// date: units come back by the minute, the countdown shows whole seconds,
  /// so a frame has nothing to do.
  static const refreshInterval = 0.25;

  // Starts due, so the first update does not wait.
  double _sinceRefresh = refreshInterval;
  double _sinceSyncAttempt = 0;
  var _syncing = false;

  EnergyRepository? get _repository => ref.read(energyRepositoryProvider);
  TrustedClock? get _clock => ref.read(trustedClockProvider);

  @override
  Energy build() => Energy.full();

  /// Restores the saved gauge, a full one for a first game, and credits what
  /// came back while the app was closed once the trusted time is known.
  Future<void> load() async {
    try {
      state = await _repository?.load() ?? state;
      // Any failure of the storage, whatever its type, falls back the same
      // way: the game goes on with a full gauge.
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      talker.handle(error, stackTrace, 'Loading the energy failed');
    }
    _refresh();
  }

  /// Asks the trusted clock for the time, then credits the recharge it
  /// allows. Does nothing without a clock.
  Future<void> sync() async {
    final clock = _clock;
    if (clock == null || _syncing) {
      return;
    }
    _syncing = true;
    try {
      await clock.sync();
    } finally {
      _syncing = false;
    }
    _refresh();
  }

  /// Advances the recharge; [dt] is the time since the last call, in seconds
  /// of the device, which only paces the retries of a missing trusted time.
  void update(double dt) {
    if (_clock?.now() == null) {
      _sinceSyncAttempt += dt;
      if (_sinceSyncAttempt >= retryDelay) {
        _sinceSyncAttempt = 0;
        unawaited(sync());
      }
      return;
    }
    _sinceRefresh += dt;
    if (_sinceRefresh >= refreshInterval) {
      _refresh();
    }
  }

  /// Whether [cost] can be paid now (as of the last refresh: a unit that came
  /// back less than [refreshInterval] ago is only counted by [trySpend]).
  bool canAfford(int cost) => state.canAfford(cost);

  /// Pays [cost] and saves; `false` (nothing changes) when there is not
  /// enough.
  bool trySpend(int cost) {
    _refresh();
    final spent = state.spend(cost);
    if (spent == null) {
      return false;
    }
    final now = _clock?.now();
    _set(now == null ? spent : spent.recharged(now));
    return true;
  }

  /// Back to a full gauge, as for a first game, and saved so.
  void reset() {
    _set(Energy.full());
    _refresh();
  }

  void _refresh() {
    _sinceRefresh = 0;
    final now = _clock?.now();
    if (now != null) {
      final recharged = state.recharged(now);
      if (recharged != state) {
        _set(recharged);
      }
    }
    final untilNext = now == null ? null : state.untilNext(now);
    ref
        .read(energyCountdownProvider.notifier)
        .show(
          untilNext == null
              ? null
              : Duration(seconds: (untilNext.inMilliseconds / 1000).ceil()),
        );
  }

  void _set(Energy value) {
    state = value;
    final repository = _repository;
    if (repository != null) {
      unawaited(
        repository
            .save(value)
            .catchError(
              (Object error, StackTrace stackTrace) =>
                  talker.handle(error, stackTrace, 'Saving the energy failed'),
            ),
      );
    }
  }
}
