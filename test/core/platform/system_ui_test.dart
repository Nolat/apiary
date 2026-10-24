// 🐦 Flutter imports:
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/core/platform/system_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('configureSystemUi', () {
    test('locks portrait and hides the system bars', () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            calls.add(call);
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await configureSystemUi();

      expect(
        calls,
        containsAll([
          isMethodCall(
            'SystemChrome.setPreferredOrientations',
            arguments: ['DeviceOrientation.portraitUp'],
          ),
          isMethodCall(
            'SystemChrome.setEnabledSystemUIMode',
            arguments: 'SystemUiMode.immersiveSticky',
          ),
        ]),
      );
    });
  });
}
