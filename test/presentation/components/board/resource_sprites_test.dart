// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/resources/resource_branch.dart';
import 'package:apiary/presentation/components/board/resource_sprites.dart';

void main() {
  group('ResourceBranch sprites', () {
    test('have art for every tier of every branch', () {
      for (final branch in ResourceBranch.values) {
        for (var tier = 1; tier <= branch.maxTier; tier++) {
          expect(
            File('assets/images/${branch.imageAt(tier)}').existsSync(),
            isTrue,
            reason: '${branch.name} has no tier $tier sprite',
          );
        }
      }
    });

    test('name the tiers after the branch and the tier', () {
      expect(ResourceBranch.wax.imageAt(1), 'resources/wax.png');
      expect(ResourceBranch.wax.imageAt(4), 'resources/wax_4.png');
      expect(ResourceBranch.honey.imageAt(1), 'resources/honey.png');
      expect(ResourceBranch.honey.imageAt(2), 'resources/honey_2.png');
    });
  });
}
