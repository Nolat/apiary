// 🎯 Dart imports:
import 'dart:async';
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/painting.dart' show TextStyle;

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';

/// The message that tells the board is full: honey-colored pixel text with a
/// dark outline, centered on the middle of its parent. [show] pops it in
/// small and overshooting, keeps it for [holdDuration], then fades it out.
/// Showing it again while it is up starts over.
class BoardFullBannerComponent extends PositionComponent
    implements OpacityProvider {
  BoardFullBannerComponent({required this.message})
    : super(anchor: Anchor.center, priority: BoardComponent.bannerPriority) {
    _measure();
  }

  /// What the banner says, translated.
  final String message;

  /// How long the pop in and the fade out take, and how long the banner stays
  /// whole in between.
  static const popDuration = 0.22;
  static const popStartScale = 0.6;
  static const holdDuration = 1.6;
  static const fadeDuration = 0.3;

  static TextPaint _renderer(Color color) => TextPaint(
    style: TextStyle(
      color: color,
      fontFamily: ItemInfoComponent.fontFamily,
      fontSize: 8,
      height: 1,
    ),
  );

  // The outline is the text drawn on the four sides of the fill, a whole
  // pixel away: pixel art has no vector stroke.
  static const _outline = [
    Offset(-1, 0),
    Offset(1, 0),
    Offset(0, -1),
    Offset(0, 1),
  ];

  double _opacity = 0;

  @override
  double get opacity => _opacity;

  @override
  set opacity(double value) => _opacity = value.clamp(0, 1);

  /// Whether the banner can be seen.
  bool get isShown => _opacity > 0;

  void _measure() {
    final width = _renderer(AppColors.honey).getLineMetrics(message).width;
    // Room for the outline all around.
    size = Vector2(width.ceilToDouble() + 6, 12);
  }

  /// Pops the banner in, at the middle of [center], in its parent's
  /// coordinates.
  void show(Vector2 center) {
    for (final effect in children.whereType<Effect>().toList()) {
      effect
        ..pause()
        ..removeFromParent();
    }
    position.setFrom(center);
    opacity = 1;
    scale.setAll(popStartScale);
    unawaited(
      addAll([
        ScaleEffect.to(
          Vector2.all(1),
          EffectController(duration: popDuration, curve: Curves.easeOutBack),
        ),
        OpacityEffect.fadeOut(
          DelayedEffectController(
            LinearEffectController(fadeDuration),
            delay: popDuration + holdDuration,
          ),
        ),
      ]),
    );
  }

  @override
  void render(Canvas canvas) {
    if (!isShown) {
      return;
    }
    // A dark plate keeps the text legible over the board's honey items.
    canvas.drawRect(
      size.toRect(),
      Paint()..color = AppColors.background.withValues(alpha: 0.85 * _opacity),
    );
    // A text has no paint to dim: its colors carry the opacity.
    final outline = _renderer(AppColors.background.withValues(alpha: _opacity));
    final fill = _renderer(AppColors.honey.withValues(alpha: _opacity));
    for (final offset in _outline) {
      outline.render(canvas, message, Vector2(3 + offset.dx, 2 + offset.dy));
    }
    fill.render(canvas, message, Vector2(3, 2));
  }
}
