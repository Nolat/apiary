// 🎯 Dart imports:
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/painting.dart' show TextStyle;

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/core/dev/dev_tools.dart';
import 'package:apiary/core/logging/talker_service.dart';
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/presentation/components/board/decor_component.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/components/dev/dev_button_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

/// The dev screen, opened by shaking the phone or by Cmd+Shift+D (see
/// `ApiaryGame`). One button per action of [DevTools]; add new ones to
/// [_buttons]. Texts are in English and not translated: players never see it.
class DevScene extends Component with HasGameReference<ApiaryGame> {
  DevScene({required this.devTools});

  static const routeName = 'dev';

  final DevTools devTools;

  static const _margin = 8.0;
  static const _buttonHeight = 16.0;
  static const _gap = 4.0;
  static const _maxButtonWidth = 120.0;

  final _decor = DecorComponent();
  final TextComponent _title = TextComponent(
    text: 'DEV TOOLS',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: AppColors.honey,
        fontFamily: ItemInfoComponent.fontFamily,
        fontSize: 8,
        height: 1,
      ),
    ),
  );
  final TextComponent _status = TextComponent(
    textRenderer: TextPaint(
      style: const TextStyle(
        color: AppColors.paper,
        fontFamily: ItemInfoComponent.fontFamily,
        fontSize: 8,
        height: 1,
      ),
    ),
  );
  late final List<DevButtonComponent> _buttons;
  var _busy = false;

  /// The status line under the buttons; empty when there is nothing to say.
  String get statusText => _status.text;

  /// The buttons, top to bottom: each action, then Close.
  List<DevButtonComponent> get buttons => List.unmodifiable(_buttons);

  @override
  Future<void> onLoad() async {
    _buttons = [
      DevButtonComponent(label: 'Reset database', onPressed: _resetDatabase),
      DevButtonComponent(label: 'Close', onPressed: game.router.pop),
    ];
    await addAll([_decor, _title, _status, ..._buttons]);
    _place();
  }

  Future<void> _resetDatabase() async {
    // A second tap while the first runs would erase twice for nothing.
    if (_busy) {
      return;
    }
    _busy = true;
    for (final button in _buttons) {
      button.enabled = false;
    }
    try {
      await devTools.resetDatabase();
      talker.info('Database reset from the dev screen');
      await game.restartFromScratch();
      // Any failure of the storage, whatever its type, is shown the same way.
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      talker.handle(error, stackTrace, 'Resetting the database failed');
      _status.text = 'Reset failed, see logs';
    } finally {
      _busy = false;
      for (final button in _buttons) {
        button.enabled = true;
      }
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _place();
    }
  }

  void _place() {
    final layout = game.layout;
    _decor.cover(layout.screen, board: layout.board);
    final safe = layout.hud;
    final width = min(_maxButtonWidth, safe.width - 2 * _margin);
    final left = (safe.left + (safe.width - width) / 2).floorToDouble();
    var top = safe.top + _margin;
    _title.position.setValues(left, top);
    top += 8 + _margin;
    for (final button in _buttons) {
      button
        ..position.setValues(left, top)
        ..size = Vector2(width, _buttonHeight);
      top += _buttonHeight + _gap;
    }
    _status.position.setValues(left, top + _gap);
  }
}
