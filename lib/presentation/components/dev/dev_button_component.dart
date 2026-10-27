// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/painting.dart' show Color, TextStyle;

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/events.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';

/// A tappable 9-slice panel with a label, for the dev screen: one sprite per
/// state, normal, pressed while a finger is down on it, and disabled (no taps
/// then). [label] is in English and not translated: players never see it.
class DevButtonComponent extends PositionComponent
    with TapCallbacks, HasGameReference {
  DevButtonComponent({
    required String label,
    required this.onPressed,
    super.size,
    super.position,
  }) : _label = TextComponent(
         text: label,
         anchor: Anchor.center,
         textRenderer: _labelText(AppColors.paper),
       );

  static const normalImage = 'ui/button.png';
  static const pressedImage = 'ui/button_pressed.png';
  static const disabledImage = 'ui/button_disabled.png';

  /// The sprites' border: a clear margin or rim, the outline and the light
  /// ring, 1 px each, the same on the three states. The 9-slice stretches the
  /// flat middle.
  static const _tileSize = 3;

  static final TextPaint _enabledText = _labelText(AppColors.paper);
  static final TextPaint _disabledText = _labelText(AppColors.surface);

  final FutureOr<void> Function() onPressed;
  final TextComponent _label;
  final NineTileBoxComponent _panel = NineTileBoxComponent();
  late final NineTileBox _normal;
  late final NineTileBox _pressed;
  late final NineTileBox _disabled;
  var _enabled = true;
  var _isDown = false;
  var _hasSprites = false;

  static TextPaint _labelText(Color color) => TextPaint(
    style: TextStyle(
      color: color,
      fontFamily: ItemInfoComponent.fontFamily,
      fontSize: 8,
      height: 1,
    ),
  );

  /// The label shown on the button.
  String get label => _label.text;

  /// Whether taps do anything; a disabled button shows its own sprite.
  bool get enabled => _enabled;
  set enabled(bool value) {
    _enabled = value;
    _isDown = false;
    _refresh();
  }

  /// Whether a finger is down on the button.
  bool get isPressed => _isDown;

  @override
  set size(Vector2 value) {
    super.size = value;
    if (isLoaded) {
      _panel.size = value;
      _label.position = value / 2;
    }
  }

  @override
  Future<void> onLoad() async {
    final images = await game.images.loadAll([
      normalImage,
      pressedImage,
      disabledImage,
    ]);
    NineTileBox slice(int index) => NineTileBox(
      Sprite(images[index]),
      tileSize: _tileSize,
      destTileSize: _tileSize,
    );
    _normal = slice(0);
    _pressed = slice(1);
    _disabled = slice(2);
    _hasSprites = true;
    _panel.size = size;
    _label.position = size / 2;
    _refresh();
    await addAll([_panel, _label]);
  }

  void _refresh() {
    if (!_hasSprites) {
      return;
    }
    _panel.nineTileBox = !_enabled
        ? _disabled
        : _isDown
        ? _pressed
        : _normal;
    _label.textRenderer = _enabled ? _enabledText : _disabledText;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_enabled) {
      _isDown = true;
      _refresh();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isDown = false;
    _refresh();
  }

  @override
  void onTapUp(TapUpEvent event) {
    final wasDown = _isDown;
    _isDown = false;
    _refresh();
    if (wasDown) {
      unawaited(Future.sync(onPressed));
    }
  }
}
