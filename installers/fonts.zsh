source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

# Reference blog:
# https://qiita.com/sl2/items/bf58dadb261c0a019571

_install() {
  if is_macos; then
    if brew list --cask font-hack-nerd-font >/dev/null 2>&1; then
      info "font-hack-nerd-font is already installed."
    else
      brew install --cask font-hack-nerd-font
    fi
    return 0
  fi

  fail "supported on macOS only."
  return 1
}
