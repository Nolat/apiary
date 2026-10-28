// 🐦 Flutter imports:
import 'package:flutter/gestures.dart';

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/events.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/components/orders/orders_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

/// The orders strip of [game], once the game is ready.
OrdersComponent ordersOf(ApiaryGame game) =>
    game.world.descendants().whereType<OrdersComponent>().single;

/// One game pixel on screen, along x.
double gamePixel(ApiaryGame game) =>
    game.camera.localToGlobal(Vector2(1, 0)).x -
    game.camera.localToGlobal(Vector2.zero()).x;

/// Drags a finger over the orders strip of [game] by [dx] game pixels, in one
/// move, through Flame's drag dispatcher.
void dragOrders(ApiaryGame game, double dx) {
  final strip = ordersOf(game);
  final middle = game.camera.localToGlobal(
    strip.absolutePositionOf(Vector2(strip.size.x / 2, strip.size.y / 2)),
  );
  final from = Offset(middle.x, middle.y);
  (game.findByKey(const MultiDragScaleDispatcherKey())!
        as MultiDragScaleDispatcher)
    ..onDragStart(
      DragStartEvent(
        1,
        game,
        DragStartDetails(globalPosition: from, localPosition: from),
      ),
    )
    ..onDragUpdate(
      DragUpdateEvent(
        1,
        game,
        DragUpdateDetails(
          globalPosition: from,
          localPosition: from,
          delta: Offset(dx * gamePixel(game), 0),
        ),
      ),
    )
    ..onDragEnd(DragEndEvent(1, DragEndDetails()));
}
