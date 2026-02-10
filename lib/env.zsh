set -euo pipefail

if [[ -z "${ROOT-}" ]]; then
  echo "ROOT is not set. Set ROOT before sourcing lib/env.zsh." >&2
  exit 1
fi

source "$ROOT/lib/log.zsh"
OS_NAME="$(uname -s)"

is_macos() { [[ "$OS_NAME" == "Darwin" ]]; }
is_linux() { [[ "$OS_NAME" == "Linux"  ]]; }

PROFILE_NAME="${PROFILE_NAME-}"

load_profile() {
  local profile="$1"
  local file="$ROOT/profiles/${profile}"

  if [[ -n "$PROFILE_NAME" ]]; then
    if [[ "$PROFILE_NAME" == "$profile" ]]; then
      return 0
    fi
    fail "profile already loaded: $PROFILE_NAME (cannot load: $profile)"
    return 1
  fi

  PROFILE_NAME="$profile"

  if [[ ! -f "$file" ]]; then
    fail "profile not found: $file"
    return 1
  fi

  source "$file"
}

profile_get() {
  local key="$1"
  local def="${2-}"
  local var="PROFILE_${key}"
  if typeset -p "$var" >/dev/null 2>&1; then
    print -r -- "${(P)var}"
    return 0
  fi
  print -r -- "$def"
}

profile_require() {
  local key="$1"
  local var="PROFILE_${key}"
  if ! typeset -p "$var" >/dev/null 2>&1; then
    fail "profile key missing: $key"
    return 1
  fi
  print -r -- "${(P)var}"
}
