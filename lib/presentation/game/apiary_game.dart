// 🐦 Flutter imports:
import 'package:flutter/painting.dart';

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/game.dart';

// 🌎 Project imports:
import 'package:apiary/core/logging/talker_service.dart';
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/presentation/game/game_viewport.dart';
import 'package:apiary/presentation/game/layout_debug_overlay.dart';
import 'package:apiary/presentation/game/screen_layout.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';

class ApiaryGame extends FlameGame {
  ApiaryGame({this.boardRepository})
    : super(
        camera: CameraComponent(
          viewport: GameViewport(minimumSize: minimumSize),
        ),
      );

  /// Where the board is saved and restored; `null` plays on the starting
  /// board without saving, as in most tests.
  final BoardRepository? boardRepository;

  /// The smallest safe area the game lays out in, in game pixels: 140 wide
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

  // A broken database must not keep the game from opening.
  Future<Board?> _loadBoard() async {
    try {
      return await boardRepository?.load();
      // Any failure of the storage, whatever its type, falls back the same way.
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      talker.handle(error, stackTrace, 'Loading the board failed');
      return null;
    }
  }

  @override
  Future<void> onLoad() async {
    // Only a first game starts on the starting board.
    final board = await _loadBoard() ?? Board.initial();
    await world.add(
      router = RouterComponent(
        initialRoute: BoardScene.routeName,
        routes: {
          BoardScene.routeName: Route(
            () => BoardScene(board: board, repository: boardRepository),
          ),
        },
      ),
    );
    if (LayoutDebugOverlay.enabled) {
      await camera.viewfinder.add(LayoutDebugOverlay());
    }
  }
}
