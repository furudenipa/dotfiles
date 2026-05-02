source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if command -v codex >/dev/null 2>&1; then
      info "codex is already installed."
    else
      brew install codex
    fi
    return 0
  fi

  fail "supported on macOS only."
  return 1
}
