// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'board_position.freezed.dart';

/// A cell of the board, counted from the top-left corner (0, 0).
@freezed
abstract class BoardPosition with _$BoardPosition {
  const factory BoardPosition({required int column, required int row}) =
      _BoardPosition;

  const BoardPosition._();
}
