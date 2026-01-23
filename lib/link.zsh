create_symlink() {
  local source_file
  source_file="$(realpath "$1")"
  local destination_path="$2"
  local backup_file="${destination_path}.bak"

  if [[ -e "$destination_path" ]]; then
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
