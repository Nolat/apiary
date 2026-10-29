// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/presentation/game/energy_countdown.dart';
import 'package:apiary/presentation/game/energy_notifier.dart';
import '../../helpers/energy_container.dart';
import '../../helpers/fake_trusted_clock.dart';
import '../../helpers/memory_energy_repository.dart';

void main() {
  final start = DateTime.utc(2026, 10, 27, 8);

  group('EnergyNotifier', () {
    test('starts on a full gauge', () {
      expect(energyOf(energyContainer()), Energy.full());
    });

    test('pays a cost and saves the gauge', () {
      final repository = MemoryEnergyRepository();
      final container = energyContainer(repository: repository);

      expect(notifierOf(container).trySpend(1), isTrue);

      expect(energyOf(container).value, 99);
      expect(repository.saved?.value, 99);
    });

    test('refuses a cost it cannot pay and changes nothing', () async {
      final repository = MemoryEnergyRepository(const Energy(value: 0));
      final container = energyContainer(repository: repository);
      final notifier = notifierOf(container);
      await notifier.load();

      expect(notifier.canAfford(1), isFalse);
      expect(notifier.trySpend(1), isFalse);

      expect(energyOf(container).value, 0);
      expect(repository.saves, 0);
    });

    test('never goes below zero when emptied by spending', () async {
      final container = energyContainer(saved: const Energy(value: 2));
      final notifier = notifierOf(container);
      await notifier.load();

      expect(notifier.trySpend(1), isTrue);
      expect(notifier.trySpend(1), isTrue);
      expect(notifier.trySpend(1), isFalse);

      expect(energyOf(container).value, 0);
    });

    test('starts the recharge when it leaves full, on the trusted time', () {
      final container = energyContainer(clock: FakeTrustedClock(time: start));

      notifierOf(container).trySpend(1);

      expect(energyOf(container), Energy(value: 99, countedFrom: start));
    });

    test(
      'recharges one unit per trusted minute while the app is open',
      () async {
        final clock = FakeTrustedClock(time: start);
        final container = energyContainer(
          saved: Energy(value: 50, countedFrom: start),
          clock: clock,
        );
        final notifier = notifierOf(container);
        await notifier.load();

        clock.advance(const Duration(minutes: 1, seconds: 1));
        notifier.update(EnergyNotifier.refreshInterval);
        expect(energyOf(container).value, 51);

        clock.advance(const Duration(minutes: 2));
        notifier.update(EnergyNotifier.refreshInterval);
        expect(energyOf(container).value, 53);
      },
    );

    test('saves the gauge when a unit comes back', () async {
      final repository = MemoryEnergyRepository(
        Energy(value: 50, countedFrom: start),
      );
      final clock = FakeTrustedClock(time: start);
      final container = energyContainer(repository: repository, clock: clock);
      final notifier = notifierOf(container);
      await notifier.load();

      clock.advance(const Duration(minutes: 1));
      notifier.update(EnergyNotifier.refreshInterval);

      expect(repository.saved?.value, 51);
    });

    test(
      'shows the time left to the next unit, rounded up to the second',
      () async {
        final clock = FakeTrustedClock(time: start);
        final container = energyContainer(
          saved: Energy(value: 50, countedFrom: start),
          clock: clock,
        );
        final notifier = notifierOf(container);
        await notifier.load();

        clock.advance(const Duration(seconds: 20, milliseconds: 500));
        notifier.update(EnergyNotifier.refreshInterval);

        expect(
          container.read(energyCountdownProvider),
          const Duration(seconds: 40),
        );
      },
    );

    test('shows no countdown when the gauge is full', () {
      final container = energyContainer(clock: FakeTrustedClock(time: start));

      notifierOf(container).update(EnergyNotifier.refreshInterval);

      expect(container.read(energyCountdownProvider), isNull);
    });

    test(
      'credits the time spent closed once the trusted time is known',
      () async {
        final clock = FakeTrustedClock()
          ..serverTime = start.add(const Duration(minutes: 35, seconds: 10));
        final container = energyContainer(
          saved: Energy(value: 20, countedFrom: start),
          clock: clock,
        );
        final notifier = notifierOf(container);

        await notifier.load();
        expect(energyOf(container).value, 20);

        await notifier.sync();

        expect(energyOf(container).value, 55);
      },
    );

    test('caps what the closed app earned at 100', () async {
      final clock = FakeTrustedClock()
        ..serverTime = start.add(const Duration(days: 3));
      final container = energyContainer(
        saved: Energy(value: 20, countedFrom: start),
        clock: clock,
      );
      final notifier = notifierOf(container);

      await notifier.load();
      await notifier.sync();

      expect(energyOf(container), Energy.full());
    });

    test('leaves a full gauge alone however long the app was closed', () async {
      final clock = FakeTrustedClock()
        ..serverTime = start.add(const Duration(days: 3));
      final container = energyContainer(saved: Energy.full(), clock: clock);
      final notifier = notifierOf(container);

      await notifier.load();
      await notifier.sync();

      expect(energyOf(container), Energy.full());
    });

    test(
      'recharges nothing while offline, then credits it on reconnect',
      () async {
        final clock = FakeTrustedClock(reachable: false)
          ..serverTime = start.add(const Duration(minutes: 10));
        final container = energyContainer(
          saved: Energy(value: 20, countedFrom: start),
          clock: clock,
        );
        final notifier = notifierOf(container);
        await notifier.load();

        await notifier.sync();
        expect(energyOf(container).value, 20);
        expect(container.read(energyCountdownProvider), isNull);

        clock.reachable = true;
        await notifier.sync();
        expect(energyOf(container).value, 30);
      },
    );

    test('asks the clock again every 30 seconds while it has no time', () {
      final clock = FakeTrustedClock(reachable: false);
      final notifier = notifierOf(energyContainer(clock: clock))..update(10);
      expect(clock.syncs, 0);

      notifier.update(20);
      expect(clock.syncs, 1);
    });

    test(
      'is not accelerated by the device clock, which it never reads',
      () async {
        // The trusted clock stands still: whatever the phone's date does, no
        // unit comes back.
        final container = energyContainer(
          saved: Energy(value: 50, countedFrom: start),
          clock: FakeTrustedClock(time: start),
        );
        final notifier = notifierOf(container);
        await notifier.load();

        notifier.update(3600);

        expect(energyOf(container).value, 50);
      },
    );

    test('does not take energy away when the trusted time goes back', () async {
      final clock = FakeTrustedClock(time: start);
      final container = energyContainer(
        saved: Energy(value: 50, countedFrom: start),
        clock: clock,
      );
      final notifier = notifierOf(container);
      await notifier.load();

      clock.advance(const Duration(hours: -3));
      notifier.update(EnergyNotifier.refreshInterval);

      expect(energyOf(container).value, 50);
    });

    test('brings the recharge up to date at most every 250 ms', () async {
      final clock = FakeTrustedClock(time: start);
      final container = energyContainer(
        saved: Energy(value: 50, countedFrom: start),
        clock: clock,
      );
      final notifier = notifierOf(container);
      await notifier.load();

      clock.advance(const Duration(minutes: 1));
      notifier
        ..update(0.1)
        ..update(0.1);
      expect(energyOf(container).value, 50);

      notifier.update(0.1);
      expect(energyOf(container).value, 51);
    });

    test('saves the full gauge on reset', () {
      final repository = MemoryEnergyRepository(const Energy(value: 3));
      final container = energyContainer(repository: repository);

      notifierOf(container).reset();

      expect(repository.saved, Energy.full());
    });

    test('goes back to a full gauge on reset', () async {
      final container = energyContainer(saved: const Energy(value: 3));
      final notifier = notifierOf(container);
      await notifier.load();

      notifier.reset();

      expect(energyOf(container), Energy.full());
    });

    test(
      'falls back on a full gauge when the saved one cannot be read',
      () async {
        final container = energyContainer(repository: _BrokenRepository());

        await notifierOf(container).load();

        expect(energyOf(container), Energy.full());
      },
    );
  });
}

class _BrokenRepository extends MemoryEnergyRepository {
  @override
  Future<Energy?> load() => throw StateError('broken storage');
}
