// 🐦 Flutter imports:
import 'package:flutter/gestures.dart';

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

/// The board of [game] once the game is ready.
Future<BoardComponent> boardOf(ApiaryGame game) async {
  await game.ready();
  return game.world.descendants().whereType<BoardComponent>().single;
}

/// Taps the middle of [cell] as the player would, through Flame's tap
/// dispatcher.
void tapCell(ApiaryGame game, BoardComponent board, BoardPosition cell) {
  final inBoard = Vector2((cell.column + 0.5) * 20, (cell.row + 0.5) * 20);
  final screen = game.camera.localToGlobal(board.absolutePositionOf(inBoard));
  (game.findByKey(const MultiTapDispatcherKey())! as MultiTapDispatcher)
      .onTapDown(
        createTapDownEvents(
          game: game,
          globalPosition: Offset(screen.x, screen.y),
        ),
      );
}

/// A finger dragging on the board of [game], through Flame's drag
/// dispatcher. [start] puts it down on the middle of a cell; [moveTo] slides
/// it to the middle of another one (or beyond the grid); [end] lifts it.
class CellDrag {
  CellDrag(this.game, this.board);

  final ApiaryGame game;
  final BoardComponent board;
  late Offset _at;

  MultiDragScaleDispatcher get _dispatcher =>
      game.findByKey(const MultiDragScaleDispatcherKey())!
          as MultiDragScaleDispatcher;

  Offset _screenOf(int column, int row) {
    final inBoard = Vector2((column + 0.5) * 20, (row + 0.5) * 20);
    final screen = game.camera.localToGlobal(board.absolutePositionOf(inBoard));
    return Offset(screen.x, screen.y);
  }

  void start(BoardPosition cell) {
    final at = _at = _screenOf(cell.column, cell.row);
    _dispatcher.onDragStart(
      DragStartEvent(
        1,
        game,
        DragStartDetails(globalPosition: at, localPosition: at),
      ),
    );
  }

  /// Moves in a single step to the middle of the cell at [column], [row],
  /// which may lie outside the grid.
  void moveTo(int column, int row) {
    final to = _screenOf(column, row);
    _dispatcher.onDragUpdate(
      DragUpdateEvent(
        1,
        game,
        DragUpdateDetails(
          // Flame reads the end of a move as the position plus the delta.
          globalPosition: _at,
          localPosition: _at,
          delta: to - _at,
        ),
      ),
    );
    _at = to;
  }

  void end() => _dispatcher.onDragEnd(DragEndEvent(1, DragEndDetails()));
}
