// 🐦 Flutter imports:
import 'package:flutter/animation.dart' show Curve, Curves;

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

/// Scales a component from [from] to [to] times its size, around its center
/// wherever its anchor is, along its curve (one that overshoots makes it
/// bounce). Unlike Flame's `ScaleEffect`, the component stays centered on its
/// cell, and may slide it too. It ends scaled by exactly [to].
class CenteredScaleEffect extends ComponentEffect<PositionComponent> {
  CenteredScaleEffect({
    required this.from,
    required this.to,
    required double duration,
    Curve curve = Curves.linear,
    this.slideTo,
    super.onComplete,
  }) : super(
         EffectController(
           duration: duration,
           curve: curve,
         ),
       );

  final double from;
  final double to;

  /// Where the component's unscaled position ends up, when it also moves.
  final Vector2? slideTo;

  // What this effect has added to the component's position so far, so that
  // anything else moving it meanwhile, a finger dragging it, is kept.
  final _applied = Vector2.zero();
  late final Vector2 _slideBy;

  @override
  void onMount() {
    super.onMount();
    final end = slideTo;
    _slideBy = end == null ? Vector2.zero() : end - target.position;
  }

  @override
  void onStart() {
    super.onStart();
    _place(from, 0);
  }

  @override
  void apply(double progress) =>
      _place(from + (to - from) * progress, progress);

  @override
  void onFinish() {
    _place(to, 1);
    super.onFinish();
  }

  void _place(double factor, double progress) {
    final applied = _slideBy * progress - target.size * ((factor - 1) / 2);
    target
      ..scale.setAll(factor)
      ..position.add(applied - _applied);
    _applied.setFrom(applied);
  }
}
