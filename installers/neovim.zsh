source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if brew list --formula neovim >/dev/null 2>&1; then
      info "neovim is already installed via Homebrew."
    else
      brew install neovim
      if ! brew list --formula neovim >/dev/null 2>&1; then
        fail "neovim install did not complete."
        return 1
      fi
    fi
    return 0
  fi

  fail "supported on macOS only."
  return 1
}
