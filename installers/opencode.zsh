source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if command -v opencode >/dev/null 2>&1; then
      info "opencode is already installed."
    else
      brew install anomalyco/tap/opencode-v2 || return $?
    fi
    return 0
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
