#!/usr/bin/env bash
# Stop: runs build_runner once per turn, only when a Dart file using code
# generation (@freezed, @riverpod, drift tables) changed since the last run.
set -uo pipefail

input=$(cat)
# Already continuing because of this hook: don't loop on a failing build.
[[ "$(jq -r '.stop_hook_active // false' <<<"$input")" == "true" ]] && exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0
stamp=.dart_tool/claude_build_runner.stamp

if [[ -f "$stamp" ]]; then
  changed=$(find lib test -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' -newer "$stamp" 2>/dev/null)
else
  changed=$(git status --porcelain --untracked-files=all -- lib test | awk '{print $NF}' | grep '\.dart$' | grep -vE '\.(g|freezed)\.dart$')
fi
[[ -n "$changed" ]] || exit 0

# shellcheck disable=SC2086
grep -lE '@freezed|@Freezed|@riverpod|@Riverpod|@DriftDatabase|@DriftAccessor|extends Table\b|^part .*\.(g|freezed)\.dart' $changed >/dev/null 2>&1 || {
  touch "$stamp"
  exit 0
}

if ! out=$(fvm dart run build_runner build --delete-conflicting-outputs 2>&1); then
  echo "build_runner failed:" >&2
  errors=$(grep -E 'SEVERE|[Ee]rror' <<<"$out" | head -30)
  echo "${errors:-$(tail -30 <<<"$out")}" >&2
  exit 2
fi
touch "$stamp"
exit 0
