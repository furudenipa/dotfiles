#!/usr/bin/env zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/lib/env.zsh"
source "$ROOT/lib/log.zsh"

profile=""

# options parsing
while getopts "P:" opt; do
  case "$opt" in
    P) profile="$OPTARG" ;;
    *) fail "usage: setup.zsh -P <work|private>"; exit 1 ;;
  esac
done

# profileが空文字列ならエラー
if [[ -z "$profile" ]]; then
  fail "usage: setup.zsh -P <work|private>"
  exit 1
fi

if ! load_profile "$profile"; then
  fail "profile load failed: $profile"
  exit 1
fi

if [[ ! -f "$ROOT/packages/common.txt" ]]; then
  fail "packages file not found: common.txt"
  exit 1
fi

if [[ ! -f "$ROOT/packages/${profile}.txt" ]]; then
  fail "packages file not found: ${profile}.txt"
  exit 1
fi

while IFS= read -r pkg; do
  [[ -z "$pkg" ]] && continue
  info "install: $pkg"
  installer="$ROOT/installers/${pkg}.zsh"
  if [[ ! -f "$installer" ]]; then
    fail "installer not found: $pkg"
    continue
  fi
  source "$installer"
  if ! _install; then
    fail "install failed: $pkg"
    continue
  fi
  success "install: $pkg"
done < <(cat "$ROOT/packages/common.txt" "$ROOT/packages/${profile}.txt" | sed '/^\s*#/d;/^\s*$/d')
