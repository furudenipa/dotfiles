source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"
source "$ROOT/lib/link.zsh"

_install() {
  if is_macos; then
    if command -v ghostty >/dev/null 2>&1; then
      info "ghostty is already installed."
    else
      brew install --cask ghostty
    fi

    mkdir -p "$HOME/.config/ghostty"
    link_files \
      "$ROOT/files/.config/ghostty/config:$HOME/.config/ghostty/config"
    info "ghostty configuration linked."
    return 0
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
