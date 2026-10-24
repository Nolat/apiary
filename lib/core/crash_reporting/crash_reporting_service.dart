// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

// 🌎 Project imports:
import 'package:apiary/core/logging/talker_service.dart';

/// Reports errors to both Crashlytics and Sentry. Sentry installs its own
/// global error handlers in `SentryFlutter.init()`, which runs first in
/// `bootstrap()`; the Crashlytics handlers set here chain to them rather
/// than replacing them.
class CrashReportingService {
  CrashReportingService(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  Future<void> initialize() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(kReleaseMode);

    final sentryFlutterOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      unawaited(_crashlytics.recordFlutterFatalError(details));
      sentryFlutterOnError?.call(details);
    };

    final sentryPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(_crashlytics.recordError(error, stack, fatal: true));
      sentryPlatformOnError?.call(error, stack);
      return true;
    };

    talker.configure(observer: _TalkerCrashReportingObserver(_crashlytics));
  }

  Future<void> setUserIdentifier(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
    await Sentry.configureScope(
      (scope) => scope.setUser(SentryUser(id: userId)),
    );
  }
}

/// Forwards Talker logs/errors to Crashlytics and Sentry: non-fatal errors
/// and exceptions are recorded as errors, plain logs become breadcrumbs
/// visible alongside a crash report.
class _TalkerCrashReportingObserver extends TalkerObserver {
  _TalkerCrashReportingObserver(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  void onError(TalkerError err) {
    _recordError(err.error ?? err.message, err.stackTrace);
  }

  @override
  void onException(TalkerException err) {
    _recordError(err.exception ?? err.message, err.stackTrace);
  }

  @override
  void onLog(TalkerData log) {
    final message = log.generateTextMessage();
    unawaited(_crashlytics.log(message));
    unawaited(
      Sentry.addBreadcrumb(Breadcrumb(message: message, category: 'talker')),
    );
  }

  void _recordError(Object? error, StackTrace? stackTrace) {
    unawaited(_crashlytics.recordError(error, stackTrace));
    unawaited(Sentry.captureException(error, stackTrace: stackTrace));
  }
}
