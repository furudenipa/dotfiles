source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if command -v gh >/dev/null 2>&1; then
      info "gh is already installed."
    else
      brew install gh
    fi
    return 0
  fi

  if is_linux; then
    warn "gh for Linux is not implemented yet."
    fail "gh installer for Linux is TODO."
    return 1
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
