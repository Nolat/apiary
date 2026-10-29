// 🎯 Dart imports:
import 'dart:math';
import 'dart:ui' show PlatformDispatcher;

// 🐦 Flutter imports:
import 'package:flutter/widgets.dart' show EdgeInsets, MediaQuery;

// 📦 Package imports:
import 'package:flame/camera.dart';
import 'package:flame/components.dart' show Anchor;
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';

/// Full-screen viewport in game pixels: (0, 0) is the top-left corner of the
/// screen, [visibleArea] the whole screen and [safeArea] the part clear of
/// notches, Dynamic Island, camera holes and home indicator.
///
/// [pixelScale] (physical pixels per game pixel) is the largest at which the
/// safe area still holds [minimumSize]: on every iPhone the height limits, so
/// the safe area is exactly [minimumSize]`.y` game pixels tall and its width
/// follows the phone's shape; on wider screens (iPad, foldables) the width
/// limits and the safe area gets taller instead. Scenes lay out in bands within these bounds
/// (see `ScreenLayout`) and extend their decor over the whole [visibleArea].
///
/// The scale is usually fractional and art is drawn nearest-neighbor, so a
/// few game pixels are one physical pixel wider than the others (one column
/// in 40 at ×5.025): invisible at phone densities. Only images keep crisp
/// pixels: Impeller anti-aliases shapes, which get soft edges.
///
/// It sets the camera's viewfinder (top-left anchor, at the origin), which
/// must not be changed elsewhere.
class GameViewport extends Viewport implements ReadOnlyScaleProvider {
  GameViewport({
    required this.minimumSize,
    this.devicePixelRatio,
    this.safePadding,
    super.children,
  });

  /// The smallest safe area the layout needs, in game pixels.
  final Vector2 minimumSize;

  /// Overrides the device pixel ratio, otherwise read from the game widget's
  /// `MediaQuery` (or the platform's view before the widget is attached).
  final double Function()? devicePixelRatio;

  /// Overrides the safe area insets, in logical pixels, otherwise read from
  /// the game widget's `MediaQuery` (none before the widget is attached).
  final EdgeInsets Function()? safePadding;

  /// Physical pixels per game pixel, usually fractional.
  double get pixelScale => _pixelScale;
  double _pixelScale = 1;

  /// The whole screen, in game pixels.
  Rect get visibleArea => _visibleArea;
  Rect _visibleArea = Rect.zero;

  /// The part of the screen clear of notches and system UI, in game pixels:
  /// at least [minimumSize].
  Rect get safeArea => _safeArea;
  Rect _safeArea = Rect.zero;

  final Vector2 _virtualSize = Vector2.zero();
  final Vector2 _scaleVector = Vector2.all(1);
  Rect _clipRect = Rect.zero;

  @override
  Vector2 get virtualSize => _virtualSize;

  @override
  Vector2 get scale => _scaleVector;

  double _currentPixelRatio() {
    if (devicePixelRatio case final override?) {
      return override();
    }
    final context = findGame()?.buildContext;
    return (context == null
            ? null
            : MediaQuery.maybeDevicePixelRatioOf(context)) ??
        PlatformDispatcher.instance.implicitView?.devicePixelRatio ??
        1;
  }

  EdgeInsets _currentSafePadding() {
    if (safePadding case final override?) {
      return override();
    }
    final context = findGame()?.buildContext;
    return (context == null ? null : MediaQuery.maybePaddingOf(context)) ??
        EdgeInsets.zero;
  }

  @override
  void onLoad() => _handleResize(findGame()!.canvasSize);

  @override
  void onGameResize(Vector2 size) {
    if (isLoaded) {
      super.onGameResize(size);
    }
    _handleResize(size);
  }

  void _handleResize(Vector2 canvasSize) {
    final ratio = _currentPixelRatio();
    final padding = _currentSafePadding() * ratio;
    final physicalWidth = canvasSize.x * ratio;
    final physicalHeight = canvasSize.y * ratio;
    _pixelScale = min(
      (physicalWidth - padding.horizontal) / minimumSize.x,
      (physicalHeight - padding.vertical) / minimumSize.y,
    );

    _scaleVector.setAll(_pixelScale / ratio);
    _virtualSize.setValues(
      physicalWidth / _pixelScale,
      physicalHeight / _pixelScale,
    );
    _visibleArea = Rect.fromLTWH(0, 0, _virtualSize.x, _virtualSize.y);
    _safeArea = Rect.fromLTRB(
      padding.left / _pixelScale,
      padding.top / _pixelScale,
      (physicalWidth - padding.right) / _pixelScale,
      (physicalHeight - padding.bottom) / _pixelScale,
    );
    position.setZero();
    size = canvasSize;
    camera.viewfinder
      ..anchor = Anchor.topLeft
      ..position = Vector2.zero();
  }

  @override
  void onViewportResize() {
    _clipRect = Rect.fromLTWH(0, 0, size.x, size.y);
  }

  @override
  void clip(Canvas canvas) => canvas.clipRect(_clipRect, doAntiAlias: false);

  @override
  bool containsLocalPoint(Vector2 point) {
    final x = point.x;
    final y = point.y;
    return x >= 0 && y >= 0 && x <= virtualSize.x && y <= virtualSize.y;
  }

  @override
  void transformCanvas(Canvas canvas) =>
      canvas.scale(_scaleVector.x, _scaleVector.y);

  @override
  Vector2 globalToLocal(Vector2 point, {Vector2? output}) {
    final viewportPoint = super.globalToLocal(point, output: output);
    return viewportPoint..divide(_scaleVector);
  }

  @override
  Vector2 localToGlobal(Vector2 point, {Vector2? output}) {
    final scaled = (output?..setFrom(point)) ?? point.clone()
      ..multiply(_scaleVector);
    return super.localToGlobal(scaled, output: output);
  }
}
