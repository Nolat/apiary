// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// 🌎 Project imports:
import 'package:apiary/core/logging/talker_service.dart';
import 'package:apiary/domain/energy/trusted_clock.dart';

/// The time of Firestore's servers, read back from a server timestamp the
/// player writes to their own document in [collection] (see
/// `firestore.rules`): no cloud function is needed, and the document carries
/// no game value.
///
/// Once obtained, the time keeps running on a [Stopwatch], which the device's
/// clock cannot move: changing the phone's date mid-session changes nothing,
/// and the next [sync] corrects the drift.
class FirestoreTrustedClock implements TrustedClock {
  FirestoreTrustedClock(
    this._firestore,
    this._userId, {
    this.timeout = const Duration(seconds: 10),
  });

  /// One document per user, named after their Firebase UID.
  static const collection = 'server_times';

  /// The only field of the document.
  static const field = 'at';

  final FirebaseFirestore _firestore;
  final String? Function() _userId;

  /// How long a [sync] waits for the server: offline, a write never completes.
  final Duration timeout;

  DateTime? _serverTime;
  final _sinceSync = Stopwatch();

  // The write of the server timestamp still waiting for the server. Offline it
  // never completes, and with offline persistence each new one would be queued
  // and sent on reconnection: a retry waits for this one instead of adding
  // another.
  Future<void>? _write;

  // Whether the last attempt failed, so that an outage is logged once and not
  // at each retry.
  var _failing = false;

  @override
  DateTime? now() => _serverTime?.add(_sinceSync.elapsed);

  @override
  Future<bool> sync() async {
    final userId = _userId();
    if (userId == null) {
      return false;
    }
    try {
      final document = _firestore.collection(collection).doc(userId);
      _write ??= document
          .set({field: FieldValue.serverTimestamp()})
          // A refused write is seen when the time is read back.
          .catchError((Object _) {})
          .whenComplete(() => _write = null);
      await _write!.timeout(timeout);
      final snapshot = await document
          .get(const GetOptions(source: Source.server))
          .timeout(timeout);
      final at = snapshot.data()?[field];
      if (at is! Timestamp) {
        return false;
      }
      _serverTime = at.toDate().toUtc();
      _sinceSync
        ..reset()
        ..start();
      _failing = false;
      return true;
      // Offline, a timeout, a refused rule: all leave the time unknown, and
      // the caller tries again later.
      // ignore: avoid_catches_without_on_clauses
    } catch (error) {
      if (!_failing) {
        _failing = true;
        talker.warning('Reading the trusted time failed: $error');
      }
      return false;
    }
  }
}
