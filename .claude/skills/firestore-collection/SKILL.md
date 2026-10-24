---
name: firestore-collection
description: Add a Firestore collection to Apiary end to end — domain repository interface, data-layer implementation with conversions, security rules in the same change, fake_cloud_firestore tests and rules tests on the emulator. Use when meta-progression data (discovered species, unlocked generators, currency, cosmetics) needs to sync to the cloud.
disable-model-invocation: true
argument-hint: <what the collection stores>
---

Add Firestore persistence for: $ARGUMENTS

Read `docs/STACK.md` ("Stockage cloud — Firestore", "Sécurité Firestore") and `docs/CONVENTIONS.md` ("Données") first. Firestore holds what must survive a reinstall or sync across devices; the current board state stays in Drift.

## 1. Design the documents (agree with the user before coding)

- Path keyed by the Firebase UID: `users/{uid}/…` (a sub-collection, or a field of the `users/{uid}` document when it is small and always read together).
- Field names, types, and who writes each field. **The client never writes an economic value** (currency, paid unlocks, anything a player could forge to their advantage): those fields are client-read-only and written by a Cloud Function. If the request needs such a field, say so and plan the Function as a separate backlog item rather than opening a client write.
- Estimate reads/writes per session (one read at launch and debounced writes, not one write per merge).

## 2. Domain — `lib/domain/<notion>/`

The `freezed` model(s) if they don't exist yet, and the repository interface: `abstract interface class XRepository` with domain types only.

## 3. Data — `lib/data/<notion>/`

- `FirestoreXRepository implements XRepository`, receiving `FirebaseFirestore` (and `AuthService` or the UID) **by constructor**.
- Conversion domain ⇄ document in the repository (or `withConverter`); no Firestore type (`DocumentSnapshot`, `Timestamp`…) leaves `data/`.
- Register it in `configureDependencies()` as `registerLazySingleton<XRepository>(…)`.
- Errors logged through `talker`, never swallowed; no personal data in logs.

## 4. Security rules — `firestore.rules`, in the same change

- Default deny stays; open only `users/{uid}/…` for `request.auth.uid == uid`.
- Validate writes: allowed keys (`request.resource.data.keys().hasOnly([...])`), types, bounds; economic fields excluded from client writes.
- Compile them: `npx -y firebase-tools@15.34.1 deploy --only firestore:rules --dry-run --project fr-nolat-apiary` (validation only — **no real deploy without the user's explicit go-ahead**).

## 5. Tests

- **Repository**: `fake_cloud_firestore` (add it with `fvm flutter pub add --dev fake_cloud_firestore` the first time), under `test/data/<notion>/`: round-trip domain → document → domain, missing document, partial document.
- **Rules**: `@firebase/rules-unit-testing` against the Firestore emulator (`docs/TESTING.md`). The first time, set up a small Node project for it (e.g. `test/firestore_rules/` with its own `package.json`) and the emulator in `firebase.json`; ask the user before adding that tooling. Cover at least: owner can read/write the allowed fields, another user can't read or write, unauthenticated is denied, the client can't write an economic field, an unknown key is rejected.

## 6. Check

```bash
fvm flutter analyze
fvm flutter test test/data/
```

Then run the `firestore-security-reviewer` subagent on the rules and the repository. Report in French: the document layout, the rules opened, the tests and their results, and what still needs a Cloud Function. Don't commit, and don't deploy.
