// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_position.dart';

part 'bee_release.freezed.dart';

/// The outcome of taking the bee out of a hive that has made nothing yet.
@freezed
sealed class BeeRelease with _$BeeRelease {
  /// The bee is out on [position]; [board] is the board with it, and the
  /// hive empty.
  const factory BeeRelease.released({
    required Board board,
    required BoardPosition position,
  }) = BeeReleased;

  /// There was no free cell: nothing changed.
  const factory BeeRelease.boardFull() = BeeReleaseBoardFull;
}
