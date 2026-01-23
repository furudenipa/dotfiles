set -euo pipefail

ROOT="$(cd "$(dirname "${(%):-%N}")/.." && pwd)"
source "$ROOT/lib/log.zsh"
OS_NAME="$(uname -s)"

is_macos() { [[ "$OS_NAME" == "Darwin" ]]; }
is_linux() { [[ "$OS_NAME" == "Linux"  ]]; }

typeset -gA PROFILE
PROFILE_NAME="${PROFILE_NAME-}"

load_profile() {
  local profile="$1"
  local file="$ROOT/profiles/${profile}.yaml"

  if [[ -n "$PROFILE_NAME" ]]; then
    if [[ "$PROFILE_NAME" == "$profile" ]]; then
      return 0
    fi
    fail "profile already loaded: $PROFILE_NAME (cannot load: $profile)"
  fi

  PROFILE_NAME="$profile"

  if [[ ! -f "$file" ]]; then
    warn "profile not found: $file (skip)"
    return 0
  fi

  local line key val
  while IFS= read -r line; do
    line="${line%%#*}"
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" != *:* ]] && continue
    key="${line%%:*}"
    val="${line#*:}"
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    val="${val#"${val%%[![:space:]]*}"}"
    val="${val%"${val##*[![:space:]]}"}"
    val="${val#\"}"
    val="${val%\"}"
    [[ -z "$key" ]] && continue
    PROFILE[$key]="$val"
  done < "$file"
}

profile_get() {
  local key="$1"
  local def="${2-}"
  if [[ -n "${PROFILE[$key]-}" ]]; then
    echo "${PROFILE[$key]}"
  else
    echo "$def"
  fi
}

profile_require() {
  local key="$1"
  if [[ -z "${PROFILE[$key]-}" ]]; then
    fail "profile key missing: $key"
  fi
  echo "${PROFILE[$key]}"
}
