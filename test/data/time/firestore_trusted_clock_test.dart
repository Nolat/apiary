// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// 🌎 Project imports:
import 'package:apiary/data/time/firestore_trusted_clock.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() => firestore = FakeFirebaseFirestore());

  test('knows no time before the first sync', () {
    final clock = FirestoreTrustedClock(firestore, () => 'user');

    expect(clock.now(), isNull);
  });

  test("reads the server time through the player's own document", () async {
    final clock = FirestoreTrustedClock(firestore, () => 'user');

    final synced = await clock.sync();

    expect(synced, isTrue);
    expect(clock.now(), isNotNull);
    final stored = await firestore
        .collection(FirestoreTrustedClock.collection)
        .doc('user')
        .get();
    expect(stored.data()!.keys, [FirestoreTrustedClock.field]);
    expect(stored.data()![FirestoreTrustedClock.field], isA<Timestamp>());
  });

  test('does not sync without a signed-in user', () async {
    final clock = FirestoreTrustedClock(firestore, () => null);

    expect(await clock.sync(), isFalse);
    expect(clock.now(), isNull);
  });

  group('offline', () {
    test('queues a single write however many times it retries', () async {
      final firestore = _MockFirestore();
      final collection = _MockCollection();
      final document = _MockDocument();
      final write = Completer<void>();
      when(() => firestore.collection(any())).thenReturn(collection);
      when(() => collection.doc(any())).thenReturn(document);
      when(() => document.set(any())).thenAnswer((_) => write.future);
      final clock = FirestoreTrustedClock(
        firestore,
        () => 'user',
        timeout: const Duration(milliseconds: 20),
      );

      expect(await clock.sync(), isFalse);
      expect(await clock.sync(), isFalse);
      expect(await clock.sync(), isFalse);

      verify(() => document.set(any())).called(1);
      expect(clock.now(), isNull);
    });
  });
}

class _MockFirestore extends Mock implements FirebaseFirestore {}

// The Firestore references are sealed, but only mocktail's mocks can hang on
// a write that never completes, as offline.
// ignore: subtype_of_sealed_class
class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// Sealed too, for the same reason.
// ignore: subtype_of_sealed_class
class _MockDocument extends Mock
    implements DocumentReference<Map<String, dynamic>> {}
