#!/usr/bin/env bash
# PreToolUse (Read|Edit|Write|NotebookEdit): blocks access to secrets and edits
# to files that must only change through their tool (see docs/CONVENTIONS.md).
set -uo pipefail

input=$(cat)
tool=$(jq -r '.tool_name' <<<"$input")
file=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input")
[[ -n "$file" ]] || exit 0
name=$(basename "$file")

case "$name" in
  .env | .env.*)
    echo "Blocked: $name holds secrets (Sentry auth token) and must not be read or edited by Claude." >&2
    exit 2
    ;;
esac

[[ "$tool" == "Read" ]] && exit 0

case "$name" in
  *.g.dart | *.freezed.dart)
    echo "Blocked: $name is generated. Edit the source file and run build_runner instead." >&2
    exit 2
    ;;
  pubspec.lock)
    echo "Blocked: pubspec.lock is managed by pub. Use 'fvm flutter pub add/upgrade' instead." >&2
    exit 2
    ;;
esac
exit 0
