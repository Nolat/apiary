// 📦 Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// 🌎 Project imports:
import 'package:apiary/core/logging/talker_service.dart';

/// Anonymous sign-in for now — will grow a Game Center / Play Games
/// Services linking method later (see docs/STACK.md).
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    talker.info('Signed in as ${_auth.currentUser?.uid}');
  }
}
