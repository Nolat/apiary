// 🎯 Dart imports:
import 'dart:async';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState, KeyEventResult;

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:apiary/core/dev/dev_tools.dart';
import 'package:apiary/core/logging/talker_service.dart';
import 'package:apiary/core/startup/startup.dart';
import 'package:apiary/core/startup/startup_step.dart';
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/domain/orders/first_day_orders.dart';
import 'package:apiary/domain/orders/order.dart';
import 'package:apiary/domain/orders/order_repository.dart';
import 'package:apiary/presentation/game/energy_notifier.dart';
import 'package:apiary/presentation/game/game_viewport.dart';
import 'package:apiary/presentation/game/layout_debug_overlay.dart';
import 'package:apiary/presentation/game/screen_layout.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';
import 'package:apiary/presentation/scenes/dev_scene.dart';
import 'package:apiary/presentation/scenes/splash_scene.dart';

class ApiaryGame extends FlameGame with KeyboardEvents {
  ApiaryGame({
    this._boardRepository,
    this._orderRepository,
    this._devTools,
    this.startup,
    this._random,
    ProviderContainer? container,
  }) : _ownsContainer = container == null,
       container = container ?? ProviderContainer(),
       super(
         camera: CameraComponent(
           viewport: GameViewport(minimumSize: minimumSize),
         ),
       );

  /// The launch to run behind the splash screen, which the game opens on; it
  /// brings the board repository and the dev tools, once it is done. `null`
  /// opens straight on the board (most tests).
  final Startup? startup;

  /// The Riverpod state the game shares with the app (the energy gauge): the
  /// app's own container, or a private one when none is given (tests).
  final ProviderContainer container;
  final bool _ownsContainer;

  /// The energy gauge, which the board spends and the HUD shows.
  EnergyNotifier get energy => container.read(energyProvider.notifier);

  /// What the energy gauge holds now.
  Energy get energyValue => container.read(energyProvider);

  // Whether the energy may be read: not before the launch has registered the
  // services it saves and recharges with.
  var _energyReady = false;

  // Seeds the hives' draws; `null` for an unseeded one (tests seed it).
  final Random? _random;

  BoardRepository? _boardRepository;
  OrderRepository? _orderRepository;
  DevTools? _devTools;

  /// Where the board is saved and restored; `null` plays on the starting
  /// board without saving, as in most tests.
  BoardRepository? get boardRepository => _boardRepository;

  /// Where the orders of the day are saved and restored; `null` plays on the
  /// first day's orders without saving, as in most tests.
  OrderRepository? get orderRepository => _orderRepository;

  /// What the dev screen does and what opens it; `null` has no dev screen
  /// (most tests).
  DevTools? get devTools => _devTools;

  /// The smallest safe area the game lays out in, in game pixels: 140 wide
  /// (the board's), 285 tall (see `docs/DESIGN.md`).
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

  // What the board scene opens on, set before it is shown.
  Board _board = Board.initial();
  List<Order> _orders = FirstDayOrders.orders;

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

  // A first game gets the first day's orders, saved from then on so that the
  // day keeps them. A broken database must not keep the game from opening.
  Future<List<Order>> _loadOrders() async {
    final repository = orderRepository;
    if (repository == null) {
      return FirstDayOrders.orders;
    }
    try {
      final saved = await repository.load();
      if (saved != null) {
        return saved;
      }
      await repository.save(FirstDayOrders.orders);
      // Any failure of the storage, whatever its type, falls back the same way.
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      talker.handle(error, stackTrace, 'Loading the orders failed');
    }
    return FirstDayOrders.orders;
  }

  Future<void> _mountRouter({required String initialRoute}) async {
    await world.add(
      router = RouterComponent(
        initialRoute: initialRoute,
        routes: {
          BoardScene.routeName: Route(
            () => BoardScene(
              board: _board,
              orders: _orders,
              repository: _boardRepository,
              random: _random,
              energy: energy,
            ),
          ),
          if (startup case final startup?)
            SplashScene.routeName: Route(
              () => SplashScene(
                startup: startup,
                onFinished: () => router.pushReplacementNamed(
                  BoardScene.routeName,
                ),
              ),
            ),
          // Without dev tools yet (the launch brings them), the route exists
          // but nothing opens it.
          DevScene.routeName: Route(() => DevScene(devTools: _devTools!)),
        },
      ),
    );
  }

  // Runs the launch behind the splash screen, which moves on to the board
  // once the last step is reported and its bar is full.
  Future<void> _start(Startup startup) async {
    try {
      final services = await startup.run();
      _boardRepository = services.boardRepository;
      _orderRepository = services.orderRepository;
      _devTools = services.devTools;
      _listenToShakes();
      startup.step.value = StartupStep.board;
      _board = await _loadBoard() ?? Board.initial();
      _orders = await _loadOrders();
      _energyReady = true;
      await energy.load();
      // The trusted time can take a while (or never come, offline): the game
      // opens without it and credits the recharge when it arrives.
      unawaited(energy.sync());
      startup.step.value = StartupStep.ready;
      // Any failure of the launch, whatever its type, is shown the same way.
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      talker.handle(error, stackTrace, 'Starting the game failed');
      startup.failed.value = true;
    }
  }

  void _listenToShakes() {
    _shakes = devTools?.shakes.listen((_) => toggleDevScreen());
  }

  @override
  Future<void> onLoad() async {
    if (startup case final startup?) {
      // The launch goes on while the splash screen shows: waiting for it here
      // would keep the game from drawing anything.
      await _mountRouter(initialRoute: SplashScene.routeName);
      unawaited(_start(startup));
    } else {
      // Only a first game starts on the starting board.
      _board = await _loadBoard() ?? Board.initial();
      _orders = await _loadOrders();
      _energyReady = true;
      await energy.load();
      unawaited(energy.sync());
      await _mountRouter(initialRoute: BoardScene.routeName);
      _listenToShakes();
    }
    if (LayoutDebugOverlay.enabled) {
      await camera.viewfinder.add(LayoutDebugOverlay());
    }
  }

  // A phone that slept in the background may not have counted that time on the
  // stopwatch the trusted clock runs on: coming back, ask the server again, so
  // the recharge of the time away is credited in full.
  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    if (state == AppLifecycleState.resumed && _energyReady) {
      unawaited(energy.sync());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_energyReady) {
      energy.update(dt);
    }
  }

  @override
  void onRemove() {
    unawaited(_shakes?.cancel());
    if (_ownsContainer) {
      container.dispose();
    }
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
    _board = Board.initial();
    _orders = FirstDayOrders.orders;
    energy.reset();
    await _mountRouter(initialRoute: BoardScene.routeName);
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
