source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if command -v pre-commit >/dev/null 2>&1; then
      info "pre-commit is already installed."
    else
      brew install pre-commit || return $?
    fi
    return 0
  fi

  if is_linux; then
    warn "pre-commit for Linux is not implemented yet."
    fail "pre-commit installer for Linux is TODO."
    return 1
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
