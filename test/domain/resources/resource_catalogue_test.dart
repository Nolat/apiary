// 📦 Package imports:
import 'package:glados/glados.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/resources/resource_branch.dart';
import 'package:apiary/domain/resources/resource_catalogue.dart';

void main() {
  Resource resource(ResourceBranch branch, int tier) =>
      Resource(branch: branch, tier: tier);

  group('ResourceCatalogue.madeBy', () {
    test('gives the honeybee species the resources of docs/CONTENT.md', () {
      const wax = ResourceBranch.wax;
      const honey = ResourceBranch.honey;
      final expected = [
        [resource(wax, 1), resource(honey, 1)],
        [
          resource(wax, 2),
          resource(wax, 1),
          resource(honey, 2),
          resource(honey, 1),
        ],
        [
          resource(wax, 3),
          resource(wax, 2),
          resource(honey, 3),
          resource(honey, 2),
        ],
        [resource(wax, 3), resource(honey, 4), resource(honey, 3)],
      ];

      expect(expected, hasLength(Family.honeybee.maxLevel));
      for (var level = 1; level <= Family.honeybee.maxLevel; level++) {
        expect(
          ResourceCatalogue.madeBy(Bee(family: Family.honeybee, level: level)),
          expected[level - 1],
        );
      }
    });

    for (final family in Family.values) {
      test('makes only valid resources, without duplicates, for $family', () {
        for (var level = 1; level <= family.maxLevel; level++) {
          final made = ResourceCatalogue.madeBy(
            Bee(family: family, level: level),
          );

          expect(made, isNotEmpty);
          expect(made.toSet(), hasLength(made.length));
          for (final resource in made) {
            expect(resource.tier, lessThanOrEqualTo(resource.branch.maxTier));
          }
        }
      });
    }

    test('leaves the candle to the merge', () {
      final all = [
        for (var level = 1; level <= Family.honeybee.maxLevel; level++)
          ...ResourceCatalogue.madeBy(
            Bee(family: Family.honeybee, level: level),
          ),
      ];

      expect(all, isNot(contains(resource(ResourceBranch.wax, 4))));
    });
  });
}
