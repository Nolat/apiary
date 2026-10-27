// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/resources/resource_type.dart';
import 'package:apiary/presentation/components/board/resource_sprites.dart';

void main() {
  group('ResourceType sprites', () {
    test('have art for tier 1 of every type', () {
      for (final type in ResourceType.values) {
        expect(
          File('assets/images/${type.imageAt(1)}').existsSync(),
          isTrue,
          reason: '${type.name} has no tier-1 sprite',
        );
      }
    });

    test('name the other tiers after the type and the tier', () {
      expect(ResourceType.comb.imageAt(1), 'resources/comb.png');
      expect(ResourceType.pollen.imageAt(3), 'resources/pollen_3.png');
    });
  });
}
