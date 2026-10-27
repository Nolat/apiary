// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// A round red badge with a white cross, which fades while a finger is down on
/// it. It carries no caption: the item it sits on says what it closes. The
/// touch area is wider than the badge, which is small.
class CloseButtonComponent extends PositionComponent
    with TapCallbacks, HasGameReference {
  CloseButtonComponent({required this.onPressed, super.position})
    : super(size: Vector2.all(touchSize));

  static const image = 'ui/close_button.png';

  /// The sprite is this many game pixels wide and tall.
  static const buttonSize = 11.0;

  /// The touch area, centered on the sprite.
  static const touchSize = 15.0;

  /// How opaque the cross stays while it is pressed.
  static const pressedOpacity = 0.6;

  final void Function() onPressed;
  final _icon = SpriteComponent(
    size: Vector2.all(buttonSize),
    position: Vector2.all((touchSize - buttonSize) / 2),
  );
  var _isDown = false;

  /// Whether a finger is down on the button.
  bool get isPressed => _isDown;

  @override
  Future<void> onLoad() async {
    _icon
      ..sprite = Sprite(await game.images.load(image))
      // Nearest-neighbor, so pixels stay sharp at fractional scales.
      ..paint = (Paint()..filterQuality = FilterQuality.none);
    await add(_icon);
  }

  void _setDown({required bool down}) {
    _isDown = down;
    _icon.opacity = down ? pressedOpacity : 1;
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
