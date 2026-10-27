// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/bootstrap.dart';
import 'package:apiary/presentation/game/energy_repository_provider.dart';
import 'package:apiary/presentation/game/trusted_clock_provider.dart';

void main() {
  group('The energy services', () {
    test('are absent by default: nothing is saved nor recharged', () {
      final container = ProviderContainer.test();

      expect(container.read(energyRepositoryProvider), isNull);
      expect(container.read(trustedClockProvider), isNull);
    });

    test('fail loudly when the app reads them before they are registered', () {
      final container = ProviderContainer.test(overrides: appOverrides());

      expect(() => container.read(energyRepositoryProvider), throwsA(anything));
      expect(() => container.read(trustedClockProvider), throwsA(anything));
    });
  });
}
