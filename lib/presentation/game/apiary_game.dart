// 🐦 Flutter imports:
import 'package:flutter/painting.dart';

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/game.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';

class ApiaryGame extends FlameGame {
  ApiaryGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: referenceResolution.x,
          height: referenceResolution.y,
        ),
      );

  /// Pixel-art reference resolution (portrait), see `docs/DESIGN.md`.
  static final Vector2 referenceResolution = Vector2(240, 480);

  late final RouterComponent router;

  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    await world.add(
      router = RouterComponent(
        initialRoute: BoardScene.routeName,
        routes: {
          BoardScene.routeName: Route(BoardScene.new),
        },
      ),
    );
  }
}
