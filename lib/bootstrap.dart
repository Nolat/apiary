// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:sentry_flutter/sentry_flutter.dart';

// 🌎 Project imports:
import 'package:apiary/app.dart';
import 'package:apiary/core/auth/auth_service.dart';
import 'package:apiary/core/crash_reporting/crash_reporting_service.dart';
import 'package:apiary/core/crash_reporting/sentry_config.dart';
import 'package:apiary/core/dev/dev_tools.dart';
import 'package:apiary/core/dev/shake_detector.dart';
import 'package:apiary/core/di/injection.dart';
import 'package:apiary/core/platform/system_ui.dart';
import 'package:apiary/core/startup/game_services.dart';
import 'package:apiary/core/startup/startup.dart';
import 'package:apiary/core/startup/startup_step.dart';
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/domain/energy/energy_repository.dart';
import 'package:apiary/domain/energy/trusted_clock.dart';
import 'package:apiary/domain/orders/order_repository.dart';
import 'package:apiary/firebase_options.dart';
import 'package:apiary/presentation/game/energy_repository_provider.dart';
import 'package:apiary/presentation/game/trusted_clock_provider.dart';

Future<void> bootstrap() async {
  // Sentry's binding variant enables slow/frozen frame tracking.
  SentryWidgetsFlutterBinding.ensureInitialized();

  // Initialized first so errors during the rest of startup are captured.
  await SentryFlutter.init(configureSentry);

  await configureSystemUi();

  await EasyLocalization.ensureInitialized();

  runApp(
    // Root wrapper Sentry needs for screenshots and user interaction tracing.
    SentryWidget(
      child: EasyLocalization(
        supportedLocales: const [Locale('fr'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('fr'),
        child: ProviderScope(
          overrides: appOverrides(),
          // The rest of the launch runs behind the splash screen.
          child: ApiaryApp(startup: Startup(_startServices)),
        ),
      ),
    ),
  );
}

/// The services the app's Riverpod providers stand on, resolved from `getIt`
/// on first read: the launch registers them behind the splash screen, and a
/// read before then fails loudly. Tests leave them out and play without
/// saving or recharging.
List<Override> appOverrides() => [
  energyRepositoryProvider.overrideWith((ref) => getIt<EnergyRepository>()),
  trustedClockProvider.overrideWith((ref) => getIt<TrustedClock>()),
];

Future<GameServices> _startServices(ValueNotifier<StartupStep> step) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  configureDependencies();

  final crashReportingService = getIt<CrashReportingService>();
  await crashReportingService.initialize();

  step.value = StartupStep.account;
  final authService = getIt<AuthService>();
  await authService.ensureSignedIn();
  await crashReportingService.setUserIdentifier(
    authService.currentUserId ?? 'unknown',
  );

  return GameServices(
    boardRepository: getIt<BoardRepository>(),
    orderRepository: getIt<OrderRepository>(),
    // Also in release builds, for now (see docs/STACK.md).
    devTools: DevTools(
      resetDatabase: getIt<AppDatabase>().reset,
      shakes: ShakeDetector().shakes,
    ),
  );
}
