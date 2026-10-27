// 🎯 Dart imports:
import 'dart:async';
import 'dart:math';
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/painting.dart' show TextStyle;

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/presentation/components/board/bounce_effect.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/components/hud/pixel_panel_component.dart';
import 'package:apiary/presentation/components/pixel_paint.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/game/energy_countdown.dart';
import 'package:apiary/presentation/game/energy_notifier.dart';

/// The energy in the HUD, after Flambé's: a wooden panel with the amount
/// (no ceiling) centered in it, a bolt sticking out of its left edge and a
/// "+" badge on its bottom right corner. While the gauge is not full, a dark pill
/// counts down to the next unit (`mm:ss`), centered right under the panel's
/// bottom edge; nothing else moves when it comes or goes. The "+" does nothing
/// yet: buying energy comes with the gems.
///
/// The panel sticks out of the HUD band by 2 px and the pill hangs below it,
/// over the top of the orders band, which is still empty. To rethink when the orders
/// are designed. Its parent places it at the top left of the HUD band.
class EnergyGaugeComponent extends PositionComponent
    with HasGameReference<ApiaryGame> {
  EnergyGaugeComponent({super.position})
    : super(size: Vector2(gaugeWidth, pillBottom));

  static const iconImage = 'ui/energy.png';
  static const plusImage = 'ui/energy_plus.png';
  static const String panelImage = ItemInfoComponent.panelImage;
  static const timerImage = 'ui/energy_timer.png';

  /// The width of the edges of the 9-slices of the panel (the info panel's
  /// rings of 3 px) and of the pill (1 px).
  static const double _panelRing = 3;
  static const double _pillRing = 1;
  static const _iconWidth = 8.0;
  static const _iconHeight = 10.0;
  static const _plusSize = 7.0;
  static const _lineHeight = 8.0;

  /// The panel starts this far from the gauge's left, leaving room for the
  /// bolt to stick out; the text starts [_textInset] inside it, past the bolt.
  static const _panelLeft = 5.0;
  static const _textInset = 6.0;
  static const _rightPadding = 3.0;
  static const _pillPadding = 2.0;
  static const _pillHeight = 8.0;

  /// The panel is the amount between two 3 px borders, two pixels taller than
  /// the HUD band. The pill hangs right under its bottom edge (the
  /// sprite has no border of its own).
  static const _border = 3.0;
  static const double panelHeight = _border + _lineHeight + _border;
  static const double pillTop = panelHeight;
  static const double pillBottom = pillTop + _pillHeight;

  /// The bolt's distance from the gauge's left and top, on whole pixels.
  static const _iconLeft = 2.0;
  static const _iconTop = 2.0;

  static final _text = TextPaint(
    style: const TextStyle(
      color: AppColors.paper,
      fontFamily: ItemInfoComponent.fontFamily,
      fontSize: 8,
      height: 1,
    ),
  );

  static double _measure(String text) =>
      _text.getLineMetrics(text).width.ceilToDouble();

  // The pill, hence the panel, is wide enough for the widest countdown; the
  // amount takes the room of three digits at least.
  static final double _contentWidth = max(
    _measure('000'),
    _measure('00:00') + 2 * _pillPadding,
  );
  static final double _panelWidth = _textInset + _contentWidth + _rightPadding;

  // The pill is centered under the panel: their widths have the same parity,
  // so that both margins are whole pixels.
  static final double _pillWidth = () {
    final width = _measure('00:00') + 2 * _pillPadding;
    return width + ((_panelWidth - width) % 2);
  }();

  /// The "+" badge sits on the panel's bottom right corner: its top left is
  /// this far inside the corner.
  static const _plusInset = 5.0;

  /// The widest the gauge gets: the panel and the badge sticking out of it.
  static final double gaugeWidth =
      _panelLeft + _panelWidth - _plusInset + _plusSize;

  // Above the panel and the pill, which they overlap.
  final SpriteComponent _icon = SpriteComponent(
    size: Vector2(_iconWidth, _iconHeight),
    priority: 1,
  );
  final SpriteComponent _plus = SpriteComponent(
    size: Vector2.all(_plusSize),
    priority: 1,
  );
  final TextComponent _amount = TextComponent(textRenderer: _text);
  final TextComponent _countdown = TextComponent(textRenderer: _text);
  late final PixelPanelComponent _panel;
  late final PixelPanelComponent _pill;
  var _subscriptions = <ProviderSubscription<Object?>>[];

  // Kept here rather than read from the pill's lifecycle, which lags behind
  // `addAll` and `removeAll` until the next update.
  var _pillShown = false;

  /// The amount shown.
  String get amountText => _amount.text;

  /// The countdown shown; empty while there is none.
  String get countdownText => _countdown.text;

  /// Whether the pill under the amount is there.
  bool get showsCountdown => _pillShown;

  @override
  Future<void> onLoad() async {
    final [icon, plus, panel, timer] = await game.images.loadAll([
      iconImage,
      plusImage,
      panelImage,
      timerImage,
    ]);
    // Nearest-neighbor, so pixels stay sharp at fractional scales.
    Paint paint() => pixelPaint();
    _icon
      ..sprite = Sprite(icon)
      ..paint = paint();
    _plus
      ..sprite = Sprite(plus)
      ..paint = paint();
    // Grids rather than tiles: `drawImageNine` would draw the right and
    // bottom parts of the 20×20 panel sprite at their whole size, and squash
    // them (and their rings) on a panel smaller than that.
    _panel = PixelPanelComponent(
      nineTileBox: NineTileBox.withGrid(
        Sprite(panel),
        leftWidth: _panelRing,
        rightWidth: _panelRing,
        topHeight: _panelRing,
        bottomHeight: _panelRing,
      ),
      position: Vector2(_panelLeft, 0),
      size: Vector2(_panelWidth, panelHeight),
    );
    _pill = PixelPanelComponent(
      nineTileBox: NineTileBox.withGrid(
        Sprite(timer),
        leftWidth: _pillRing,
        rightWidth: _pillRing,
        topHeight: _pillRing,
        bottomHeight: _pillRing,
      ),
      position: Vector2(_panelLeft + (_panelWidth - _pillWidth) / 2, pillTop),
      size: Vector2(_pillWidth, _pillHeight),
    );
    _amount.position.y = _border;
    _countdown.position.y = pillTop;
    _icon.position.setValues(_iconLeft, _iconTop);
    _plus.position.setValues(
      _panelLeft + _panelWidth - _plusInset,
      panelHeight - _plusInset,
    );
    await addAll([_panel, _icon, _amount, _plus]);
    _subscriptions = [
      game.container.listen(energyProvider, (_, _) => _showAmount()),
      game.container.listen(
        energyCountdownProvider,
        (_, _) => _showCountdown(),
      ),
    ];
    _showAmount();
    _showCountdown();
  }

  @override
  void onRemove() {
    for (final subscription in _subscriptions) {
      subscription.close();
    }
    super.onRemove();
  }

  /// Tells the player the energy is missing: the bolt and the amount pop.
  void flashMissing() {
    for (final part in [_icon, _amount]) {
      unawaited(
        Future.sync(
          () => part.add(BounceEffect(duration: 0.16, amplitude: 0.4)),
        ),
      );
    }
  }

  void _showAmount() {
    _amount.text = '${game.energyValue.value}';
    _amount.position.x = _centered(_amount.text, _textInset, _contentWidth);
  }

  void _showCountdown() {
    final left = game.container.read(energyCountdownProvider);
    if (left == null) {
      _countdown.text = '';
      if (_pillShown) {
        _pillShown = false;
        removeAll([_pill, _countdown]);
      }
      return;
    }
    _countdown.text =
        '${left.inMinutes.toString().padLeft(2, '0')}:'
        '${(left.inSeconds % 60).toString().padLeft(2, '0')}';
    _countdown.position.x = _centered(
      _countdown.text,
      (_panelWidth - _pillWidth) / 2,
      _pillWidth,
    );
    if (!_pillShown) {
      _pillShown = true;
      unawaited(addAll([_pill, _countdown]));
    }
  }

  // Where [text] starts to be centered in the [width] pixels that begin
  // [inset] pixels inside the panel, on whole pixels.
  static double _centered(String text, double inset, double width) =>
      _panelLeft + inset + ((width - _measure(text)) / 2).floorToDouble();
}
