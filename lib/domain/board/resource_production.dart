// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_position.dart';

part 'resource_production.freezed.dart';

/// The outcome of tapping an occupied hive.
@freezed
sealed class ResourceProduction with _$ResourceProduction {
  /// A resource appeared on [position]; [board] is the board with it.
  const factory ResourceProduction.created({
    required Board board,
    required BoardPosition position,
  }) = ResourceCreated;

  /// There was no free cell: nothing changed.
  const factory ResourceProduction.boardFull() = ResourceBoardFull;
}
