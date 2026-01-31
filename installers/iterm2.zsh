source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    local dest_dir="$HOME/.zsh/iterm2"
    local dest_file="$dest_dir/iterm2_shell_integration.zsh"

    if [[ -f "$dest_file" ]]; then
      info "iTerm2 shell integration already exists."
      return 0
    fi

    mkdir -p "$dest_dir"
    curl -fsSL https://iterm2.com/shell_integration/zsh -o "$dest_file"
    return 0
  fi

  fail "iTerm2 is supported on macOS only."
  return 1
}
