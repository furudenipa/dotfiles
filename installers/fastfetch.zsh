source "$ROOT/lib/env.zsh"
source "$ROOT/lib/link.zsh"

_install() {
  if is_macos; then
    if command -v fastfetch >/dev/null 2>&1; then
      info "fastfetch is already installed."
    else
      brew install fastfetch
    fi
    mkdir -p "$HOME/.config/fastfetch"
    link_files \
      "$ROOT/files/.config/fastfetch/config.jsonc:$HOME/.config/fastfetch/config.jsonc" \
      "$ROOT/files/.config/fastfetch/logo.txt:$HOME/.config/fastfetch/logo.txt"
    info "fastfetch configuration linked."
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
