// 🌎 Project imports:
import 'package:apiary/domain/orders/customer.dart';

/// How a [Customer] looks on an order's card. This lives in `presentation/`:
/// the domain knows nothing of looks.
extension CustomerSprites on Customer {
  /// The portrait, 25×25: the inside of the card's portrait cell. Provisional, until the customers are drawn.
  String get image => switch (this) {
    Customer.baker => 'customers/baker.png',
    Customer.candleMaker => 'customers/candle_maker.png',
    Customer.herbalist => 'customers/herbalist.png',
  };
}
