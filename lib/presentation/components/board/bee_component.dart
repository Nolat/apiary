// 🌎 Project imports:
import 'package:apiary/presentation/components/board/family_item_component.dart';
import 'package:apiary/presentation/components/board/family_sprites.dart';

/// A bee, drawn as the bee of her family and level, under the family's
/// outline.
class BeeComponent extends FamilyItemComponent {
  // The level bound cannot live in `Bee` (a const constructor cannot read
  // the family's maximum level), so the sprite lookup checks it.
  BeeComponent({required super.family, this.level = 1, super.position})
    : assert(
        level >= 1 && level <= family.maxLevel,
        'No $family bee of level $level',
      );

  final int level;

  @override
  String get borderImage => family.beeBorderImage;

  @override
  String get spriteImage => family.beeImageAt(level);
}
