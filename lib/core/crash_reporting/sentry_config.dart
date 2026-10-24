// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:sentry_flutter/sentry_flutter.dart';

/// DSN of the `apiary` project in the `fr-nolat-apiary` Sentry org. A DSN
/// only allows sending events, so it is safe to ship in the app.
const _sentryDsn =
    'https://960a4a44459d1ecf7c8540778f5cde1a@o4512310916808704.ingest.de.sentry.io/4512310947217488';

/// Options passed to `SentryFlutter.init()` from `bootstrap()`. Sentry runs
/// alongside Crashlytics: unlike Crashlytics it also reports debug builds,
/// tagged with the `development` environment.
void configureSentry(SentryFlutterOptions options) {
  options
    ..dsn = _sentryDsn
    ..environment = kReleaseMode ? 'production' : 'development'
    ..tracesSampleRate = kReleaseMode ? 0.2 : 1.0
    ..attachScreenshot = true;
}
