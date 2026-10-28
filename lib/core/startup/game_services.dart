// 🌎 Project imports:
import 'package:apiary/core/dev/dev_tools.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/domain/orders/order_repository.dart';

/// What the game needs from the services started while the splash screen is
/// up.
class GameServices {
  const GameServices({
    required this.boardRepository,
    this.orderRepository,
    this.devTools,
  });

  /// Where the board is saved and restored.
  final BoardRepository boardRepository;

  /// Where the orders of the day are saved and restored; `null` plays on the
  /// first day's orders without saving.
  final OrderRepository? orderRepository;

  /// What the dev screen does and what opens it; `null` has no dev screen.
  final DevTools? devTools;
}
