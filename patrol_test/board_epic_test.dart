// The info panel's state is exposed for tests, and this is one (it lives
// outside `test/`, which the analyzer does not know).
// ignore_for_file: invalid_use_of_visible_for_testing_member

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

// 🌎 Project imports:
import 'package:apiary/core/di/injection.dart';
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/presentation/components/board/board_full_banner_component.dart';
import 'package:apiary/presentation/components/board/hive_component.dart';
import 'package:apiary/presentation/components/board/queen_component.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';

import 'board_driver.dart';
import 'common.dart';

/// What a merge conserves: a larva is worth 1, a bee of level n is worth 2^n.
int _worth(BoardItem item) => switch (item) {
  Queen() || Hive() => 0,
  Larva() => 1,
  Bee(:final level) => 1 << level,
};

void main() {
  // The whole "Plateau et fusion" epic (APY-1 to APY-10) in one game, from an
  // empty app to a board saved and restored. One test per file: iOS shares
  // its process between tests (see docs/TESTING.md).
  patrolTest(
    'board epic: from an empty app to a merged, saved and restored board',
    ($) async {
      final game = await launchApiary($);
      final driver = BoardDriver($, game);
      final repository = getIt<BoardRepository>();
      const start = Board.startingQueenPosition;
      const hive = Board.startingHivePosition;
      const common = Family.common;

      // --- Empty state: a first game on the starting board (APY-1, APY-2).
      await getIt<AppDatabase>().reset();
      await game.restartFromScratch();
      await driver.settle();

      expect(game.router.currentRoute.name, BoardScene.routeName);
      expect(driver.board, Board.initial());
      expect(driver.board.items, hasLength(2), reason: 'the queen and a hive');
      expect(driver.selection, isNull);
      expect(await repository.load(), isNull, reason: 'nothing saved yet');
      expect(
        driver.boardComponent.children.whereType<QueenComponent>(),
        hasLength(1),
      );
      expect(driver.board.itemAt(hive), const BoardItem.hive());
      expect(
        driver.boardComponent.children.whereType<HiveComponent>(),
        hasLength(1),
      );

      // --- Selecting shows the item's info (APY-9).
      await driver.tapCell(const BoardPosition(column: 0, row: 0));
      expect(driver.selection, isNull, reason: 'an empty cell is no item');

      await driver.tapCell(start);
      expect(driver.selection, start);
      expect(driver.info.titleText, isNotEmpty);
      expect(driver.info.hasRemoveButton, isFalse, reason: 'queens stay');
      expect(
        driver.board,
        Board.initial(),
        reason: 'selecting creates nothing',
      );

      // A hive can be inspected, but never removed (APY-11).
      await driver.tapCell(hive);
      expect(driver.selection, hive);
      expect(driver.info.titleText, isNotEmpty);
      expect(driver.info.hasRemoveButton, isFalse, reason: 'hives stay');
      expect(
        driver.board,
        Board.initial(),
        reason: 'selecting changes nothing',
      );

      // --- A selected queen creates larvae on the nearest free cells (APY-3).
      expect(
        await driver.newLarva(),
        const BoardPosition(column: 3, row: 3),
        reason: 'the first larva lands right above the queen',
      );
      expect(
        driver.board.itemAt(const BoardPosition(column: 3, row: 3)),
        const BoardItem.larva(family: common),
      );
      expect(await driver.newLarva(), const BoardPosition(column: 4, row: 3));
      expect(await driver.newLarva(), const BoardPosition(column: 4, row: 4));
      expect(driver.board.items, hasLength(5));
      expect(
        await repository.load(),
        driver.board,
        reason: 'the board is saved right after each action (APY-8)',
      );

      // --- Removing an item, then undoing it (APY-10).
      const doomed = BoardPosition(column: 4, row: 4);
      await driver.tapCell(doomed);
      expect(driver.info.hasRemoveButton, isTrue);
      final withDoomed = driver.board;

      await driver.tapButton(driver.info.removeButton);
      expect(driver.board.itemAt(doomed), isNull);
      expect(driver.selection, isNull);
      expect(driver.info.hasUndoButton, isTrue);
      expect(driver.info.hasRemovedFrame, isTrue);
      expect(await repository.load(), driver.board);

      await driver.tapButton(driver.info.undoButton);
      expect(driver.board, withDoomed);
      expect(driver.selection, doomed);
      expect(driver.info.hasUndoButton, isFalse);
      expect(await repository.load(), withDoomed);

      // Any other action makes a removal final.
      await driver.tapButton(driver.info.removeButton);
      expect(driver.boardComponent.canUndo, isTrue);
      await driver.tapCell(start);
      expect(driver.boardComponent.canUndo, isFalse);
      expect(driver.info.hasUndoButton, isFalse);
      expect(driver.board.itemAt(doomed), isNull);

      // --- Moving an item to an empty cell (APY-5).
      const corner = BoardPosition(column: 6, row: 8);
      await driver.drag(const BoardPosition(column: 4, row: 3), corner);
      expect(
        driver.board.itemAt(corner),
        const BoardItem.larva(family: common),
      );
      expect(
        driver.board.itemAt(const BoardPosition(column: 4, row: 3)),
        isNull,
      );
      expect(driver.selection, corner, reason: 'a dragged item is selected');

      // --- Swapping two different items (APY-6): the larva and the queen.
      await driver.drag(corner, start);
      expect(driver.board.itemAt(start), const BoardItem.larva(family: common));
      expect(driver.queen, corner);
      expect(driver.board.items, hasLength(4));
      await driver.drag(corner, start);
      expect(driver.queen, start, reason: 'swapped back');
      expect(
        driver.board.itemAt(corner),
        const BoardItem.larva(family: common),
      );

      // --- Merging two larvae into a bee (APY-4).
      expect(
        driver.cellsWhere((item) => item is Larva),
        hasLength(2),
        reason: 'the larva above the queen and the one in the corner',
      );
      await driver.drag(corner, const BoardPosition(column: 3, row: 3));
      expect(driver.board.items, hasLength(3));
      expect(
        driver.board.itemAt(const BoardPosition(column: 3, row: 3)),
        const BoardItem.bee(family: common),
      );
      expect(driver.selection, const BoardPosition(column: 3, row: 3));

      // A bee and a larva do not merge: they trade places.
      final larva = await driver.newLarva();
      await driver.drag(const BoardPosition(column: 3, row: 3), larva);
      expect(driver.board.itemAt(larva), const BoardItem.bee(family: common));
      expect(
        driver.board.itemAt(const BoardPosition(column: 3, row: 3)),
        const BoardItem.larva(family: common),
      );

      // --- Merging bees up to the family's last level (APY-7).
      final level2 = await driver.raiseBee(2);
      expect(
        driver.board.itemAt(level2),
        const BoardItem.bee(family: common, level: 2),
      );
      expect(await repository.load(), driver.board);

      // --- A full board: the queen has no room, nothing changes (APY-3).
      while (driver.board.items.length < Board.columns * Board.rows) {
        await driver.newLarva();
      }
      final full = driver.board;
      expect(
        driver.fullBanner.isShown,
        isFalse,
        reason: 'the banner answers a tap, not a full board',
      );
      await driver.tapCell(driver.queen);
      expect(driver.board, full);
      expect(await repository.load(), full);
      expect(
        driver.fullBanner.isShown,
        isTrue,
        reason: 'tells the board is full',
      );

      // It holds for a moment, then fades out on its own.
      const bannerSeconds =
          BoardFullBannerComponent.popDuration +
          BoardFullBannerComponent.holdDuration +
          BoardFullBannerComponent.fadeDuration;
      await driver.settle(
        Duration(milliseconds: (bannerSeconds * 1000).round() + 300),
      );
      expect(driver.fullBanner.isShown, isFalse);

      // --- Merging a crowded board away: value is conserved at each step,
      // and merging goes on until no two items are left to merge.
      final worth = full.items.values.map(_worth).reduce((a, b) => a + b);
      while (true) {
        final pair = _mergeablePair(driver.board);
        if (pair == null) {
          break;
        }
        final before = driver.board.items.length;
        await driver.drag(pair.$1, pair.$2);
        expect(driver.board.items, hasLength(before - 1));
      }
      expect(
        driver.board.items.values.map(_worth).reduce((a, b) => a + b),
        worth,
        reason: 'merging neither creates nor destroys anything',
      );
      final topLevel = common.maxLevel;
      final top = BoardItem.bee(family: common, level: topLevel);
      expect(
        driver.board.items.values.whereType<Bee>().map((bee) => bee.level),
        contains(topLevel),
      );

      // --- Two bees of the last level no longer merge: they trade places.
      while (driver.cellsWhere((item) => item == top).length < 2) {
        await driver.raiseBee(topLevel);
      }
      final [first, second, ...] = driver
          .cellsWhere((item) => item == top)
          .toList();
      final beforeSwap = driver.board;
      await driver.drag(first, second);
      expect(driver.board, beforeSwap);
      expect(
        driver.board.items.values.whereType<Bee>().map((bee) => bee.level),
        everyElement(lessThanOrEqualTo(topLevel)),
      );

      // --- Reopening the app restores the board in progress (APY-8).
      final saved = driver.board;
      expect(await repository.load(), saved);
      driver.game = await relaunchApiary($);
      await driver.settle();

      expect(driver.board, saved);
      expect(driver.selection, isNull);
      expect(game.router.currentRoute.name, BoardScene.routeName);
      expect(driver.game.router.currentRoute.name, BoardScene.routeName);
    },
    timeout: const Timeout(Duration(minutes: 15)),
  );
}

/// Two cells whose items merge, the first dropped on the second; `null` when
/// there are none. Worked out from the rules (a family's larvae; bees of one
/// family and level below the last), not from the game's own check.
(BoardPosition, BoardPosition)? _mergeablePair(Board board) {
  final seen = <Object, BoardPosition>{};
  for (final MapEntry(:key, :value) in board.items.entries) {
    final kind = switch (value) {
      Larva(:final family) => (family, 0),
      Bee(:final family, :final level) when level < family.maxLevel => (
        family,
        level,
      ),
      _ => null,
    };
    if (kind == null) {
      continue;
    }
    final other = seen[kind];
    if (other != null) {
      return (other, key);
    }
    seen[kind] = key;
  }
  return null;
}
