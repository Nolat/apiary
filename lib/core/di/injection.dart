// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

// 🌎 Project imports:
import 'package:apiary/core/auth/auth_service.dart';
import 'package:apiary/core/crash_reporting/crash_reporting_service.dart';
import 'package:apiary/core/logging/talker_service.dart';
import 'package:apiary/data/local/app_database.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<Talker>(() => talker);

  getIt.registerLazySingleton<AppDatabase>(AppDatabase.new);

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<FirebaseAuth>()),
  );

  getIt.registerLazySingleton<FirebaseCrashlytics>(
    () => FirebaseCrashlytics.instance,
  );

  getIt.registerLazySingleton<CrashReportingService>(
    () => CrashReportingService(getIt<FirebaseCrashlytics>()),
  );

  talker.info('Dependencies configured');
}
