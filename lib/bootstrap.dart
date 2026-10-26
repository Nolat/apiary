// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// 🌎 Project imports:
import 'package:apiary/app.dart';
import 'package:apiary/core/auth/auth_service.dart';
import 'package:apiary/core/crash_reporting/crash_reporting_service.dart';
import 'package:apiary/core/crash_reporting/sentry_config.dart';
import 'package:apiary/core/di/injection.dart';
import 'package:apiary/core/platform/system_ui.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/firebase_options.dart';

Future<void> bootstrap() async {
  // Sentry's binding variant enables slow/frozen frame tracking.
  SentryWidgetsFlutterBinding.ensureInitialized();

  // Initialized first so errors during the rest of startup are captured.
  await SentryFlutter.init(configureSentry);

  await configureSystemUi();

  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  configureDependencies();

  final crashReportingService = getIt<CrashReportingService>();
  await crashReportingService.initialize();

  final authService = getIt<AuthService>();
  await authService.ensureSignedIn();
  await crashReportingService.setUserIdentifier(
    authService.currentUserId ?? 'unknown',
  );

  runApp(
    // Root wrapper Sentry needs for screenshots and user interaction tracing.
    SentryWidget(
      child: EasyLocalization(
        supportedLocales: const [Locale('fr'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('fr'),
        child: ProviderScope(
          child: ApiaryApp(boardRepository: getIt<BoardRepository>()),
        ),
      ),
    ),
  );
}
