source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    local current_root=""

    if ! command -v git >/dev/null 2>&1; then
      fail "git is required."
      return 1
    fi

    if command -v ghq >/dev/null 2>&1; then
      info "ghq is already installed."
    else
      brew install ghq
    fi

    current_root="$(git config --global --get ghq.root 2>/dev/null || true)"
    if [[ -z "$current_root" ]]; then
      git config --global ghq.root "$HOME/src"
      info "Set ghq.root to $HOME/src"
    elif [[ "$current_root" == "$HOME/src" ]]; then
      info "ghq.root is already set to $HOME/src"
    else
      warn "ghq.root is already set to $current_root; leaving it unchanged."
    fi
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
