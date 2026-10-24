# Apiary

Apiary is a relaxing mobile merge game (Flutter). The player raises bees,
crosses species to discover new ones, and turns their resources into the day's
orders. See `docs/DESIGN.md` for the full design.

## Getting started

```bash
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter run
```

Firebase project: `fr-nolat-apiary` (Android + iOS). To regenerate the config, delete
`lib/firebase_options.dart` first, then run
`flutterfire configure --project=fr-nolat-apiary --platforms=android,ios`.

## Tests

```bash
fvm flutter test                               # unit, Flame and golden tests
patrol test                                    # on-device E2E (patrol_test/)
```

See `docs/TESTING.md` for the strategy, tools and conventions.
