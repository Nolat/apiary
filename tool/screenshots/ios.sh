#!/usr/bin/env bash
# Screenshots the app on several iOS simulators, from the smallest to the
# largest screens, and checks the layout on each of them (see
# GameViewport): the app is built with the LayoutDebugOverlay test
# card, measured by check_layout.py. Creates and boots the simulators it
# needs, reusing existing ones, and shuts down those it booted. Exits 1 if a
# check fails.
#
#   tool/screenshots/ios.sh            # every device below
#   tool/screenshots/ios.sh "iPhone SE (3rd generation)"   # only those named
#
# Screenshots land in build/screenshots/ios/<device>.png.
set -euo pipefail

cd "$(dirname "$0")/../.."

# "Device type name|runtime[|flags]" — the extremes in size, aspect ratio and
# DPR. Flags (see check_layout.py): "centered", the height limits the scale,
# so the board is centered rather than edge to edge; "downsampled", iOS
# shrinks the app's @3x rendering to fit the panel, blurring pixels.
DEVICES=(
  "iPhone SE (3rd generation)|iOS-27-0"  # smallest, 16:9, no notch, DPR 2
  "iPhone 13 mini|iOS-27-0|downsampled"  # small, notch, @3x shrunk ×0.96
  "iPhone 18 Pro|iOS-27-0"               # reference phone, Dynamic Island
  "iPhone 18 Pro Max|iOS-27-0"           # largest phone
  "iPhone Duo|iOS-27-1|centered"         # foldable
  "iPad mini (A17 Pro)|iOS-27-0|centered"  # small tablet, wide aspect
  "iPad Pro 13-inch (M5)|iOS-27-0|centered"  # largest screen
)
BUNDLE_ID="fr.nolat.apiary"
APP="build/ios/iphonesimulator/Runner.app"
OUT="build/screenshots/ios"
# Max seconds for the board scene to show (a fresh simulator can take 30+ s).
LAUNCH_TIMEOUT="${LAUNCH_TIMEOUT:-90}"
CHECK="python3 tool/screenshots/check_layout.py"

# Whether device $1 is among the names given on the command line (all if none).
wanted() {
  local name=$1; shift
  [[ $# -eq 0 ]] && return 0
  for w in "$@"; do [[ "$w" == "$name" ]] && return 0; done
  return 1
}

# UDIDs of the simulators of this type on this runtime, one per line, one
# created if there is none. A simulator can be stuck on a black screen (the
# iPhone Duo does): the caller moves on to the next one when it never shows.
udids_for() {
  local name=$1 runtime=$2
  local udids
  udids=$(xcrun simctl list devices -j | python3 -c "
import json, sys
name, runtime = sys.argv[1], sys.argv[2]
devices = json.load(sys.stdin)['devices'].get(
    'com.apple.CoreSimulator.SimRuntime.' + runtime, [])
print('\\n'.join(d['udid'] for d in devices
                 if d['name'] == name and d['isAvailable']))
" "$name" "$runtime")
  if [[ -z "$udids" ]]; then
    udids=$(xcrun simctl create "$name" "$name" \
      "com.apple.CoreSimulator.SimRuntime.$runtime")
  fi
  echo "$udids"
}

# Launches the app on simulator $1 and screenshots it into $2 once the board
# scene is up (the splash screen shows the test card too) and has stopped
# moving: two identical screenshots in a row. Fails after LAUNCH_TIMEOUT.
screenshot_when_ready() {
  local udid=$1 file=$2
  local previous="$file.previous"
  xcrun simctl terminate "$udid" "$BUNDLE_ID" 2>/dev/null || true
  xcrun simctl install "$udid" "$APP"
  xcrun simctl launch "$udid" "$BUNDLE_ID" >/dev/null
  rm -f "$previous"
  local deadline=$((SECONDS + LAUNCH_TIMEOUT))
  until xcrun simctl io "$udid" screenshot "$file" >/dev/null 2>&1 \
      && $CHECK --ready "$file" "$previous"; do
    if ((SECONDS > deadline)); then
      rm -f "$previous"
      return 1
    fi
    cp "$file" "$previous" 2>/dev/null || true
    sleep 2
  done
  rm -f "$previous"
}

echo "▶ Building $APP"
fvm flutter build ios --simulator --debug \
  --dart-define=APIARY_LAYOUT_DEBUG=true >/dev/null

rm -rf "$OUT"
mkdir -p "$OUT"
booted_here=()
check_args=()
failed=false
trap 'for u in "${booted_here[@]:-}"; do [[ -n "$u" ]] && xcrun simctl shutdown "$u" 2>/dev/null; done' EXIT

for entry in "${DEVICES[@]}"; do
  IFS='|' read -r name runtime flags <<<"$entry"
  wanted "$name" "$@" || continue

  file="$OUT/$(echo "$name" | tr -c 'A-Za-z0-9\n' '_' | tr -s '_' | sed 's/_$//').png"
  shown=false
  while read -r udid <&3; do
    if ! xcrun simctl list devices booted | grep -q "$udid"; then
      xcrun simctl boot "$udid"
      booted_here+=("$udid")
    fi
    xcrun simctl bootstatus "$udid" -b >/dev/null
    if screenshot_when_ready "$udid" "$file"; then
      shown=true
      break
    fi
    echo "⚠ $name ($udid): board scene not ready after ${LAUNCH_TIMEOUT}s" >&2
  done 3< <(udids_for "$name" "$runtime")
  if ! $shown; then
    echo "✘ $name: no simulator showed the board scene" >&2
    failed=true
    continue
  fi
  echo "📸 $name → $file"
  [[ "$flags" == *downsampled* ]] && check_args+=("--downsampled=$file")
  [[ "$flags" == *centered* ]] && check_args+=("--centered=$file")
  check_args+=("$file")
done

echo "▶ Checking the layout"
if ((${#check_args[@]})); then
  $CHECK "${check_args[@]}" || failed=true
fi
if $failed; then
  exit 1
fi
