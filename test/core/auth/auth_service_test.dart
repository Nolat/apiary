// 📦 Package imports:
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/core/auth/auth_service.dart';

void main() {
  group('AuthService.ensureSignedIn', () {
    test('signs in anonymously when no user is signed in', () async {
      final auth = MockFirebaseAuth();
      final service = AuthService(auth);

      expect(service.currentUserId, isNull);

      await service.ensureSignedIn();

      expect(service.currentUserId, isNotNull);
      expect(auth.currentUser!.isAnonymous, isTrue);
    });

    test('keeps the existing user when already signed in', () async {
      final user = MockUser(uid: 'existing-uid');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final service = AuthService(auth);

      await service.ensureSignedIn();

      expect(service.currentUserId, 'existing-uid');
    });
  });
}
