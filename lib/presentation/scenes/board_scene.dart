// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

class BoardScene extends Component with HasGameReference<ApiaryGame> {
  static const routeName = 'board';

  final _background = RectangleComponent(
    paint: Paint()..color = AppColors.surface,
  );

  @override
  Future<void> onLoad() async {
    await add(_background);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Decor: the whole screen, under the system UI too.
    final visibleArea = game.visibleArea;
    _background
      ..position.setValues(visibleArea.left, visibleArea.top)
      ..size.setValues(visibleArea.width, visibleArea.height);
  }
}
