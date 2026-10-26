// 🎯 Dart imports:
import 'dart:ui' show Offset;

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
