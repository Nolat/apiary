// The info panel's state is exposed for tests, and this is one (it lives
// outside `test/`, which the analyzer does not know).
// ignore_for_file: invalid_use_of_visible_for_testing_member

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

// 🌎 Project imports:
import 'package:apiary/core/di/injection.dart';
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/domain/bees/bee_lifespan.dart';
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/domain/resources/resource_branch.dart';
import 'package:apiary/presentation/components/board/hive_component.dart';
import 'package:apiary/presentation/components/board/resource_component.dart';

import 'board_driver.dart';
import 'common.dart';

void main() {
  // The whole "Ruches et ressources" epic (APY-11 to APY-15, and the release
  // of an untouched bee, APY-49) in one game, from an empty app to a board
  // saved and restored. One test per file: iOS shares its process between
  // tests (see docs/TESTING.md).
  patrolTest(
    'hives epic: from an empty hive to merged resources, saved and restored',
    ($) async {
      final game = await launchApiary($);
      final driver = BoardDriver($, game);
      final repository = getIt<BoardRepository>();
      const hive = Board.startingHivePosition;
      const common = Family.common;
      const lifespan = BeeLifespan.provisional;

      Hive hiveItem() => driver.board.itemAt(hive)! as Hive;
      Iterable<BoardPosition> resourcesOf(ResourceBranch branch, int tier) =>
          driver.cellsWhere(
            (item) =>
                item is Resource && item.branch == branch && item.tier == tier,
          );

      // Taps the hive until its bee is spent, selecting it first when needed.
      Future<void> spendBee() async {
        if (driver.selection != hive) {
          await driver.tapCell(hive);
        }
        for (var taps = 0; hiveItem().bee != null; taps++) {
          expect(taps, lessThanOrEqualTo(lifespan), reason: 'never spent');
          await driver.tapCell(hive);
        }
      }

      // Raises a level 1 bee from nothing and drops it in the empty hive.
      Future<BoardPosition> houseNewBee() async {
        final bee = await driver.raiseBee(1);
        await driver.drag(bee, hive);
        return bee;
      }

      // --- A first game: an empty hive (APY-11).
      await getIt<AppDatabase>().reset();
      await game.restartFromScratch();
      await driver.settle();
      expect(driver.board, Board.initial());
      expect(hiveItem().bee, isNull);

      // --- A bee dropped on the empty hive goes in (APY-12).
      final cell = await driver.raiseBee(1);
      expect(driver.board.itemAt(cell), const BoardItem.bee(family: common));
      await driver.drag(cell, hive);
      expect(driver.board.itemAt(cell), isNull, reason: 'its cell is free');
      expect(hiveItem().bee, const Bee(family: common));
      expect(hiveItem().remainingLife, lifespan);
      expect(driver.selection, hive);
      expect(
        driver.boardComponent.children.whereType<HiveComponent>().single.bee,
        isNotNull,
      );
      expect(await repository.load(), driver.board);

      // A bee dropped on an occupied hive swaps with it.
      final other = await driver.raiseBee(1);
      await driver.drag(other, hive);
      expect(driver.board.itemAt(hive), const BoardItem.bee(family: common));
      expect(driver.board.itemAt(other), isA<Hive>());
      await driver.drag(other, hive);
      expect(hiveItem().bee, const Bee(family: common), reason: 'swapped back');

      // --- While it has made nothing, the bee can be taken back (APY-49).
      expect(driver.info.hasReleaseButton, isTrue);
      final freeCell = driver.board.nearestFreeCell(hive);
      await driver.tapButton(driver.info.releaseButton);
      expect(driver.board.itemAt(freeCell!), const Bee(family: common));
      expect(driver.board.itemAt(hive), const BoardItem.hive());
      expect(driver.selection, hive);
      expect(driver.info.hasReleaseButton, isFalse);
      expect(await repository.load(), driver.board);

      await driver.drag(freeCell, hive);
      expect(hiveItem().bee, const Bee(family: common));
      expect(hiveItem().remainingLife, lifespan, reason: 'a whole lifespan');

      // --- A selected hive makes a resource on the nearest free cell (APY-13).
      final nearest = driver.board.nearestFreeCell(hive)!;
      await driver.tapCell(hive);
      expect(driver.board.itemAt(nearest), isA<Resource>());
      expect((driver.board.itemAt(nearest)! as Resource).tier, 1);
      expect(
        driver.boardComponent.children.whereType<ResourceComponent>(),
        hasLength(1),
      );
      expect(hiveItem().bee, const Bee(family: common), reason: 'it stays');
      expect(driver.info.hasReleaseButton, isFalse, reason: 'it has worked');

      // --- The bee is spent a resource at a time (APY-14), and the life it
      // has left survives reopening the app.
      expect(hiveItem().remainingLife, lifespan - 1);
      final saved = driver.board;
      expect(await repository.load(), saved);
      driver.game = await relaunchApiary($);
      await driver.settle();
      expect(driver.board, saved);
      expect(hiveItem().remainingLife, lifespan - 1);

      await spendBee();
      expect(driver.board.itemAt(hive), const BoardItem.hive());
      expect(
        driver.cellsWhere((item) => item is Resource),
        hasLength(lifespan),
        reason: 'one resource for each life of the bee',
      );
      expect(await repository.load(), driver.board);

      // An empty hive makes nothing.
      final spent = driver.board;
      await driver.tapCell(hive);
      await driver.tapCell(hive);
      expect(driver.board, spent);

      // --- Two identical resources merge into the next tier (APY-15): bees
      // go through the hive until two combs are on the board.
      for (
        var bees = 0;
        resourcesOf(ResourceBranch.comb, 1).length < 2;
        bees++
      ) {
        expect(bees, lessThan(6), reason: 'no comb after many resources');
        await houseNewBee();
        await spendBee();
      }
      final [first, second, ...] = resourcesOf(ResourceBranch.comb, 1).toList();
      final before = driver.board;
      await driver.drag(first, second);

      expect(driver.board.itemAt(first), isNull);
      expect(
        driver.board.itemAt(second),
        const BoardItem.resource(branch: ResourceBranch.comb, tier: 2),
        reason: 'honey, on the cell of the target',
      );
      expect(driver.board.items, hasLength(before.items.length - 1));
      expect(driver.selection, second);
      expect(await repository.load(), driver.board);

      // Honey is the last tier of its branch: it no longer merges. A pollen,
      // the only tier of its branch, neither.
      final lastTier = [
        ...resourcesOf(ResourceBranch.comb, 2),
        ...resourcesOf(ResourceBranch.pollen, 1),
      ];
      final bySameKind = <Object, BoardPosition>{};
      for (final position in lastTier) {
        final item = driver.board.itemAt(position)! as Resource;
        final twin = bySameKind[(item.branch, item.tier)];
        if (twin != null) {
          final beforeSwap = driver.board;
          await driver.drag(twin, position);
          expect(driver.board, beforeSwap, reason: 'identical, so unchanged');
          break;
        }
        bySameKind[(item.branch, item.tier)] = position;
      }

      // --- Reopening the app restores everything (APY-8).
      final end = driver.board;
      expect(await repository.load(), end);
      driver.game = await relaunchApiary($);
      await driver.settle();
      expect(driver.board, end);
      expect(driver.selection, isNull);
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}
