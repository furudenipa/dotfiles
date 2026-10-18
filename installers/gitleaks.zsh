source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if command -v gitleaks >/dev/null 2>&1; then
      info "gitleaks is already installed."
    else
      brew install gitleaks || return $?
    fi
    return 0
  fi

  if is_linux; then
    warn "gitleaks for Linux is not implemented yet."
    fail "gitleaks installer for Linux is TODO."
    return 1
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
