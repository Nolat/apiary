// 🎯 Dart imports:
import 'dart:math';
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter/painting.dart' show TextStyle;

// 📦 Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

// 🌎 Project imports:
import 'package:apiary/core/startup/startup.dart';
import 'package:apiary/core/startup/startup_step.dart';
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/presentation/components/board/bee_component.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/components/hud/progress_bar_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

/// The screen the game opens on while the app starts: a bee in the middle,
/// breathing in and out, with a loading bar under it and, under the bar, the
/// step of the [startup] being run. It calls [onFinished] once the last step
/// is done and the bar is full.
class SplashScene extends Component with HasGameReference<ApiaryGame> {
  SplashScene({required this.startup, required this.onFinished});

  static const routeName = 'splash';

  final Startup startup;

  /// Told once, when the bar is full on the last step.
  final VoidCallback onFinished;

  /// The bee is drawn [restScale] times its size, and swells to
  /// [breathScale] and back every [breathDuration] seconds.
  static const restScale = 3.0;
  static const breathScale = 3.3;
  static const breathDuration = 1.4;

  static const barWidth = 80.0;

  /// How much of the bar fills in a second at most: a step that is over in a
  /// flash still shows the bar moving.
  static const fillSpeed = 1.2;

  /// The bar and its label sit at the bottom of the safe area: the label's
  /// distance from its bottom edge, its height (the pixel font's) and its gap
  /// under the bar.
  static const _bottomMargin = 16.0;
  static const _labelHeight = 8.0;
  static const _labelGap = 6.0;

  final BeeComponent _bee = BeeComponent(family: Family.common)
    ..anchor = Anchor.center
    ..scale.setAll(restScale);
  final ProgressBarComponent _bar = ProgressBarComponent(width: barWidth);
  final TextComponent _label = TextComponent(
    textRenderer: TextPaint(
      style: const TextStyle(
        color: AppColors.paper,
        fontFamily: ItemInfoComponent.fontFamily,
        fontSize: 8,
        height: 1,
      ),
    ),
  );
  var _shown = 0.0;
  var _finished = false;

  /// What the label says.
  String get labelText => _label.text;

  /// How full the bar is shown, from 0 to 1.
  double get shownProgress => _shown;

  /// The bee, for tests to look at its breathing.
  BeeComponent get bee => _bee;

  /// The label's width, in game pixels.
  double get labelWidth => _label.size.x;

  @override
  Future<void> onLoad() async {
    await addAll([_bee, _bar, _label]);
    await _bee.add(
      ScaleEffect.to(
        Vector2.all(breathScale),
        EffectController(
          duration: breathDuration,
          curve: Curves.easeInOut,
          alternate: true,
          infinite: true,
        ),
      ),
    );
    startup.step.addListener(_showLabel);
    startup.failed.addListener(_showLabel);
    _showLabel();
  }

  @override
  void onRemove() {
    startup.step.removeListener(_showLabel);
    startup.failed.removeListener(_showLabel);
    super.onRemove();
  }

  void _showLabel() {
    _label.text =
        (startup.failed.value ? 'startup.failed' : startup.step.value.labelKey)
            .tr();
    _place();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final step = startup.step.value;
    if (_shown < step.progress) {
      _shown = min(step.progress, _shown + fillSpeed * dt);
      _bar.value = _shown;
    }
    if (!_finished && step == StartupStep.ready && _shown >= 1) {
      _finished = true;
      onFinished();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _place();
    }
  }

  // The bee in the middle of the screen, the bar and its label at the
  // bottom, in whole pixels, which keeps the sprites and the pixel font sharp.
  void _place() {
    final safe = game.safeArea;
    final x = safe.center.dx.floorToDouble();
    final labelTop = safe.bottom.floorToDouble() - _bottomMargin - _labelHeight;
    // The middle of the whole screen, not of the safe area: that is where the
    // native launch screen draws its bee, so the two line up.
    final screen = game.visibleArea.center;
    _bee.position.setValues(
      screen.dx.floorToDouble(),
      screen.dy.floorToDouble(),
    );
    _bar.position.setValues(
      x - barWidth / 2,
      labelTop - _labelGap - ProgressBarComponent.barHeight,
    );
    _label.position.setValues(
      (x - _label.size.x / 2).floorToDouble(),
      labelTop,
    );
  }
}
