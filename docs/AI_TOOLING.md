# Outillage Claude Code et MCP

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
