// 🎯 Dart imports:
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/painting.dart' show TextStyle;

// 📦 Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/core/logging/talker_service.dart';
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/domain/board/board_item.dart';

/// The panel of the bottom bar that tells what the selected item is: its name
/// and level on a first line, a tip on what to do with it on the next three.
/// Without a selected item, it invites the player to touch one. Its parent
/// places it on the bottom bar of the screen layout with [place].
///
/// Texts are in the pixel font: four lines fill the panel. The title is
/// honey-colored, the invitation and tip off-white.
class ItemInfoComponent extends PositionComponent with HasGameReference {
  static const fontFamily = 'BoldPixels';
  static const panelImage = 'ui/bordered_panel.png';

  /// The panel sprite's border: the outline, shadow and light rings, each 1 px.
  /// The 9-slice stretches the flat middle.
  static const _panelTileSize = 3;
  static const _textLeft = 4.0;
  static const _firstLineTop = 3.0;
  static const _lineHeight = 8.0;

  /// The title and up to three lines of tip.
  static const _maxLines = 4;

  /// The font's native size: one font pixel is one game pixel.
  static const _fontSize = 8.0;

  static final TextPaint _titleText = _renderer(AppColors.honey);
  static final TextPaint _bodyText = _renderer(AppColors.paper);

  late final NineTileBoxComponent _panel;
  final List<TextComponent> _lineLabels = [
    for (var i = 0; i < _maxLines; i++)
      TextComponent(
        position: Vector2(_textLeft, _firstLineTop + i * _lineHeight),
        textRenderer: _bodyText,
      ),
  ];
  BoardItem? _item;

  static TextPaint _renderer(Color color) => TextPaint(
    style: TextStyle(
      color: color,
      fontFamily: fontFamily,
      fontSize: _fontSize,
      height: 1,
    ),
  );

  /// Breaks [text] into lines of at most [maxWidth] as given by [measure],
  /// at spaces; a word wider than [maxWidth] stays alone on its line.
  static List<String> wrap(
    String text,
    double maxWidth,
    double Function(String) measure,
  ) {
    // A panel not placed yet has no width to wrap to: leave the text whole.
    if (maxWidth <= 0) {
      return [text];
    }
    final lines = <String>[];
    var line = '';
    for (final word in text.split(' ')) {
      final candidate = line.isEmpty ? word : '$line $word';
      if (line.isNotEmpty && measure(candidate) > maxWidth) {
        lines.add(line);
        line = word;
      } else {
        line = candidate;
      }
    }
    if (line.isNotEmpty) {
      lines.add(line);
    }
    return lines;
  }

  /// First line of the panel: the item's name and level, or the invitation to
  /// select one.
  String get titleText => _lineLabels[0].text;

  /// Second line: what the selected item does, or the rest of a text that
  /// wraps.
  String get tipText => _lineLabels
      .skip(1)
      .map((label) => label.text)
      .where((text) => text.isNotEmpty)
      .join(' ');

  /// Describes [item], or invites to select one when it is `null`.
  void show(BoardItem? item) {
    _item = item;
    _refresh();
  }

  /// How many lines [item]'s texts (the invitation when `null`) take in a
  /// panel [panelWidth] wide. The panel holds two.
  @visibleForTesting
  static int lineCount(BoardItem? item, double panelWidth) =>
      _linesOf(item, panelWidth).length;

  // The panel holds four lines. Each text breaks at the panel's width, which
  // depends on the screen, so a text takes as many lines as it needs: the
  // invitation fills both, an item's name and tip take one each when they fit.
  static List<(String, TextPaint)> _linesOf(
    BoardItem? item,
    double panelWidth,
  ) {
    List<String> wrapped(String text, TextPaint paint) => wrap(
      text,
      panelWidth - 2 * _textLeft,
      (line) => paint.getLineMetrics(line).width,
    );
    return [
      if (item == null)
        for (final line in wrapped('board.info.empty'.tr(), _bodyText))
          (line, _bodyText)
      else ...[
        for (final line in wrapped(_titleOf(item), _titleText))
          (line, _titleText),
        for (final line in wrapped(_tipOf(item), _bodyText)) (line, _bodyText),
      ],
    ];
  }

  void _refresh() {
    final lines = _linesOf(_item, size.x);
    if (lines.length > _lineLabels.length) {
      talker.warning(
        'Item info text overflows the panel: ${lines.length} lines '
        'for ${_lineLabels.length}',
      );
    }
    for (final (index, label) in _lineLabels.indexed) {
      final (text, paint) = index < lines.length
          ? lines[index]
          : ('', _bodyText);
      label
        ..text = text
        ..textRenderer = paint;
    }
  }

  static String _titleOf(BoardItem item) {
    final name = switch (item) {
      Queen(:final family) => 'item.queen.name'.tr(
        namedArgs: {'family': 'family.${family.name}'.tr()},
      ),
      Larva(:final family) => 'item.larva.name'.tr(
        namedArgs: {'family': 'family.${family.name}'.tr()},
      ),
    };
    final level = item.level;
    return level == null
        ? name
        : 'board.info.title_level'.tr(
            namedArgs: {'name': name, 'level': '$level'},
          );
  }

  static String _tipOf(BoardItem item) => switch (item) {
    Queen() => 'item.queen.tip'.tr(),
    Larva() => 'item.larva.tip'.tr(),
  };

  /// Covers [area], in the parent's coordinates.
  void place(Rect area) {
    position.setValues(area.left, area.top);
    size.setValues(area.width, area.height);
    if (isLoaded) {
      _panel.size.setFrom(size);
      _refresh();
    }
  }

  @override
  Future<void> onLoad() async {
    final image = await game.images.load(panelImage);
    _panel = NineTileBoxComponent(
      nineTileBox: NineTileBox(
        Sprite(image),
        tileSize: _panelTileSize,
        destTileSize: _panelTileSize,
      ),
      size: size,
    );
    show(null);
    await addAll([_panel, ..._lineLabels]);
  }
}
