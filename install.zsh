#!/usr/bin/env zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/lib/env.zsh"
source "$ROOT/lib/log.zsh"

profile=""

while getopts "P:" opt; do
  case "$opt" in
    P) profile="$OPTARG" ;;
    *) fail "usage: install.zsh [-P <profile>] <package>"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

pkg="${1:-}"
pkg="${pkg%.zsh}"
if [[ -z "$pkg" ]]; then
  fail "usage: install.zsh [-P <profile>] <package>"
  exit 1
fi

if [[ -n "$profile" ]]; then
  if ! load_profile "$profile"; then
    fail "profile load failed: $profile"
    exit 1
  fi
fi

installer="$ROOT/installers/${pkg}.zsh"
if [[ ! -f "$installer" ]]; then
  fail "installer not found: $pkg"
  exit 1
fi

info "install: $pkg"
source "$installer"
if ! _install; then
  fail "install failed: $pkg"
  exit 1
fi
success "install: $pkg"
