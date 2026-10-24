# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Apiary is a relaxing mobile merge game (Flutter): the player raises bees, crosses species to discover new ones, and harvests their resources to fulfil daily orders. The full design lives in `docs/DESIGN.md`.

The codebase is a bare scaffold: the app shell (routing, DI, theming, i18n, auth, crash reporting) is wired up, but no gameplay feature is implemented yet beyond an empty board screen. Work is tracked in **Linear** (workspace Nolat, team Apiary, key `APY`) as a prioritized product backlog: one project per epic, one issue per user story — managed with the `/backlog` skill.

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

## MCP tooling

The official Dart/Flutter MCP server (built into the Dart SDK, `dart mcp-server`) is configured project-wide in `.mcp.json`, run as `fvm dart mcp-server` to match the pinned SDK. It's experimental — see `docs/STACK.md` for details and caveats (don't confuse it with unofficial third-party servers of similar names). It's an addition to the existing workflow (build_runner, analyze, tests), not a replacement — still run those explicitly.

The official **Firebase MCP server** (`firebase-tools` `mcp`, pinned in `.mcp.json`, run through `npx`) is also configured, limited to the `core`, `firestore`, `auth` and `crashlytics` tools, against the project set in `.firebaserc` (`fr-nolat-apiary`). It uses the Firebase CLI login (`firebase login`). It talks to the **real** project: read freely, but never write, delete or deploy through it without the user's explicit go-ahead.

The official **Linear MCP server** (remote, `https://mcp.linear.app/mcp`, HTTP transport) is configured in `.mcp.json` too; it hosts the product backlog (team Apiary, `APY`), the only source of truth for stories — there is no backlog file in the repo. It authenticates through OAuth: run `/mcp` once in an interactive `claude` terminal session and pick `linear`. Same rule as Firebase: read freely, but never create, edit or delete issues, projects or documents through it without the user's explicit go-ahead.

## Claude Code automation

Project-level, versioned in `.claude/`:

- **Hooks** (`.claude/settings.json`, scripts in `.claude/hooks/`) — see "Workflow rules"; a Stop hook also blocks the end of a turn while `fr.json` and `en.json` don't define the same keys.
- **Subagents** (`.claude/agents/`):
  - `architecture-reviewer` checks a change against `docs/CONVENTIONS.md` (run it after a feature, before the user commits);
  - `test-writer` writes tests following `docs/TESTING.md`;
  - `balance-simulator` runs headless simulations of the implemented domain rules (`tool/simulate/`) and compares them with `docs/DESIGN.md`'s figures — it suggests balancing changes but never applies them;
  - `firestore-security-reviewer` audits `firestore.rules`, Firestore repositories and Cloud Functions (run it before any rules deploy).
- **Skills** (`.claude/skills/`):
  - `/game-rule <rule>` implements a DESIGN.md rule in `lib/domain/` (freezed models, pure function, glados properties) — Claude may also use it on its own for gameplay logic;
  - `/backlog [init|add|done|prioritize]` creates and maintains the Linear backlog (user stories `APY-N`, one Linear project per epic, framed one at a time with the user);
  - `/new-sprite <name> <x1.png> [x2.png]` validates a pixel-art asset (`check_sprite.py`), declares and loads it, with a golden;
  - user-only: `/new-scene <Name>` (Flame scene + route + translations + tests), `/drift-migration <change>` (schema export, `schemaVersion` bump, migration, tests), `/firestore-collection <data>` (repository, rules, fake and emulator tests — never deploys), `/release [patch|minor|major]` (pre-flight, version bump, release notes, then the fastlane commands for the user to run).

## Workflow rules

- Follow the code conventions in `docs/CONVENTIONS.md` (layering rules, domain/data/state/Flame patterns, logging, i18n, commits) — read it before writing code.
- After every code change, run `fvm dart run build_runner build --delete-conflicting-outputs && fvm dart run import_sorter:main`. In Claude Code this is automated by the project hooks (`.claude/settings.json`, scripts in `.claude/hooks/`): each edited Dart file is import-sorted and formatted on save, `build_runner` runs at the end of a turn when a codegen source (`@freezed`, `@riverpod`, drift) changed, and edits to generated files, `pubspec.lock` and access to `.env*` are blocked.
- Never commit changes yourself — leave committing to the user.

## Architecture & stack

- **Folder structure**: `lib/` is split by technical layer — `core/` (DI, routing, theme: cross-cutting app infra), `presentation/` (pages, widgets), `domain/` and `data/` (currently empty, populate as features need a business/data layer). This is a deliberate choice kept over a feature-based layout when it was reconsidered.
- **State management**: `flutter_riverpod` + `riverpod_annotation`/`riverpod_generator` — providers are code-generated (`@riverpod`), not hand-written `Provider(...)` declarations.
- **DI**: `get_it` — instance and `configureDependencies()` entry point in `lib/core/di/injection.dart`, called from `bootstrap()`. Use it for cross-cutting singletons/services (e.g. logging, repositories) rather than for widget-facing state, which stays in Riverpod.
- **Routing**: scene navigation uses Flame's `RouterComponent`/`Route`, owned by `ApiaryGame` (`lib/presentation/game/apiary_game.dart`). Each screen is a Flame scene (a `Component` in `lib/presentation/scenes/`, e.g. `BoardScene`) registered in the `routes` map under a `routeName` constant; navigate with `game.router.pushNamed(...)`/`pop()`. There is no Flutter-side router.
- **Rendering**: **Flame** is the game engine for **100% of the app's architecture** (decided 2026-10-24, driven by the confirmed **pixel art** DA — reference resolution **240×480**, ×2 assets at **480×960**, see `docs/DESIGN.md`). `ApiaryApp` (`lib/app.dart`) is only the host shell: a `MaterialApp` (for localization delegates and platform plumbing) whose `home` is a `GameWidget<ApiaryGame>`. `ApiaryGame` uses a `CameraComponent.withFixedResolution(240, 480)` with a top-left anchored viewfinder, so scenes work in reference-resolution coordinates (`ApiaryGame.referenceResolution`); scenes are added to its `world` via the router. Everything — board, Apidex, Settings — is meant to be a Flame scene, not a widget screen; this reverses an earlier decision to drop Flame for plain Flutter widgets, which predated the DA. The hand-built design system (`lib/core/theme/app_theme.dart`/`app_colors.dart`) still targets `ThemeData`; components consume `AppColors` directly for now, and porting text styles to Flame is pending. Rive remains available for rich per-element animation via `flame_rive`. Not yet worked out: pixel-perfect integer scaling (`withFixedResolution` scales non-integer), the overlay strategy for Flutter-only needs like text input, bridging Riverpod into components — see `docs/STACK.md`.
- **Models**: `freezed` for immutable data classes / unions (e.g. bee species, board items, orders).
- **Persistence**: `drift` (`lib/data/local/app_database.dart`, `AppDatabase`) for local SQLite storage, `cloud_firestore` (Firebase project `fr-nolat-apiary`, Android + iOS apps `fr.nolat.apiary`; config generated by `flutterfire configure` into `lib/firebase_options.dart`, `firebase.json`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`) for cloud sync — both registered as lazy singletons in `configureDependencies()`, no tables/collections defined yet (populate when a feature needs to persist data, per the `data/` layer rule above). `Firebase.initializeApp()` runs in `bootstrap()` before DI. Firestore security rules (`firestore.rules`) are deny-all by default; redeploy via `firebase deploy --only firestore:rules` after changes — see `docs/STACK.md` for the full rationale.
- **Auth**: `firebase_auth`, wrapped in `AuthService` (`lib/core/auth/auth_service.dart`, registered in `configureDependencies()`), anonymous sign-in only for now (`AuthService.ensureSignedIn()`, called from `bootstrap()` after DI is configured). Game Center / Play Games Services linking is planned but not implemented — see `docs/STACK.md`.
- **Localization**: `easy_localization`, supported locales `fr` (fallback) and `en`, strings in `assets/translations/{locale}.json`.
- **Logging & crash reporting**: `talker_flutter` — single instance in `lib/core/logging/talker_service.dart`, imported directly where needed (available before DI is configured) and also registered in `get_it`. `firebase_crashlytics` is wired through it: `CrashReportingService` (`lib/core/crash_reporting/crash_reporting_service.dart`, initialized from `bootstrap()`) attaches a `TalkerObserver` that forwards Talker errors/exceptions to `Crashlytics.recordError` and all logs to `Crashlytics.log` as breadcrumbs — report errors via `talker.error(...)`/`talker.warning(...)` rather than calling `FirebaseCrashlytics` directly. Collection is enabled only in release (`kReleaseMode`). **Sentry** (`sentry_flutter`, project `apiary` in org `fr-nolat-apiary`) runs alongside Crashlytics: `SentryFlutter.init()` is the first thing in `bootstrap()` (options in `lib/core/crash_reporting/sentry_config.dart`), `CrashReportingService` chains its Crashlytics global error handlers to Sentry's rather than replacing them, and the Talker observer forwards to both. Sentry also reports debug builds, under the `development` environment. Release builds go through fastlane — `cd ios && bundle exec fastlane release` / `cd android && bundle exec fastlane release` (one Fastfile + Gemfile per platform, `ios/fastlane/` and `android/fastlane/`; `--split-debug-info`, then symbol upload to Sentry via `sentry_dart_plugin` and to Crashlytics), which needs `SENTRY_AUTH_TOKEN` exported or in the gitignored `.env.sentry`. iOS dSYM upload runs as a Run Script Build Phase on the `Runner` target (`ios/Runner.xcodeproj`, "Upload Crashlytics Symbols") calling the SPM variant of Firebase's script, since the project has no Podfile — see `docs/STACK.md`.
- **Testing**: strategy, tools and conventions in `docs/TESTING.md` — read it before writing tests. Key points: the UI is a Flame canvas, invisible to widget/accessibility finders, so test the game through code (`ApiaryGame`, components) or images. `test/` mirrors `lib/`. Domain logic is pure Dart tested with `package:glados` (property-based; import it alone, it re-exports `package:test` and clashes with `flutter_test`); use `clock.now()` (never `DateTime.now()`) and an injected `Random` so it stays deterministic. `AppDatabase` takes an optional `QueryExecutor` (`NativeDatabase.memory()` in tests). Flame scenes: `flame_test`'s `testWithGame` + `testGameGolden` (`test/helpers/game_golden.dart`, renders at 240×480 / DPR 1, tagged `golden`, macOS is the reference platform). Never `pumpAndSettle` with a `GameWidget` on screen (the game loop never settles). On-device E2E lives in `patrol_test/` (Patrol; Android via `MainActivityTest.java` + test orchestrator, iOS via the `RunnerUITests` Xcode target linked to `FlutterGeneratedPluginSwiftPackage`), drives the game via `gameOf($)`.
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

### Entry point flow

`main.dart` → `bootstrap()` (`lib/bootstrap.dart`): initializes `WidgetsFlutterBinding` and `EasyLocalization`, then wraps `ApiaryApp` (`lib/app.dart`) in `EasyLocalization` + Riverpod's `ProviderScope`. New app-wide setup (DI registration, error handling, etc.) belongs in `bootstrap()`.
