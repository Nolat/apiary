#!/usr/bin/env bash
# SessionStart hook: provisions FVM + the pinned Flutter SDK in Claude Code
# cloud (remote) environments. No-op on a local machine.
set -euo pipefail

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

cd "${CLAUDE_PROJECT_DIR:-.}"

export FVM_HOME="${FVM_HOME:-$HOME/.fvm_cache}"
export PATH="$HOME/.fvm_bin:$HOME/.pub-cache/bin:$PATH"
# Flutter refuses to run as root in some setups; cloud sandboxes are root.
export FVM_ALLOW_ROOT=true

install_fvm_binary() {
  # Standalone FVM (bundles its own Dart) from GitHub releases.
  local version
  version="$(curl -fsSL https://api.github.com/repos/leoafarias/fvm/releases/latest \
    | grep -m1 '"tag_name"' | cut -d'"' -f4)" || return 1
  mkdir -p "$HOME/.fvm_bin"
  curl -fsSL "https://github.com/leoafarias/fvm/releases/download/${version}/fvm-${version}-linux-x64.tar.gz" \
    | tar -xz -C "$HOME/.fvm_bin" --strip-components=1
}

install_fvm_pub() {
  # Fallback: bootstrap Dart from a pinned Flutter clone, then install FVM
  # from pub.dev (needs github.com, storage.googleapis.com and pub.dev).
  local flutter_version
  flutter_version="$(grep -m1 '"flutter"' .fvmrc | cut -d'"' -f4)"
  git clone --depth 1 -b "$flutter_version" \
    https://github.com/flutter/flutter.git "$HOME/.flutter_bootstrap"
  export PATH="$HOME/.flutter_bootstrap/bin/cache/dart-sdk/bin:$HOME/.flutter_bootstrap/bin:$PATH"
  dart pub global activate fvm
}

if ! command -v fvm >/dev/null 2>&1; then
  install_fvm_binary >&2 || {
    echo "FVM binary download failed, falling back to pub.dev" >&2
    install_fvm_pub >&2
  }
fi

fvm install --no-setup >&2 || fvm install >&2
fvm flutter --version >&2
fvm flutter pub get >&2
fvm dart run build_runner build --delete-conflicting-outputs >&2

# Persist PATH / env for every later command of the session.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  {
    echo "export FVM_HOME=\"$FVM_HOME\""
    echo "export FVM_ALLOW_ROOT=true"
    echo "export PATH=\"$HOME/.fvm_bin:$PWD/.fvm/flutter_sdk/bin:$HOME/.pub-cache/bin:\$PATH\""
  } >> "$CLAUDE_ENV_FILE"
fi
