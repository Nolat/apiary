// 🎯 Dart imports:
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/painting.dart' show TextStyle;

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/events.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/components/pixel_paint.dart';

/// A square icon button, one sprite per state (normal, and pressed while a
/// finger is down on it), with a [caption] right above it, centered on it and
/// wider than it. The caption is a translated text the caller gives, since the
/// icon alone does not say what the button does. Only the square takes
/// touches; the caption overhangs it, by [captionOverhang] on each side.
class CaptionButtonComponent extends PositionComponent
    with TapCallbacks, HasGameReference {
  CaptionButtonComponent({
    required this.normalImage,
    required this.pressedImage,
    required String caption,
    required this.onPressed,
    super.position,
  }) : _caption = TextComponent(
         text: caption,
         anchor: Anchor.bottomLeft,
         position: Vector2(
           -captionOverhang(caption),
           -captionGap,
         ),
         textRenderer: captionText,
       ),
       super(size: Vector2.all(buttonSize));

  /// The sprites are this many game pixels wide and tall.
  static const buttonSize = 15.0;

  /// The caption's font size, the font's native one, and its distance above
  /// the button.
  static const captionFontSize = 8.0;
  static const captionGap = 1.0;

  /// How far a [caption] sticks out of the button on each side; negative when
  /// it is narrower. Whole pixels, to keep the text sharp.
  static double captionOverhang(String caption) =>
      ((captionText.getLineMetrics(caption).width - buttonSize) / 2)
          .roundToDouble();

  /// The width of the caption and the button together: whichever is wider.
  static double widthWith(String caption) =>
      buttonSize + 2 * max(0, captionOverhang(caption));

  /// The caption and the button together are this tall.
  static const double totalHeight = captionFontSize + captionGap + buttonSize;

  static final TextPaint captionText = TextPaint(
    style: const TextStyle(
      color: AppColors.paper,
      fontFamily: ItemInfoComponent.fontFamily,
      fontSize: captionFontSize,
      height: 1,
    ),
  );

  final String normalImage;
  final String pressedImage;
  final void Function() onPressed;
  final TextComponent _caption;
  final _icon = SpriteComponent(size: Vector2.all(buttonSize));
  late final Sprite _normal;
  late final Sprite _pressed;
  var _isDown = false;

  /// The text over the button.
  String get caption => _caption.text;
  set caption(String value) {
    _caption
      ..text = value
      ..position.x = -captionOverhang(value);
  }

  /// Whether a finger is down on the button.
  bool get isPressed => _isDown;

  @override
  Future<void> onLoad() async {
    final images = await game.images.loadAll([normalImage, pressedImage]);
    _normal = Sprite(images[0]);
    _pressed = Sprite(images[1]);
    _icon
      ..sprite = _normal
      // Nearest-neighbor, so pixels stay sharp at fractional scales.
      ..paint = (pixelPaint());
    await addAll([_icon, _caption]);
  }

  void _setDown({required bool down}) {
    _isDown = down;
    _icon.sprite = down ? _pressed : _normal;
  }

  @override
  void onTapDown(TapDownEvent event) => _setDown(down: true);

  @override
  void onTapCancel(TapCancelEvent event) => _setDown(down: false);

  @override
  void onTapUp(TapUpEvent event) {
    _setDown(down: false);
    onPressed();
  }
}
