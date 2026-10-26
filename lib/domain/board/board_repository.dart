// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';

/// Where the board of the game in progress is kept between two launches.
abstract interface class BoardRepository {
  /// The saved board, or `null` when none was saved yet (a first game).
  Future<Board?> load();

  /// Replaces the saved board by [board], all or nothing: a launch after a
  /// crash during a save finds the previous board, never half of a new one.
  Future<void> save(Board board);
}
