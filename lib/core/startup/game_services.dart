// 🌎 Project imports:
import 'package:apiary/core/dev/dev_tools.dart';
import 'package:apiary/domain/board/board_repository.dart';

/// What the game needs from the services started while the splash screen is
/// up.
class GameServices {
  const GameServices({required this.boardRepository, this.devTools});

  /// Where the board is saved and restored.
  final BoardRepository boardRepository;

  /// What the dev screen does and what opens it; `null` has no dev screen.
  final DevTools? devTools;
}
