// 🐦 Flutter imports:
import 'package:flutter/painting.dart';

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/game.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/presentation/game/layout_debug_overlay.dart';
import 'package:apiary/presentation/game/screen_layout.dart';
import 'package:apiary/presentation/game/game_viewport.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';

class ApiaryGame extends FlameGame {
  ApiaryGame()
    : super(
        camera: CameraComponent(
          viewport: GameViewport(minimumSize: minimumSize),
        ),
      );

  /// The smallest safe area the game lays out in, in game pixels: 224 wide
  /// (the board's width, see `docs/DESIGN.md`), the height varying above.
  static final Vector2 minimumSize = Vector2(
    ScreenLayout.minimumSafeSize.width,
    ScreenLayout.minimumSafeSize.height,
  );

  GameViewport get gameViewport => camera.viewport as GameViewport;

  /// The whole screen, in game pixels; scenes extend their decor over it.
  Rect get visibleArea => gameViewport.visibleArea;

  /// The part of the screen clear of notches and system UI, in game pixels.
  Rect get safeArea => gameViewport.safeArea;

  /// Where each band of the screen goes; scenes read it in `onGameResize`.
  ScreenLayout get layout =>
      ScreenLayout.compute(screen: visibleArea, safeArea: safeArea);

  late final RouterComponent router;

  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    await world.add(
      router = RouterComponent(
        initialRoute: BoardScene.routeName,
        routes: {
          BoardScene.routeName: Route(BoardScene.new),
        },
      ),
    );
    if (LayoutDebugOverlay.enabled) {
      await camera.viewfinder.add(LayoutDebugOverlay());
    }
  }
}
