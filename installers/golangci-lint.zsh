source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if command -v golangci-lint >/dev/null 2>&1; then
      info "golangci-lint is already installed."
    else
      brew install golangci-lint
    fi
    return 0
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
