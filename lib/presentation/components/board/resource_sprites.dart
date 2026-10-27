// 🌎 Project imports:
import 'package:apiary/domain/resources/resource_type.dart';

/// How a [ResourceType] looks on the board. This lives in `presentation/`: the
/// domain knows nothing of looks.
extension ResourceSprites on ResourceType {
  /// The sprite of the resource of [tier], each tier with its own look, like
  /// the levels of a bee: tier 1 is `<type>.png`, the others
  /// `<type>_<tier>.png`. Only tier 1 has art for now.
  String imageAt(int tier) =>
      tier == 1 ? 'resources/$name.png' : 'resources/${name}_$tier.png';
}
