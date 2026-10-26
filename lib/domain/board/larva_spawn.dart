// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_position.dart';

part 'larva_spawn.freezed.dart';

/// The outcome of tapping a queen.
@freezed
sealed class LarvaSpawn with _$LarvaSpawn {
  /// A larva appeared on [position]; [board] is the board with it.
  const factory LarvaSpawn.created({
    required Board board,
    required BoardPosition position,
  }) = LarvaCreated;

  /// There was no free cell: nothing changed.
  const factory LarvaSpawn.boardFull() = BoardFull;
}
