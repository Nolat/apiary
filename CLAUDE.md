# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Apiary is a relaxing mobile merge game (Flutter): the player raises bees, crosses species to discover new ones, and harvests their resources to fulfil daily orders. The full design lives in `docs/DESIGN.md`.

The codebase is a bare scaffold: the app shell (routing, DI, theming, i18n, auth, crash reporting) is wired up, but no gameplay feature is implemented yet beyond an empty board screen. Work is tracked in **Linear** (workspace Nolat, team Apiary, key `APY`) as a prioritized product backlog: one project per epic, one issue per user story — managed with the `/backlog` skill.

Two sources of truth, no duplication between them:

- **`docs/DESIGN.md` owns the design**: vision and pillars, game rules, economy (coins, gems), numbers and open design questions. A design decision taken while framing a story is written there first.
- **Linear owns the backlog**: what gets built, in which order, its scope and acceptance criteria, and its status. Stories link to the DESIGN.md section they implement instead of restating its rules.

## Commands

The Flutter SDK is pinned via FVM (`.fvmrc` → Flutter 3.47.8). Prefix Flutter/Dart commands with `fvm` (i.e. `fvm flutter ...`, `fvm dart ...`) so the pinned SDK is used.

```bash
fvm flutter pub get              # install dependencies

fvm dart run build_runner build --delete-conflicting-outputs
                                  # generate *.g.dart / *.freezed.dart (riverpod_generator, freezed, drift_dev)
fvm dart run build_runner watch --delete-conflicting-outputs
                                  # regenerate on file changes

fvm flutter analyze              # static analysis (very_good_analysis rule set)
fvm dart run import_sorter:main  # sort/organize imports (see convention below)

fvm flutter test                 # run all tests
fvm flutter test test/some_test.dart          # run a single test file
fvm flutter test --plain-name "test name"     # run a single test by name
fvm flutter test --exclude-tags golden        # skip goldens (what Linux CI runs)
fvm flutter test --update-goldens --tags golden  # regenerate goldens (macOS only)
patrol test -t patrol_test/launch_test.dart   # on-device E2E (needs a booted device; `fvm dart pub global activate patrol_cli`)

fvm flutter run                  # run the app on a connected device/simulator
```

Any code using `@freezed`, `@riverpod`, or drift tables requires a `build_runner build` pass before it will compile — run it after adding/changing such files.

## MCP and Claude Code tooling

Dart/Flutter, Firebase and Linear MCP servers, hooks, subagents (`architecture-reviewer`, `test-writer`, `balance-simulator`, `firestore-security-reviewer`) and skills (`/game-rule`, `/backlog`, `/new-sprite`, user-only `/new-scene`, `/drift-migration`, `/firestore-collection`, `/release`) are described in `docs/AI_TOOLING.md`. Firebase and Linear MCP talk to real services: read freely, never write, delete or deploy without the user's explicit go-ahead.

## Workflow rules

- Follow the code conventions in `docs/CONVENTIONS.md` (layering rules, domain/data/state/Flame patterns, logging, i18n, commits) — read it before writing code.
- After every code change, run `fvm dart run build_runner build --delete-conflicting-outputs && fvm dart run import_sorter:main`. In Claude Code this is automated by the project hooks (`.claude/settings.json`, scripts in `.claude/hooks/`): each edited Dart file is import-sorted and formatted on save, `build_runner` runs at the end of a turn when a codegen source (`@freezed`, `@riverpod`, drift) changed, and edits to generated files, `pubspec.lock` and access to `.env*` are blocked.
- Never commit changes yourself — leave committing to the user.

## Architecture & stack

- **Folder structure**: `lib/` is split by technical layer — `core/` (DI, routing, theme: cross-cutting app infra), `presentation/` (pages, widgets), `domain/` and `data/` (currently empty, populate as features need a business/data layer). This is a deliberate choice kept over a feature-based layout when it was reconsidered.
- **State management**: `flutter_riverpod` + `riverpod_annotation`/`riverpod_generator` — providers are code-generated (`@riverpod`), not hand-written `Provider(...)` declarations.
- **DI**: `get_it` — instance and `configureDependencies()` entry point in `lib/core/di/injection.dart`, called from `bootstrap()`. Use it for cross-cutting singletons/services (e.g. logging, repositories) rather than for widget-facing state, which stays in Riverpod.
- **Routing**: scene navigation uses Flame's `RouterComponent`/`Route`, owned by `ApiaryGame` (`lib/presentation/game/apiary_game.dart`). Each screen is a Flame scene (a `Component` in `lib/presentation/scenes/`, e.g. `BoardScene`) registered in the `routes` map under a `routeName` constant; navigate with `game.router.pushNamed(...)`/`pop()`. There is no Flutter-side router.
- **Rendering**: **Flame** drives 100% of the app (pixel-art DA, decided 2026-10-24). `ApiaryApp` (`lib/app.dart`) is only a host `MaterialApp` whose `home` is a `GameWidget<ApiaryGame>`; every screen (board, Apidex, Settings) is a Flame scene. `GameViewport` (`lib/presentation/game/game_viewport.dart`) makes the screen exactly **140 game pixels wide** on iPhone (fractional scale, nearest-neighbor); the 7×9 grid of 20 px cells fills it edge to edge. The pure `ScreenLayout` (`screen_layout.dart`, read via `ApiaryGame.layout`) stacks HUD (16), orders (56), grid and bottom bar (32) in bands. Pixel art must be **images (sprites)**, never drawn shapes (Impeller anti-aliases geometry). `--dart-define=APIARY_LAYOUT_DEBUG=true` overlays a layout test card (see `docs/TESTING.md`). Full rationale, open questions and Rive notes: `docs/STACK.md`.
- **Models**: `freezed` for immutable data classes / unions (e.g. bee species, board items, orders).
- **Persistence**: `drift` (`lib/data/local/app_database.dart`, `AppDatabase`) for local SQLite and `cloud_firestore` (project `fr-nolat-apiary`, apps `fr.nolat.apiary`) for cloud sync — both lazy singletons in `configureDependencies()`, no tables/collections yet. `Firebase.initializeApp()` runs in `bootstrap()` before DI. `firestore.rules` is deny-all by default; redeploy with `firebase deploy --only firestore:rules`. See `docs/STACK.md`.
- **Auth**: `firebase_auth`, wrapped in `AuthService` (`lib/core/auth/auth_service.dart`, registered in `configureDependencies()`), anonymous sign-in only for now (`AuthService.ensureSignedIn()`, called from `bootstrap()` after DI is configured). Game Center / Play Games Services linking is planned but not implemented — see `docs/STACK.md`.
- **Localization**: `easy_localization`, supported locales `fr` (fallback) and `en`, strings in `assets/translations/{locale}.json`.
- **Logging & crash reporting**: `talker_flutter`, single instance in `lib/core/logging/talker_service.dart` (import directly, also in `get_it`). `CrashReportingService` (`lib/core/crash_reporting/`) forwards Talker errors/logs to Crashlytics and Sentry — report via `talker.error(...)`/`talker.warning(...)`, never call `FirebaseCrashlytics`/Sentry directly. Crashlytics is release-only; Sentry also reports debug builds (`development` environment); `SentryFlutter.init()` is first in `bootstrap()`. Release builds must go through fastlane (`cd ios && bundle exec fastlane release`, same in `android`), which needs `SENTRY_AUTH_TOKEN` exported or in the gitignored `.env.sentry`. Details (handler chaining, dSYM upload, symbols): `docs/STACK.md`.
- **Testing**: read `docs/TESTING.md` before writing tests. The UI is a Flame canvas (invisible to widget finders): test through code (`ApiaryGame`, components) or goldens. `test/` mirrors `lib/`. Domain logic is pure Dart tested with `package:glados` (import it alone; it clashes with `flutter_test`); use `clock.now()` (never `DateTime.now()`) and an injected `Random`. `AppDatabase` takes an optional `QueryExecutor` (`NativeDatabase.memory()`). Scenes: `testWithGame` + `testGameGolden` (`test/helpers/game_golden.dart`, tag `golden`, macOS reference). Never `pumpAndSettle` with a `GameWidget` on screen. E2E lives in `patrol_test/`.
- **Lints**: `very_good_analysis`, with `directives_ordering`, `lines_longer_than_80_chars`, and `public_member_api_docs` disabled (see `analysis_options.yaml`). Generated files (`*.g.dart`, `*.freezed.dart`) and platform dirs are excluded from analysis.

### Import ordering convention

The project uses `import_sorter` with emoji section comments — group and label imports in this order when writing Dart files:

```dart
// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:apiary/app.dart';
```

### System UI

The app is full-screen and portrait-only: `configureSystemUi()` (`lib/core/platform/system_ui.dart`, called early in `bootstrap()`) locks `portraitUp` and enables `SystemUiMode.immersiveSticky` (status and navigation bars hidden, revealed briefly by an edge swipe). The native launch config mirrors it so the splash screen has no bars either: `ios/Runner/Info.plist` (`UIStatusBarHidden`, portrait only, `UIRequiresFullScreen` on iPad), Android `styles.xml` (`windowFullscreen`, cutout mode `shortEdges`, both `values/` and `values-night/`) and `screenOrientation="portrait"` in `AndroidManifest.xml`.

### Entry point flow

`main.dart` → `bootstrap()` (`lib/bootstrap.dart`): initializes `WidgetsFlutterBinding` and `EasyLocalization`, then wraps `ApiaryApp` (`lib/app.dart`) in `EasyLocalization` + Riverpod's `ProviderScope`. New app-wide setup (DI registration, error handling, etc.) belongs in `bootstrap()`.
