#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script currently supports macOS only." >&2
  exit 1
fi

if command -v fastfetch >/dev/null 2>&1; then
  echo "fastfetch is already installed."
  exit 0
fi

brew install fastfetch
