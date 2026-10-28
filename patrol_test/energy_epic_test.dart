// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

// 🌎 Project imports:
import 'package:apiary/core/di/injection.dart';
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/domain/bees/bee_lifespan.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/domain/energy/energy_repository.dart';
import 'package:apiary/domain/energy/trusted_clock.dart';
import 'package:apiary/presentation/components/hud/energy_gauge_component.dart';

import 'board_driver.dart';
import 'common.dart';

void main() {
  // The whole "Énergie" epic (APY-24 to APY-26) in one game, from an empty
  // app: the gauge in the HUD, what a tap on a queen and on a hive costs, the
  // tap that finds the gauge empty, and the gauge kept when the app is opened
  // again. The recharge over time is covered by the fast tests, on a clock
  // the test moves (a real minute would make this one far too long). One test
  // per file: iOS shares its process between tests (see docs/TESTING.md).
  patrolTest(
    'energy epic: from a full gauge to an empty one, saved and restored',
    ($) async {
      final game = await launchApiary($);
      final driver = BoardDriver($, game)..refillEnergy = false;
      final repository = getIt<EnergyRepository>();
      const hive = Board.startingHivePosition;

      EnergyGaugeComponent gauge() => driver.game.world
          .descendants()
          .whereType<EnergyGaugeComponent>()
          .single;
      int energy() => driver.game.energyValue.value;

      // --- A first game: a full gauge in the HUD (APY-24).
      await getIt<AppDatabase>().reset();
      await game.restartFromScratch();
      await driver.settle();
      expect(energy(), Energy.maximum);
      expect(gauge().amountText, '${Energy.maximum}');
      expect(gauge().countdownText, isEmpty, reason: 'nothing to wait for');

      // --- Selecting, moving and merging cost nothing; a tap that makes a
      // larva costs one unit (APY-25).
      await driver.tapCell(driver.queen);
      expect(energy(), Energy.maximum);
      await driver.tapCell(driver.queen);
      expect(driver.board.items.length, Board.initial().items.length + 1);
      expect(energy(), Energy.maximum - 1);
      expect(gauge().amountText, '${Energy.maximum - 1}');
      final first = driver.board.items.entries
          .singleWhere((entry) => entry.value is Larva)
          .key;
      final second = await driver.newLarva();
      expect(energy(), Energy.maximum - 2);
      await driver.drag(first, second);
      expect(energy(), Energy.maximum - 2, reason: 'a merge is free');

      // --- A hive costs a unit per resource, on top of the bee's lifespan.
      final bee = await driver.raiseBee(1);
      expect(energy(), Energy.maximum - 4);
      await driver.drag(bee, hive);
      expect(energy(), Energy.maximum - 4, reason: 'housing a bee is free');
      // The drag selected the hive: both taps make a resource.
      await driver.tapCell(hive);
      await driver.tapCell(hive);
      expect(
        (driver.board.itemAt(hive)! as Hive).remainingLife,
        BeeLifespan.of(1) - 2,
      );
      expect(energy(), Energy.maximum - 6);

      // --- The gauge below its ceiling counts down to the next unit (APY-26),
      // on the time of the server: the deployed rules let the player read it.
      final clock = getIt<TrustedClock>();
      for (var i = 0; clock.now() == null; i++) {
        expect(i, lessThan(100), reason: 'The server time never came');
        await $.tester.pump(const Duration(milliseconds: 100));
      }
      await driver.settle();
      expect(gauge().countdownText, matches(r'^\d\d:\d\d$'));
      expect(gauge().showsCountdown, isTrue);
      expect(await repository.load(), isNotNull);
      expect((await repository.load())!.value, energy());

      // --- Reopening the app keeps the gauge, and credits at most the time
      // that went by (a few seconds here).
      final before = energy();
      driver.game = await relaunchApiary($);
      await driver.settle();
      expect(energy(), inInclusiveRange(before, before + 1));

      // --- With a single unit left, a tap makes the last larva; the next
      // one finds the gauge empty and makes nothing (APY-25).
      await repository.save(const Energy(value: 1));
      driver.game = await relaunchApiary($);
      await driver.settle();
      driver.refillEnergy = false;
      expect(energy(), 1);
      final items = driver.board.items.length;
      await driver.tapCell(driver.queen);
      await driver.tapCell(driver.queen);
      expect(driver.board.items.length, items + 1);
      expect(energy(), 0);
      final emptyBoard = driver.board;

      await driver.tapCell(driver.queen);
      await driver.settle();

      expect(driver.board, emptyBoard, reason: 'nothing is made');
      expect(energy(), 0, reason: 'never below zero');
      expect(driver.missingEnergyBanner.isShown, isTrue);
      expect(driver.fullBanner.isShown, isFalse);

      // --- The same goes for a hive: nothing made, the lifespan kept.
      await driver.tapCell(hive);
      await driver.tapCell(hive);
      expect(driver.board, emptyBoard);
      expect(energy(), 0);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
