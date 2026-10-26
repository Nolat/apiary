// 🎯 Dart imports:
import 'dart:math';

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

/// Scales a component up by [amplitude] and back to its size, around its
/// center, wherever its anchor is: a pop in and out. It leaves the component
/// exactly as it found it.
class BounceEffect extends ComponentEffect<PositionComponent> {
  BounceEffect({required double duration, this.amplitude = 0.2})
    : super(EffectController(duration: duration));

  /// How much bigger the component gets at the peak: 0.2 is 20% bigger.
  final double amplitude;

  late final Vector2 _home;

  @override
  void onStart() {
    super.onStart();
    _home = target.position.clone();
  }

  @override
  void apply(double progress) {
    final factor = 1 + amplitude * sin(pi * progress);
    target
      ..scale.setAll(factor)
      ..position.setFrom(_home - target.size * ((factor - 1) / 2));
  }

  @override
  void onFinish() {
    target
      ..scale.setAll(1)
      ..position.setFrom(_home);
    super.onFinish();
  }
}
