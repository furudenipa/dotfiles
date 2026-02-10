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

layers=()
if ! (( ${+PROFILE_LAYERS} )); then
  fail "PROFILE_LAYERS is not defined."
  exit 1
fi
if (( ${#PROFILE_LAYERS[@]} == 0 )); then
  fail "PROFILE_LAYERS is empty."
  exit 1
fi
layers=("${PROFILE_LAYERS[@]}")

for layer in "${layers[@]}"; do
  layer_file="$ROOT/layers/${layer}"
  if [[ ! -f "$layer_file" ]]; then
    fail "layer file not found: $layer"
    exit 1
  fi

  while IFS= read -r installer_name; do
    [[ -z "$installer_name" ]] && continue
    info "install: $installer_name"
    installer_path="$ROOT/installers/${installer_name}.zsh"
    if [[ ! -f "$installer_path" ]]; then
      fail "installer not found: $installer_name"
      continue
    fi
    source "$installer_path"
    if ! _install; then
      fail "install failed: $installer_name"
      continue
    fi
    success "install: $installer_name"
  done < <(sed '/^\s*#/d;/^\s*$/d' "$layer_file")
done
