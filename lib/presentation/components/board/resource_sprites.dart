// 🌎 Project imports:
import 'package:apiary/domain/resources/resource_branch.dart';

/// How a [ResourceBranch] looks on the board. This lives in `presentation/`: the
/// domain knows nothing of looks.
extension ResourceSprites on ResourceBranch {
  /// The sprite of the resource of [tier], each tier with its own look, like
  /// the levels of a bee: tier 1 is `<branch>.png`, the others
  /// `<branch>_<tier>.png`: the wax drop is `wax.png` and the candle
  /// `wax_4.png`. Provisional: the tiers above 1 are recolors of the first
  /// one, until each resource has its own art.
  String imageAt(int tier) =>
      tier == 1 ? 'resources/$name.png' : 'resources/${name}_$tier.png';
}
