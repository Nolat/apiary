// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/resources/resource_branch.dart';

void main() {
  // The info panel reads `resource.<branch>.tier_<tier>`: a tier without its
  // name would show the raw key to the player.
  for (final locale in ['fr', 'en']) {
    test('every tier of every branch has a name in $locale', () {
      final translations = jsonDecode(
        File('assets/translations/$locale.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final names = translations['resource'] as Map<String, dynamic>;

      for (final branch in ResourceBranch.values) {
        final tiers = names[branch.name] as Map<String, dynamic>;
        expect(
          tiers.keys,
          [for (var tier = 1; tier <= branch.maxTier; tier++) 'tier_$tier'],
          reason: '${branch.name} names in $locale',
        );
      }
    });
  }
}
