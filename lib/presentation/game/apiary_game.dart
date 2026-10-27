// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

// 🌎 Project imports:
import 'package:apiary/core/dev/dev_tools.dart';
import 'package:apiary/core/logging/talker_service.dart';
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/presentation/game/game_viewport.dart';
import 'package:apiary/presentation/game/layout_debug_overlay.dart';
import 'package:apiary/presentation/game/screen_layout.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';
import 'package:apiary/presentation/scenes/dev_scene.dart';

class ApiaryGame extends FlameGame with KeyboardEvents {
  ApiaryGame({this.boardRepository, this.devTools})
    : super(
        camera: CameraComponent(
          viewport: GameViewport(minimumSize: minimumSize),
        ),
      );

  /// Where the board is saved and restored; `null` plays on the starting
  /// board without saving, as in most tests.
  final BoardRepository? boardRepository;

  /// What the dev screen does and what opens it; `null` has no dev screen
  /// (most tests).
  final DevTools? devTools;

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

  late RouterComponent router;
  StreamSubscription<void>? _shakes;

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

  Future<void> _mountRouter(Board board) async {
    await world.add(
      router = RouterComponent(
        initialRoute: BoardScene.routeName,
        routes: {
          BoardScene.routeName: Route(
            () => BoardScene(board: board, repository: boardRepository),
          ),
          if (devTools case final devTools?)
            DevScene.routeName: Route(() => DevScene(devTools: devTools)),
        },
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    // Only a first game starts on the starting board.
    await _mountRouter(await _loadBoard() ?? Board.initial());
    if (LayoutDebugOverlay.enabled) {
      await camera.viewfinder.add(LayoutDebugOverlay());
    }
    _shakes = devTools?.shakes.listen((_) => toggleDevScreen());
  }

  @override
  void onRemove() {
    unawaited(_shakes?.cancel());
    super.onRemove();
  }

  /// Opens the dev screen over the current scene, or closes it when it is
  /// already open. Does nothing without [devTools].
  void toggleDevScreen() {
    if (devTools == null) {
      return;
    }
    if (router.currentRoute.name == DevScene.routeName) {
      router.pop();
    } else {
      router.pushNamed(DevScene.routeName);
    }
  }

  /// Drops the game in progress for a first game on the starting board, as
  /// after a fresh install. The saved board is not touched: the caller has
  /// emptied it already.
  Future<void> restartFromScratch() async {
    router.removeFromParent();
    await _mountRouter(Board.initial());
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isShortcut =
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyD &&
        keysPressed.any(
          (key) =>
              key == LogicalKeyboardKey.metaLeft ||
              key == LogicalKeyboardKey.metaRight,
        ) &&
        keysPressed.any(
          (key) =>
              key == LogicalKeyboardKey.shiftLeft ||
              key == LogicalKeyboardKey.shiftRight,
        );
    if (isShortcut && devTools != null) {
      toggleDevScreen();
      return KeyEventResult.handled;
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
