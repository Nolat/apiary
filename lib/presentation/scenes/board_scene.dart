// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

class BoardScene extends Component {
  static const routeName = 'board';

  @override
  Future<void> onLoad() async {
    await add(
      RectangleComponent(
        size: ApiaryGame.referenceResolution,
        paint: Paint()..color = AppColors.surface,
      ),
    );
  }
}
