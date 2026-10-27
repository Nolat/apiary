// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/board_banner_component.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

/// Plays the board of the running [game] with real touches, as a player
/// would: every tap and drag goes through the platform's pointer pipeline
/// (`WidgetTester`), the game is never told what to do directly.
class BoardDriver {
  BoardDriver(this.$, this.game);

  final PatrolIntegrationTester $;

  /// Replaced by the new game when the app is relaunched.
  ApiaryGame game;

  /// Whether the driver refills the gauge when it runs low, so that epics
  /// which play long games are not about energy. The energy epic turns it
  /// off.
  bool refillEnergy = true;

  /// How long the animations of a merge (land, then pop in) take, with a
  /// margin; any other action settles faster.
  static const _settle = Duration(milliseconds: 450);
  static const _frame = Duration(milliseconds: 16);

  BoardComponent get boardComponent =>
      game.world.descendants().whereType<BoardComponent>().single;

  BoardBannerComponent get fullBanner => boardComponent.fullBanner;

  BoardBannerComponent get missingEnergyBanner =>
      boardComponent.missingEnergyBanner;

  Board get board => boardComponent.board;

  BoardPosition? get selection => boardComponent.selection.value;

  ItemInfoComponent get info =>
      game.world.descendants().whereType<ItemInfoComponent>().single;

  /// Where the queen is now: a swap can move her.
  BoardPosition get queen =>
      board.items.entries.singleWhere((entry) => entry.value is Queen).key;

  /// Lets the game run for [duration] (frames are scheduled by the game
  /// loop; never `pumpAndSettle`, it would wait forever).
  Future<void> settle([Duration duration = _settle]) async {
    await $.tester.pump(duration);
    await game.ready();
  }

  Offset _screenOf(Vector2 inBoard) {
    final screen = game.camera.localToGlobal(
      boardComponent.absolutePositionOf(inBoard),
    );
    return Offset(screen.x, screen.y);
  }

  /// The middle of [cell] on screen. It may lie off the grid.
  Offset centerOf(BoardPosition cell) => _screenOf(
    Vector2((cell.column + 0.5) * 20, (cell.row + 0.5) * 20),
  );

  /// Taps the middle of [cell].
  Future<void> tapCell(BoardPosition cell) async {
    if (refillEnergy && !game.energy.canAfford(10)) {
      game.energy.reset();
    }
    await $.tester.tapAt(centerOf(cell));
    await settle(const Duration(milliseconds: 120));
  }

  /// Presses a button of the info panel with a real tap on its square.
  Future<void> tapButton(PositionComponent button) async {
    final screen = game.camera.localToGlobal(button.absoluteCenter);
    await $.tester.tapAt(Offset(screen.x, screen.y));
    await settle(const Duration(milliseconds: 120));
  }

  /// Drags the item of [from] onto [onto], in small steps like a finger, and
  /// lets the outcome play out.
  Future<void> drag(BoardPosition from, BoardPosition onto) async {
    final start = centerOf(from);
    final end = centerOf(onto);
    final gesture = await $.tester.startGesture(start);
    await $.tester.pump(_frame);
    const steps = 8;
    for (var step = 1; step <= steps; step++) {
      await gesture.moveTo(Offset.lerp(start, end, step / steps)!);
      await $.tester.pump(_frame);
    }
    await gesture.up();
    await settle();
  }

  /// Makes the queen create a larva, selecting her first when needed, and
  /// gives the cell it landed on.
  Future<BoardPosition> newLarva() async {
    if (selection != queen) {
      await tapCell(queen);
    }
    final before = board.items.keys.toSet();
    await tapCell(queen);
    return board.items.keys.toSet().difference(before).single;
  }

  /// Raises a bee of [level] from nothing but taps and drags: two bees of
  /// the level below (two larvae for level 1) merged together. Gives the
  /// cell it ends on.
  Future<BoardPosition> raiseBee(int level) async {
    final first = level == 1 ? await newLarva() : await raiseBee(level - 1);
    final second = level == 1 ? await newLarva() : await raiseBee(level - 1);
    await drag(first, second);
    return second;
  }

  /// The cells holding an item for which [test] is true.
  Iterable<BoardPosition> cellsWhere(bool Function(BoardItem item) test) =>
      board.items.entries
          .where((entry) => test(entry.value))
          .map((entry) => entry.key);
}
