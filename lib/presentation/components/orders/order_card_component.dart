// 🎯 Dart imports:
import 'dart:math';
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/painting.dart' show TextStyle;

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/domain/orders/order.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/components/board/resource_component.dart';
import 'package:apiary/presentation/components/orders/customer_sprites.dart';
import 'package:apiary/presentation/components/orders/order_panel_component.dart';
import 'package:apiary/presentation/components/pixel_paint.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// One order of the day, as a card of the orders band, on the info panel's
/// bordered panel: the customer's portrait on the left; on its right the one
/// or two resources asked (the sprite says the type and the tier), and under
/// them, on the card's right, the coins the order pays. The portrait is a
/// square as tall as the card's inside, drawn inside its cell's border; each resource sits on an
/// order cell of the board's size. The card is as wide as its content needs,
/// and its size is known right away, for the strip to lay the cards out.
/// Tapping it does nothing yet.
class OrderCardComponent extends PositionComponent with HasGameReference {
  OrderCardComponent(this.order)
    : super(size: Vector2(widthOf(order), cardHeight));

  final Order order;

  static const String panelImage = ItemInfoComponent.panelImage;
  static const cellImage = 'ui/order_cell.png';
  static const coinImage = 'ui/coin.png';

  static const double cardHeight = ScreenLayout.ordersHeight;

  /// The panel sprite's border, which the content stays clear of.
  static const _ring = 3;
  static const double _padding = 3;
  static const _gap = 1.0;
  static const double _cell = ScreenLayout.cellSize;
  static const double _margin = ScreenLayout.itemMargin;

  /// The cell sprite's border, 2 px.
  static const _cellRing = 2;

  /// The portrait is a square as tall as the card's inside.
  static const double _portrait = cardHeight - 2 * _padding;

  /// The room right of the portrait, before the resources and the coins.
  static const _portraitGap = 3.0;

  /// Where the resources and the coins start: right of the portrait.
  static const double _contentLeft = _padding + _portrait + _portraitGap;

  /// The coins sit under the cells.
  static const _coinSize = 7.0;
  static const double _coinsTop = _padding + _cell + _gap;
  static const _textGap = 2.0;

  /// The room between the coins' text and the card's content edge.
  static const _coinsPadding = 2.0;

  /// The digits are 4 px tall, 2 px under their line's top, so on the line they
  /// sit 1 px under the middle of the 7 px coin, which looks aligned.
  static const _textShift = 0.0;

  static TextPaint _renderer(Color color) => TextPaint(
    style: TextStyle(
      color: color,
      fontFamily: ItemInfoComponent.fontFamily,
      fontSize: 8,
      height: 1,
    ),
  );

  static final TextPaint _coinsText = _renderer(AppColors.white);

  static double _measure(TextPaint paint, String text) =>
      paint.getLineMetrics(text).width.ceilToDouble();

  static double _cellsWidth(Order order) =>
      order.resources.length * _cell + (order.resources.length - 1) * _gap;

  static double _coinsWidth(Order order) =>
      _coinSize +
      _textGap +
      _measure(_coinsText, '${order.coins}') +
      _coinsPadding;

  static double _contentWidth(Order order) =>
      max(_cellsWidth(order), _coinsWidth(order));

  /// How wide the card of [order] is, in game pixels: its cells or its coins,
  /// whichever are wider.
  static double widthOf(Order order) =>
      _contentLeft + _contentWidth(order) + _padding;

  late final TextComponent _coins;

  /// What the coins read.
  String get coinsText => _coins.text;

  @override
  Future<void> onLoad() async {
    final [panel, cell, coin, portrait] = await game.images.loadAll([
      panelImage,
      cellImage,
      coinImage,
      order.customer.image,
    ]);
    final paint = pixelPaint();
    final cells = Sprite(cell);
    SpriteComponent cellAt(double left) => SpriteComponent(
      sprite: cells,
      paint: paint,
      position: Vector2(left, _padding),
      size: Vector2.all(_cell),
    );
    await addAll([
      OrderPanelComponent(panel, size: size, ring: _ring),
      OrderPanelComponent(
        cell,
        size: Vector2.all(_portrait),
        ring: _cellRing,
        position: Vector2(_padding, _padding),
      ),
      SpriteComponent(
        sprite: Sprite(portrait),
        paint: paint,
        position: Vector2(_padding + _cellRing, _padding + _cellRing),
        size: Vector2.all(_portrait - 2 * _cellRing),
      ),
    ]);
    var left = _contentLeft;
    for (final resource in order.resources) {
      await addAll([
        cellAt(left),
        ResourceComponent(
          branch: resource.branch,
          tier: resource.tier,
          position: Vector2(left + _margin, _padding + _margin),
        ),
      ]);
      left += _cell + _gap;
    }
    // Right-aligned on the card.
    final coinsLeft = size.x - _padding - _coinsWidth(order);
    _coins = TextComponent(
      text: '${order.coins}',
      textRenderer: _coinsText,
      position: Vector2(
        coinsLeft + _coinSize + _textGap,
        _coinsTop + _textShift,
      ),
    );
    await addAll([
      SpriteComponent(
        sprite: Sprite(coin),
        paint: paint,
        position: Vector2(coinsLeft, _coinsTop),
        size: Vector2.all(_coinSize),
      ),
      _coins,
    ]);
  }
}
