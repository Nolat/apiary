// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/decor_component.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

class BoardScene extends Component with HasGameReference<ApiaryGame> {
  static const routeName = 'board';

  final _decor = DecorComponent();
  final _board = BoardComponent(board: Board.initial());
  final _info = ItemInfoComponent();

  @override
  Future<void> onLoad() async {
    await addAll([_decor, _board, _info]);
    _board.selection.addListener(_showSelectedItem);
  }

  @override
  void onRemove() {
    _board.selection.removeListener(_showSelectedItem);
    super.onRemove();
  }

  void _showSelectedItem() => _info.show(_board.selectedItem);

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
