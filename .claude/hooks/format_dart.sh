#!/usr/bin/env bash
# PostToolUse (Edit|Write): formats the edited Dart file and sorts its imports
# (emoji sections, see CLAUDE.md). Generated files are left alone.
set -uo pipefail
# Cloud environments install fvm outside the hooks' default PATH.
export PATH="$HOME/.fvm_bin:$HOME/.pub-cache/bin:$PATH"

file=$(jq -r '.tool_input.file_path // empty')
[[ "$file" == *.dart ]] || exit 0
[[ "$file" == *.g.dart || "$file" == *.freezed.dart ]] && exit 0
[[ -f "$file" ]] || exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0
rel="${file#"$CLAUDE_PROJECT_DIR"/}"

# import_sorter only scans lib/, bin/, test/… and treats its args as regexes.
if ! out=$(fvm dart run import_sorter:main "$rel" 2>&1); then
  echo "import_sorter failed on $rel:" >&2
  echo "$out" | tail -20 >&2
  exit 2
fi
if ! out=$(fvm dart format "$file" 2>&1); then
  echo "dart format failed on $rel:" >&2
  echo "$out" | tail -20 >&2
  exit 2
fi
exit 0
