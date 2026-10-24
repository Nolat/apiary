---
name: release
description: Prepare an Apiary release build — check the tree, analysis and tests, bump the version in pubspec.yaml, draft release notes from git, then hand over the fastlane commands that build and upload debug symbols to Sentry and Crashlytics.
disable-model-invocation: true
argument-hint: "[patch | minor | major | <version>] [ios | android | both]"
---

Prepare a release of Apiary: $ARGUMENTS (default: patch, both platforms).

Release builds **must** go through the fastlane `release` lanes (`docs/STACK.md`, "Monitoring — Sentry"): they build with `--split-debug-info=build/debug-info` and upload the Dart symbols to Sentry and Crashlytics, without which release stack traces are unreadable. Never run `flutter build ipa|appbundle` by hand for a release.

## 1. Pre-flight — stop at the first failure and report it

```bash
git status --porcelain           # must be empty: a release is built from committed code
git log -1 --oneline
fvm flutter analyze
fvm flutter test --exclude-tags golden
fvm flutter test --tags golden   # macOS only
```

Also check `.env.sentry` **exists** (`test -f .env.sentry`) — never read it — and that the Firebase CLI is logged in (`firebase login:list`).

## 2. Version

- Read `version:` in `pubspec.yaml` (`x.y.z+build`). Bump `x.y.z` as requested and **always** increment `+build` (the stores reject a reused build number).
- Show the old and new version and wait for the user's OK before editing.
- The Sentry release name follows automatically: `fr.nolat.apiary@<x.y.z>+<build>`.

## 3. Release notes

From `git log <last tag>..HEAD` (or the whole history if there is no tag), draft:
- player-facing notes in **French and English**, short, no technical jargon, for the stores;
- an internal changelog in French, grouped by feature / fix / tech.

Write nothing to the repository unless the user asks for a CHANGELOG file.

## 4. Hand over

The version bump must be committed before building (the user commits — never commit yourself). Then give the user the commands to run, each in its own block:

```bash
cd ios && bundle exec fastlane release
```

```bash
cd android && bundle exec fastlane release
```

Remind them, if relevant: `bundle install` the first time in each platform folder; the lanes fail early if `SENTRY_AUTH_TOKEN` is missing; after the run, check the release appears in Sentry with its debug files and that Crashlytics received the symbols. Suggest tagging the commit `v<x.y.z>+<build>` once the build is uploaded.

Report in French: pre-flight results, the version change, and the notes.
