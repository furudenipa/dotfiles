#!/bin/zsh
set -euo pipefail

# Install zsh plugins used by .zshrc (pinned versions, no git submodules).

BASE_DIR="$HOME/.zsh"

ZSH_AUTOSUGGESTIONS_REPO="zsh-users/zsh-autosuggestions"
ZSH_AUTOSUGGESTIONS_VERSION="v0.7.1"
ZSH_AUTOSUGGESTIONS_DIR="$BASE_DIR/zsh-autosuggestions"

ZSH_SYNTAX_HIGHLIGHTING_REPO="zsh-users/zsh-syntax-highlighting"
ZSH_SYNTAX_HIGHLIGHTING_VERSION="0.8.0"
ZSH_SYNTAX_HIGHLIGHTING_DIR="$BASE_DIR/zsh-syntax-highlighting"

mkdir -p "$BASE_DIR"

_download() {
  local url="$1"
  local out="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$out" "$url"
  else
    echo "Error: curl or wget is required." >&2
    return 1
  fi
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

  _download "$url" "$archive"
  tar -xzf "$archive" -C "$tmp_dir"

  local extracted_dir
  extracted_dir="$(find "$tmp_dir" -maxdepth 1 -type d -name "${name}-*" | head -n 1)"
  if [[ -z "$extracted_dir" ]]; then
    echo "Error: failed to find extracted directory for ${name}." >&2
    rm -rf "$tmp_dir"
    return 1
  fi

  rm -rf "$dest_dir"
  mv "$extracted_dir" "$dest_dir"
  rm -rf "$tmp_dir"
}

_install_from_github_tag \
  "$ZSH_AUTOSUGGESTIONS_REPO" \
  "$ZSH_AUTOSUGGESTIONS_VERSION" \
  "$ZSH_AUTOSUGGESTIONS_DIR" \
  "zsh-autosuggestions"

_install_from_github_tag \
  "$ZSH_SYNTAX_HIGHLIGHTING_REPO" \
  "$ZSH_SYNTAX_HIGHLIGHTING_VERSION" \
  "$ZSH_SYNTAX_HIGHLIGHTING_DIR" \
  "zsh-syntax-highlighting"

if [[ -f "$ZSH_AUTOSUGGESTIONS_DIR/zsh-autosuggestions.zsh" ]]; then
  echo "Installed: $ZSH_AUTOSUGGESTIONS_DIR"
else
  echo "Warning: zsh-autosuggestions.zsh not found after install." >&2
fi

if [[ -f "$ZSH_SYNTAX_HIGHLIGHTING_DIR/zsh-syntax-highlighting.zsh" ]]; then
  echo "Installed: $ZSH_SYNTAX_HIGHLIGHTING_DIR"
else
  echo "Warning: zsh-syntax-highlighting.zsh not found after install." >&2
fi
