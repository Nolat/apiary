// 📦 Package imports:
import 'package:glados/glados.dart';

// 🌎 Project imports:
import 'package:apiary/domain/energy/energy.dart';

extension AnyEnergy on Any {
  Generator<Energy> get energy => combine2(
    intInRange(0, Energy.maximum + 1),
    intInRange(0, 1000000),
    (value, seconds) => Energy(
      value: value,
      countedFrom: value >= Energy.maximum
          ? null
          : DateTime.utc(2026, 10, 27).add(Duration(seconds: seconds)),
    ),
  );
}

void main() {
  final start = DateTime.utc(2026, 10, 27, 8);

  group('Energy.full', () {
    test('is at the maximum with no count', () {
      expect(Energy.full().value, 100);
      expect(Energy.full().countedFrom, isNull);
    });
  });

  group('Energy.spend', () {
    test('takes the cost off the value', () {
      expect(Energy.full().spend(1), const Energy(value: 99));
    });

    test('refuses a cost above the value, leaving nothing to change', () {
      expect(const Energy(value: 0).spend(1), isNull);
      expect(const Energy(value: 2).spend(3), isNull);
    });

    test('can empty the gauge exactly', () {
      expect(const Energy(value: 1).spend(1), const Energy(value: 0));
    });

    Glados2(any.energy, any.intInRange(0, 200)).test(
      'never goes negative',
      (energy, cost) {
        final spent = energy.spend(cost);

        expect(spent == null, cost > energy.value);
        if (spent != null) {
          expect(spent.value, energy.value - cost);
          expect(spent.value, greaterThanOrEqualTo(0));
        }
      },
    );
  });

  group('Energy.recharged', () {
    test('starts counting at the first trusted time after leaving full', () {
      final spent = Energy.full().spend(1)!;

      expect(spent.recharged(start), Energy(value: 99, countedFrom: start));
    });

    test('adds one unit per whole minute', () {
      final energy = Energy(value: 50, countedFrom: start);

      expect(
        energy.recharged(start.add(const Duration(minutes: 3, seconds: 59))),
        Energy(
          value: 53,
          countedFrom: start.add(const Duration(minutes: 3)),
        ),
      );
    });

    test('adds nothing before a minute is over', () {
      final energy = Energy(value: 50, countedFrom: start);

      expect(energy.recharged(start.add(const Duration(seconds: 59))), energy);
    });

    test('is back to full after 1 h 40 from empty, and no later', () {
      final empty = Energy(value: 0, countedFrom: start);

      expect(
        empty.recharged(start.add(const Duration(minutes: 99))).value,
        99,
      );
      expect(
        empty.recharged(start.add(const Duration(minutes: 100))),
        Energy.full(),
      );
    });

    test('stops at the maximum however long the app was closed', () {
      final energy = Energy(value: 90, countedFrom: start);

      expect(energy.recharged(start.add(const Duration(days: 30))).value, 100);
    });

    test('leaves energy above the maximum as it is', () {
      expect(const Energy(value: 130).recharged(start).value, 130);
    });

    test('takes nothing away when the time goes back', () {
      final energy = Energy(value: 50, countedFrom: start);

      expect(
        energy.recharged(start.subtract(const Duration(hours: 5))),
        energy,
      );
    });

    Glados2(any.energy, any.intInRange(0, 20000)).test(
      'never exceeds the maximum nor loses energy',
      (energy, minutes) {
        final after = energy.countedFrom == null
            ? energy
            : energy.recharged(
                energy.countedFrom!.add(Duration(minutes: minutes)),
              );

        expect(after.value, greaterThanOrEqualTo(energy.value));
        expect(after.value, lessThanOrEqualTo(Energy.maximum));
      },
    );

    Glados2(any.intInRange(0, 100), any.intInRange(0, 300)).test(
      'recharging in two steps equals recharging at once',
      (value, minutes) {
        final energy = Energy(value: value, countedFrom: start);
        final middle = start.add(Duration(seconds: minutes * 17));
        final end = start.add(Duration(seconds: minutes * 40));

        expect(energy.recharged(middle).recharged(end), energy.recharged(end));
      },
    );
  });

  group('Energy.untilNext', () {
    test('counts down to the next unit', () {
      final energy = Energy(value: 10, countedFrom: start);

      expect(
        energy.untilNext(start.add(const Duration(seconds: 20))),
        const Duration(seconds: 40),
      );
    });

    test('is a whole minute right after a unit came back', () {
      final energy = Energy(value: 10, countedFrom: start);

      expect(energy.untilNext(start), Energy.rechargeInterval);
    });

    test('is none when the gauge is full or above', () {
      expect(Energy.full().untilNext(start), isNull);
      expect(const Energy(value: 120).untilNext(start), isNull);
    });

    test('is none while no count has started', () {
      expect(const Energy(value: 10).untilNext(start), isNull);
    });
  });
}
