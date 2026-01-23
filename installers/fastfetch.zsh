source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if command -v fastfetch >/dev/null 2>&1; then
      info "fastfetch is already installed."
      return 0
    fi
    brew install fastfetch
    return 0
  fi

  if is_linux; then
    warn "fastfetch for Linux is not implemented yet."
    fail "fastfetch installer for Linux is TODO."
    return 1
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
