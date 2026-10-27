// 🎯 Dart imports:
import 'dart:async';
import 'dart:math';
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
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/hud/caption_button_component.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// The panel of the bottom bar that tells what the selected item is: its name
/// and level on a first line, a tip on what to do with it on the next three.
/// Without a selected item, it invites the player to touch one. Its parent
/// places it on the bottom bar of the screen layout with [place].
///
/// A removable item (not a queen) comes with a button on the right of the
/// panel to remove it; once it is removed, a button offers to undo it, with a
/// note in place of the item's details. The texts then leave room for the
/// button.
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

  /// The button's distance from the panel's right edge, and the gap between
  /// it and the texts.
  static const _buttonMargin = 4.0;
  static const _buttonGap = 2.0;

  /// The frame of the removed item, a panel with the item inside, and the
  /// room it leaves around it.
  static const _removedFrameSize = 24.0;
  static const double _removedFrameInset =
      (_removedFrameSize -
          ScreenLayout.cellSize +
          2 * ScreenLayout.itemMargin) /
      2;
  static const _firstLineTop = 3.0;
  static const _lineHeight = 8.0;

  /// The title and up to three lines of tip.
  static const _maxLines = 4;

  /// The font's native size: one font pixel is one game pixel.
  static const _fontSize = 8.0;

  static final TextPaint _titleText = _renderer(AppColors.honey);
  static final TextPaint _bodyText = _renderer(AppColors.paper);

  late final NineTileBoxComponent _panel;
  late final NineTileBox _panelBox;
  final List<TextComponent> _lineLabels = [
    for (var i = 0; i < _maxLines; i++)
      TextComponent(
        position: Vector2(_textLeft, _firstLineTop + i * _lineHeight),
        textRenderer: _bodyText,
      ),
  ];
  BoardItem? _item;
  final _shownButtons = <CaptionButtonComponent>{};
  BoardItem? _removed;
  NineTileBoxComponent? _removedFrame;
  BoardItem? _frameItem;
  late final CaptionButtonComponent _removeButton;
  late final CaptionButtonComponent _undoButton;

  /// Told when the player touches the remove or the undo button.
  VoidCallback? onRemovePressed;
  VoidCallback? onUndoPressed;

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
  ///
  /// With [removed], the panel shows that item, just removed, and offers to
  /// undo the removal instead.
  void show(BoardItem? item, {BoardItem? removed}) {
    _item = item;
    _removed = removed;
    _refresh();
  }

  /// Whether a button is on show, [removeButton] or [undoButton].
  @visibleForTesting
  bool get hasRemoveButton => _shownButtons.contains(_removeButton);
  @visibleForTesting
  bool get hasUndoButton => _shownButtons.contains(_undoButton);

  /// Whether the frame of a removed item is on show.
  @visibleForTesting
  bool get hasRemovedFrame => _removedFrame != null;

  /// The buttons, for tests to press.
  @visibleForTesting
  CaptionButtonComponent get removeButton => _removeButton;
  @visibleForTesting
  CaptionButtonComponent get undoButton => _undoButton;

  /// How many lines [item]'s texts (the invitation when `null`) take in a
  /// panel [panelWidth] wide. The panel holds two.
  @visibleForTesting
  static int lineCount(BoardItem? item, double panelWidth) =>
      _linesOf(item, panelWidth, removed: null).length;

  // The panel holds four lines. Each text breaks at the panel's width, which
  // depends on the screen, so a text takes as many lines as it needs: the
  // invitation fills both, an item's name and tip take one each when they fit.
  static List<(String, TextPaint)> _linesOf(
    BoardItem? item,
    double panelWidth, {
    required BoardItem? removed,
  }) {
    // The button takes the room of its caption, which is wider than itself.
    final caption = removed != null
        ? 'board.info.undo'.tr()
        : (item?.removable ?? false)
        ? 'board.info.remove'.tr()
        : null;
    final buttonSpace = caption == null
        ? 0
        : CaptionButtonComponent.widthWith(caption) +
              _buttonMargin +
              _buttonGap;
    final inset = removed == null
        ? _textLeft
        : _textLeft + _removedFrameSize + _textLeft;
    List<String> wrapped(String text, TextPaint paint) => wrap(
      text,
      panelWidth - inset - _textLeft - buttonSpace,
      (line) => paint.getLineMetrics(line).width,
    );
    return [
      if (removed != null)
        for (final line in wrapped('board.info.removed'.tr(), _bodyText))
          (line, _bodyText)
      else if (item == null)
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
    final lines = _linesOf(_item, size.x, removed: _removed);
    if (lines.length > _lineLabels.length) {
      talker.warning(
        'Item info text overflows the panel: ${lines.length} lines '
        'for ${_lineLabels.length}',
      );
    }
    final removed = _removed;
    // The removal note sits next to the frame, centered on it.
    final left = removed == null
        ? _textLeft
        : _textLeft + _removedFrameSize + _textLeft;
    final top = removed == null
        ? _firstLineTop
        : ((size.y - lines.length * _lineHeight) / 2).floorToDouble();
    for (final (index, label) in _lineLabels.indexed) {
      final (text, paint) = index < lines.length
          ? lines[index]
          : ('', _bodyText);
      label
        ..text = text
        ..textRenderer = paint
        ..position.setValues(left, top + index * _lineHeight);
    }
    _setShown(
      _removeButton,
      shown: removed == null && (_item?.removable ?? false),
    );
    _setShown(_undoButton, shown: removed != null);
    _showRemovedFrame(removed);
  }

  void _showRemovedFrame(BoardItem? removed) {
    final top = ((size.y - _removedFrameSize) / 2).floorToDouble();
    // The frame is only rebuilt for another item: a refresh that changes
    // nothing for it just keeps it centered.
    if (removed != null && removed == _frameItem) {
      _removedFrame!.position.y = top;
      return;
    }
    _removedFrame?.removeFromParent();
    _removedFrame = null;
    _frameItem = removed;
    if (removed == null) {
      return;
    }
    final frame = NineTileBoxComponent(
      nineTileBox: _panelBox,
      position: Vector2(_textLeft, top),
      size: Vector2.all(_removedFrameSize),
    );
    final icon = BoardComponent.componentOf(
      removed,
      position: Vector2.all(_removedFrameInset),
    );
    _removedFrame = frame;
    _mount(icon, on: frame);
    _mount(frame, on: this);
  }

  static void _mount(Component child, {required Component on}) =>
      unawaited(Future.sync(() => on.add(child)));

  void _setShown(CaptionButtonComponent button, {required bool shown}) {
    // Tracked here rather than read from the button: an add still waiting
    // for the next frame does not show in its mounted state.
    if (shown && _shownButtons.add(button)) {
      _mount(button, on: this);
    } else if (!shown && _shownButtons.remove(button)) {
      button.removeFromParent();
    }
    if (shown) {
      // The caption and the button, together, are centered on the panel's
      // height, at its right edge.
      final width = CaptionButtonComponent.widthWith(button.caption);
      button.position.setValues(
        size.x -
            _buttonMargin -
            width +
            max(0, CaptionButtonComponent.captionOverhang(button.caption)),
        ((size.y - CaptionButtonComponent.totalHeight) / 2).floorToDouble() +
            CaptionButtonComponent.captionFontSize +
            CaptionButtonComponent.captionGap,
      );
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
      // Placeholder species names, until the game data defines the real ones.
      Bee(:final family, :final level) =>
        'species.${family.name}.level_$level'.tr(),
      Hive() => 'item.hive.name'.tr(),
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
    Bee(:final family, :final level) =>
      level == family.maxLevel ? 'item.bee.tip_max'.tr() : 'item.bee.tip'.tr(),
    Hive() => 'item.hive.tip'.tr(),
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
    _panelBox = NineTileBox(
      Sprite(image),
      tileSize: _panelTileSize,
      destTileSize: _panelTileSize,
    );
    _panel = NineTileBoxComponent(nineTileBox: _panelBox, size: size);
    _removeButton = CaptionButtonComponent(
      normalImage: 'ui/delete_button.png',
      pressedImage: 'ui/delete_button_pressed.png',
      caption: 'board.info.remove'.tr(),
      onPressed: () => onRemovePressed?.call(),
    );
    _undoButton = CaptionButtonComponent(
      normalImage: 'ui/undo_button.png',
      pressedImage: 'ui/undo_button_pressed.png',
      caption: 'board.info.undo'.tr(),
      onPressed: () => onUndoPressed?.call(),
    );
    show(null);
    await addAll([_panel, ..._lineLabels]);
  }
}
