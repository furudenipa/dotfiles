source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"
source "$ROOT/lib/link.zsh"

_zshrc_is_linked() {
  local source_file="$1"
  local destination_path="$2"

  [[ -L "$destination_path" ]] || return 1
  [[ "$(realpath "$destination_path")" == "$(realpath "$source_file")" ]]
}

_zshrc_backup_path() {
  local destination_path="$1"
  local backup_file="${destination_path}.bak"

  if [[ -e "$backup_file" || -L "$backup_file" ]]; then
    local timestamp candidate i
    timestamp="$(date "+%Y%m%d-%H%M%S")"
    candidate="${backup_file}.${timestamp}"
    i=1
    while [[ -e "$candidate" || -L "$candidate" ]]; do
      candidate="${backup_file}.${timestamp}.${i}"
      ((i++))
    done
    backup_file="$candidate"
  fi

  printf "%s" "$backup_file"
}

_install() {
  if is_macos || is_linux; then
    local source_file="$ROOT/files/.zshrc"
    local destination_path="$HOME/.zshrc"

    if _zshrc_is_linked "$source_file" "$destination_path"; then
      info "zshrc is already linked: $destination_path -> $(realpath "$source_file")"
      return 0
    fi

    if [[ -e "$destination_path" || -L "$destination_path" ]]; then
      info "Existing zshrc will be moved: $destination_path -> $(_zshrc_backup_path "$destination_path")"
    fi

    link_files "$source_file:$destination_path"
    info "zshrc linked: $destination_path -> $(realpath "$source_file")"
    return 0
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
