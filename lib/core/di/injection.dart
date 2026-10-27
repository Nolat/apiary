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
import 'package:apiary/data/board/drift_board_repository.dart';
import 'package:apiary/data/energy/drift_energy_repository.dart';
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/data/time/firestore_trusted_clock.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/domain/energy/energy_repository.dart';
import 'package:apiary/domain/energy/trusted_clock.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<Talker>(() => talker);

  getIt.registerLazySingleton<AppDatabase>(AppDatabase.new);

  getIt.registerLazySingleton<BoardRepository>(
    () => DriftBoardRepository(getIt<AppDatabase>(), getIt<Talker>()),
  );

  getIt.registerLazySingleton<EnergyRepository>(
    () => DriftEnergyRepository(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<FirebaseAuth>()),
  );

  getIt.registerLazySingleton<TrustedClock>(
    () => FirestoreTrustedClock(
      getIt<FirebaseFirestore>(),
      () => getIt<AuthService>().currentUserId,
    ),
  );

  getIt.registerLazySingleton<FirebaseCrashlytics>(
    () => FirebaseCrashlytics.instance,
  );

  getIt.registerLazySingleton<CrashReportingService>(
    () => CrashReportingService(getIt<FirebaseCrashlytics>()),
  );

  talker.info('Dependencies configured');
}
