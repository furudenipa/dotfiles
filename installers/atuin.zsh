source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if command -v atuin >/dev/null 2>&1; then
      info "atuin is already installed."
    else
      curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    fi
    return 0
  fi

  if is_linux; then
    if command -v atuin >/dev/null 2>&1; then
      info "atuin is already installed."
    else
      curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    fi
    return 0
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
