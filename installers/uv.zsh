source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    if command -v uv >/dev/null 2>&1; then
      info "uv is already installed."
    else
      curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    return 0
  fi

  if is_linux; then
    if command -v uv >/dev/null 2>&1; then
      info "uv is already installed."
    else
      curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    return 0
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
