// 🌎 Project imports:
import 'package:apiary/presentation/components/board/family_item_component.dart';
import 'package:apiary/presentation/components/board/family_sprites.dart';

/// A larva, drawn as the larva of her family, under the family's outline.
class LarvaComponent extends FamilyItemComponent {
  LarvaComponent({required super.family, super.position});

  @override
  String get borderImage => family.larvaBorderImage;

  @override
  String get spriteImage => family.larvaImage;
}
