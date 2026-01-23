info () {
  printf "\r  [ \033[00;37m..\033[0m ] %s\n" "$1"
}

user () {
  printf "\r  [ \033[0;34m??\033[0m ] %s\n" "$1"
}

success () {
  printf "\r  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}

warn () {
  printf "\r  [\033[0;33mWARN\033[0m] %s\n" "$1"
}

fail () {
  printf "\r  [\033[0;31mFAIL\033[0m] %s\n" "$1"
  echo ''
  exit 1
}
