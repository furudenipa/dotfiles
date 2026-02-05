source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if command -v jq >/dev/null 2>&1; then
      info "jq is already installed."
    else
      brew install jq
    fi
    return 0
  fi

  fail "supported on macOS only."
  return 1
}
