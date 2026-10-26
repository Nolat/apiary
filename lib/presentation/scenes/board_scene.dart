// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/decor_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

class BoardScene extends Component with HasGameReference<ApiaryGame> {
  static const routeName = 'board';

  final _decor = DecorComponent();
  final _board = BoardComponent(board: Board.initial());

  @override
  Future<void> onLoad() async {
    await addAll([_decor, _board]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final layout = game.layout;
    // Decor: the whole screen, under the system UI too.
    _decor.cover(layout.screen, board: layout.board);
    _board.position.setValues(layout.board.left, layout.board.top);
  }
}
