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

Offset _screenOfCell(ApiaryGame game, BoardComponent board, BoardPosition c) {
  final inBoard = Vector2((c.column + 0.5) * 20, (c.row + 0.5) * 20);
  final screen = game.camera.localToGlobal(board.absolutePositionOf(inBoard));
  return Offset(screen.x, screen.y);
}

MultiTapDispatcher _tapDispatcher(ApiaryGame game) =>
    game.findByKey(const MultiTapDispatcherKey())! as MultiTapDispatcher;

/// Puts a finger down on the middle of [cell], through Flame's tap
/// dispatcher; [releaseCell] lifts it.
void pressCell(ApiaryGame game, BoardComponent board, BoardPosition cell) =>
    _tapDispatcher(game).onTapDown(
      createTapDownEvents(
        game: game,
        globalPosition: _screenOfCell(game, board, cell),
      ),
    );

/// Lifts the finger put down by [pressCell] on the middle of [cell].
void releaseCell(ApiaryGame game, BoardComponent board, BoardPosition cell) =>
    _tapDispatcher(game).onTapUp(
      createTapUpEvents(
        game: game,
        globalPosition: _screenOfCell(game, board, cell),
      ),
    );

/// Taps the middle of [cell] as the player would (finger down, then up).
void tapCell(ApiaryGame game, BoardComponent board, BoardPosition cell) {
  pressCell(game, board, cell);
  releaseCell(game, board, cell);
}

/// A finger dragging on the board of [game], through Flame's drag
/// dispatcher. [start] puts it down on the middle of a cell; [moveTo] slides
/// it to the middle of another one (or beyond the grid); [end] lifts it.
class CellDrag {
  CellDrag(this.game, this.board, {this.pointerId = 1});

  final int pointerId;

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
        pointerId,
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
        pointerId,
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

  void end() =>
      _dispatcher.onDragEnd(DragEndEvent(pointerId, DragEndDetails()));

  /// The system takes the gesture away, as when a call comes in.
  void cancel() => _dispatcher.onDragCancel(DragCancelEvent(pointerId));
}
