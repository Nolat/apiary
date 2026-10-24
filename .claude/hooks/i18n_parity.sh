#!/usr/bin/env bash
# Stop: when a translation file has uncommitted changes, checks that fr.json and
# en.json define the same keys (docs/CONVENTIONS.md, "Localisation").
set -uo pipefail

input=$(cat)
# Already continuing because of this hook: don't loop on a mismatch.
[[ "$(jq -r '.stop_hook_active // false' <<<"$input")" == "true" ]] && exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0
dir=assets/translations
[[ -n "$(git status --porcelain -- "$dir")" ]] || exit 0

keys() { jq -r 'paths(scalars) | join(".")' "$1" | sort; }

if ! fr=$(keys "$dir/fr.json" 2>&1) || ! en=$(keys "$dir/en.json" 2>&1); then
  echo "Translation files are not valid JSON:" >&2
  echo "$fr$en" | grep -i error >&2
  exit 2
fi

only_fr=$(comm -23 <(echo "$fr") <(echo "$en"))
only_en=$(comm -13 <(echo "$fr") <(echo "$en"))
[[ -z "$only_fr$only_en" ]] && exit 0

echo "fr.json and en.json don't define the same keys:" >&2
[[ -n "$only_fr" ]] && echo "  missing in en.json: $(tr '\n' ' ' <<<"$only_fr")" >&2
[[ -n "$only_en" ]] && echo "  missing in fr.json: $(tr '\n' ' ' <<<"$only_en")" >&2
exit 2
