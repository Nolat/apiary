// 🌎 Project imports:
import 'package:apiary/presentation/components/board/family_item_component.dart';
import 'package:apiary/presentation/components/board/family_sprites.dart';

/// A queen, drawn as the queen of her family: the family's bee under the
/// family's outline and a crown, which is what sets her apart from a bee.
class QueenComponent extends FamilyItemComponent {
  QueenComponent({required super.family, super.position});

  static const crownImage = 'queens/crown_queen.png';

  @override
  String get borderImage => family.beeBorderImage;

  @override
  String get spriteImage => family.beeImage;

  @override
  List<String> get overlayImages => const [crownImage];
}
