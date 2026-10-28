// 📦 Package imports:
import 'package:glados/glados.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/bee_lifespan.dart';

void main() {
  test('follows the table of docs/CONTENT.md', () {
    expect(
      [for (var level = 1; level <= 6; level++) BeeLifespan.of(level)],
      [
        10,
        15,
        23,
        34,
        51,
        76,
      ],
    );
  });

  Glados(any.intInRange(1, 10)).test('grows with the level', (level) {
    expect(BeeLifespan.of(level + 1), greaterThan(BeeLifespan.of(level)));
  });
}
