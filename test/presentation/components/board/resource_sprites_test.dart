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
      expect(ResourceBranch.comb.imageAt(1), 'resources/comb.png');
      expect(ResourceBranch.comb.imageAt(2), 'resources/comb_2.png');
      expect(ResourceBranch.pollen.imageAt(1), 'resources/pollen.png');
    });
  });
}
