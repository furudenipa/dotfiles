source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if ! command -v git >/dev/null 2>&1; then
      fail "git is required."
      return 1
    fi

    if command -v ghq >/dev/null 2>&1; then
      info "ghq is already installed."
    else
      brew install ghq
    fi

    git config --global ghq.root "$HOME/src"
    return 0
  fi

  if is_linux; then
    warn "ghq for Linux is not implemented yet."
    fail "ghq installer for Linux is TODO."
    return 1
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
