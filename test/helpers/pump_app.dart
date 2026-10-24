// 🐦 Flutter imports:
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:apiary/app.dart';

/// Call once per test file (in `setUpAll`) before `pumpApiaryApp`.
Future<void> setUpApiaryApp() async {
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
}

extension PumpApiaryApp on WidgetTester {
  /// Pumps [ApiaryApp] wrapped like `bootstrap()` does (localization +
  /// Riverpod), without Firebase/Sentry. Pass provider [overrides] to fake
  /// state.
  ///
  /// Never follow with `pumpAndSettle`: the Flame game loop schedules frames
  /// forever, so it would time out. Use `pump()` instead.
  Future<void> pumpApiaryApp({List<Override> overrides = const []}) async {
    await pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('fr'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('fr'),
        child: ProviderScope(
          overrides: overrides,
          child: const ApiaryApp(),
        ),
      ),
    );
    await pump();
  }
}
