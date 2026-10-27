// 🎯 Dart imports:
import 'dart:async';
import 'dart:math';
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/core/logging/talker_service.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/decor_component.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

class BoardScene extends Component with HasGameReference<ApiaryGame> {
  BoardScene({
    required Board board,
    BoardRepository? repository,
    Random? random,
  }) : _board = BoardComponent(
         board: board,
         random: random,
         onChanged: repository == null
             ? null
             : (board) => _save(repository, board),
       );

  static const routeName = 'board';

  final _decor = DecorComponent();
  final BoardComponent _board;
  final _info = ItemInfoComponent();

  @override
  Future<void> onLoad() async {
    await addAll([_decor, _board, _info]);
    _board.selection.addListener(_showSelectedItem);
    _board.removal.addListener(_showSelectedItem);
    _board.itemChanged.addListener(_showSelectedItem);
    _info
      ..onRemovePressed = _board.removeSelected
      ..onUndoPressed = () => unawaited(_board.undoRemoval());
  }

  @override
  void onRemove() {
    _board.selection.removeListener(_showSelectedItem);
    _board.removal.removeListener(_showSelectedItem);
    _board.itemChanged.removeListener(_showSelectedItem);
    super.onRemove();
  }

  // Saves follow one another in the order of the actions (the database runs
  // its transactions in turn); a failure is logged and the game goes on.
  static void _save(BoardRepository repository, Board board) => unawaited(
    repository
        .save(board)
        .catchError(
          (Object error, StackTrace stackTrace) =>
              talker.handle(error, stackTrace, 'Saving the board failed'),
        ),
  );

  void _showSelectedItem() => _info.show(
    _board.selectedItem,
    removed: _board.removedItem,
  );

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final layout = game.layout;
    // Decor: the whole screen, under the system UI too.
    _decor.cover(layout.screen, board: layout.board);
    _board.position.setValues(layout.board.left, layout.board.top);
    final bar = layout.bottomBar;
    _info.place(
      Rect.fromLTRB(
        bar.left + ScreenLayout.bottomBarPadding,
        bar.top + ScreenLayout.bottomBarPadding,
        bar.right - ScreenLayout.bottomBarPadding,
        bar.bottom,
      ),
    );
  }
}
