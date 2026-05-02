source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_download() {
  local url="$1"
  local out="$2"

  curl -fsSL "$url" -o "$out"
}

_install_from_github_tag() {
  local repo="$1"
  local tag="$2"
  local dest_dir="$3"
  local name="$4"

  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local archive="$tmp_dir/${name}.tar.gz"
  local url="https://github.com/${repo}/archive/refs/tags/${tag}.tar.gz"

  if [[ -e "$dest_dir" || -L "$dest_dir" ]]; then
    info "Plugin already exists, keeping current version: $dest_dir"
    return 0
  fi

  _download "$url" "$archive"
  tar -xzf "$archive" -C "$tmp_dir"

  local extracted_dir
  extracted_dir="$(find "$tmp_dir" -maxdepth 1 -type d -name "${name}-*" | head -n 1)"
  if [[ -z "$extracted_dir" ]]; then
    rm -rf "$tmp_dir"
    fail "failed to find extracted directory for ${name}."
    return 1
  fi

  mv "$extracted_dir" "$dest_dir"
  rm -rf "$tmp_dir"
}

_install() {
  local base_dir="$HOME/.zsh/plugins"

  local zsh_autosuggestions_repo="zsh-users/zsh-autosuggestions"
  local zsh_autosuggestions_version="v0.7.1"
  local zsh_autosuggestions_dir="$base_dir/zsh-autosuggestions"

  local zsh_syntax_highlighting_repo="zsh-users/zsh-syntax-highlighting"
  local zsh_syntax_highlighting_version="0.8.0"
  local zsh_syntax_highlighting_dir="$base_dir/zsh-syntax-highlighting"

  mkdir -p "$base_dir"

  _install_from_github_tag \
    "$zsh_autosuggestions_repo" \
    "$zsh_autosuggestions_version" \
    "$zsh_autosuggestions_dir" \
    "zsh-autosuggestions" || return 1

  _install_from_github_tag \
    "$zsh_syntax_highlighting_repo" \
    "$zsh_syntax_highlighting_version" \
    "$zsh_syntax_highlighting_dir" \
    "zsh-syntax-highlighting" || return 1

  if [[ -f "$zsh_autosuggestions_dir/zsh-autosuggestions.zsh" ]]; then
    info "Installed: $zsh_autosuggestions_dir"
  else
    warn "zsh-autosuggestions.zsh not found after install."
  fi

  if [[ -f "$zsh_syntax_highlighting_dir/zsh-syntax-highlighting.zsh" ]]; then
    info "Installed: $zsh_syntax_highlighting_dir"
  else
    warn "zsh-syntax-highlighting.zsh not found after install."
  fi

  return 0
}
