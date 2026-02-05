source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if command -v fzf >/dev/null 2>&1; then
      info "fzf is already installed."
    else
      brew install fzf
    fi
    return 0
  fi

  if is_linux; then
    warn "fzf setup for Linux is not implemented yet."
    fail "fzf installer for Linux is TODO."
    return 1
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
