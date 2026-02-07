#!/usr/bin/env zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/lib/env.zsh"
source "$ROOT/lib/log.zsh"

profile=""

while getopts "P:" opt; do
  case "$opt" in
    P) profile="$OPTARG" ;;
    *) fail "usage: install.zsh [-P <profile>] <installer>"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

installer_name="${1:-}"
installer_name="${installer_name%.zsh}"
if [[ -z "$installer_name" ]]; then
  fail "usage: install.zsh [-P <profile>] <installer>"
  exit 1
fi

if [[ -n "$profile" ]]; then
  if ! load_profile "$profile"; then
    fail "profile load failed: $profile"
    exit 1
  fi
fi

installer_path="$ROOT/installers/${installer_name}.zsh"
if [[ ! -f "$installer_path" ]]; then
  fail "installer not found: $installer_name"
  exit 1
fi

info "install: $installer_name"
source "$installer_path"
if ! _install; then
  fail "install failed: $installer_name"
  exit 1
fi
success "install: $installer_name"
