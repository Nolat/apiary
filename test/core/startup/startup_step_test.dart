// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/core/startup/startup_step.dart';

void main() {
  group('StartupStep.progress', () {
    test('never leaves the bar empty and ends full', () {
      expect(StartupStep.values.first.progress, greaterThan(0));
      expect(StartupStep.values.last.progress, 1);
    });

    test('grows with each step', () {
      final progress = [for (final step in StartupStep.values) step.progress];

      expect(progress, orderedEquals([...progress]..sort()));
      expect(progress.toSet(), hasLength(progress.length));
    });
  });
}
