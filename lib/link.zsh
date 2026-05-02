create_symlink() {
  local source_file
  source_file="$(realpath "$1")"
  local destination_path="$2"
  local backup_file="${destination_path}.bak"
  local current_target

  if [[ -e "$destination_path" || -L "$destination_path" ]]; then
    if [[ -L "$destination_path" ]]; then
      current_target="$(realpath "$destination_path")"
      if [[ "$current_target" == "$source_file" ]]; then
        return 0
      fi
    fi

    # If a .bak already exists, create a timestamped backup to avoid clobbering it.
    if [[ -e "$backup_file" ]]; then
      local timestamp candidate i
      timestamp="$(date "+%Y%m%d-%H%M%S")"
      candidate="${backup_file}.${timestamp}"
      if [[ -e "$candidate" ]]; then
        i=1
        while [[ -e "${candidate}.${i}" ]]; do
          ((i++))
        done
        candidate="${candidate}.${i}"
      fi
      backup_file="$candidate"
    fi
    mv "$destination_path" "$backup_file"
  fi

  ln -s "$source_file" "$destination_path"
}

link_files() {
  local entry source_file destination_path
  for entry in "$@"; do
    IFS=":" read -r source_file destination_path <<< "$entry"
    create_symlink "$source_file" "$destination_path"
  done
}
