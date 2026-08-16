# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Enable completion (Oh My Zsh usually runs this for you).
autoload -Uz compinit && compinit

# Colorized ls (aligned with Oh My Zsh defaults).
export LSCOLORS="Gxfxcxdxbxegedabagacad"
if ls --color -d . >/dev/null 2>&1; then
  alias ls='ls -l --color=auto'
elif ls -G -d . >/dev/null 2>&1; then
  alias ls='ls -lG'
fi

# --- plugins (manual) ---
ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"
# zsh-autosuggestions
if [[ -r "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -Uz vcs_info
setopt PROMPT_SUBST

# --- history ---
# history の保存先と保持件数
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=20000
export SAVEHIST=20000

# タブ/ペイン/セッション間で history を共有
setopt SHARE_HISTORY

# 直前と重複するコマンドは記録しない
setopt HIST_IGNORE_DUPS

# 実行時刻などの拡張情報を保存
setopt EXTENDED_HISTORY

zstyle ':vcs_info:git:*' formats ' %F{204}(%b)%f'
zstyle ':vcs_info:*' enable git
precmd() { vcs_info }

PROMPT='%F{white}%n@%m %F{green}%~%f${vcs_info_msg_0_} '

# --- secrets ---
local _secrets_file="$HOME/.config/secrets/zsh.env"
if [[ -f $_secrets_file ]]; then
  [[ $(stat -f "%p" "$_secrets_file" 2>/dev/null || stat -c "%a" "$_secrets_file") == "100600" ]] || \
    echo "Warning: $_secrets_file should be chmod 600"
  set -a 
  source "$_secrets_file"
  set +a
fi
unset _secrets_file

# kubectl alias
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'

# dotfiles install wrapper (only when repo root is current directory)
install() {
  if [[ -f "$PWD/install.zsh" && -d "$PWD/installers" ]]; then
    command zsh "$PWD/install.zsh" "$@"
    return $?
  fi
  command install "$@"
}

_dotfiles_install() {
  if [[ -f "$PWD/install.zsh" && -d "$PWD/installers" ]]; then
    local -a pkgs
    local -a profiles
    pkgs=(${(f)"$(command ls -1 "$PWD"/installers/*.zsh 2>/dev/null | sed 's#.*/##;s#\\.zsh$##')"})
    profiles=(${(f)"$(command find "$PWD"/profiles -maxdepth 1 -type f -exec basename {} \; 2>/dev/null)"})
    _arguments -s \
      "-P[profile]:profile:(${profiles})" \
      "1:package:(${pkgs})"
    return
  fi
  _files
}
compdef _dotfiles_install install

# Created by `pipx` on 2025-05-03 13:43:24
export PATH="$HOME/.local/bin:$PATH"

# fastfetch
[[ -o interactive ]] && (( $+commands[fastfetch] )) && fastfetch

# iTerm2 shell integration
ITERM2_INTEGRATION="$HOME/.zsh/iterm2/iterm2_shell_integration.zsh"
if [[ $TERM_PROGRAM == "iTerm.app" && -f "$ITERM2_INTEGRATION" ]]; then
  source "$ITERM2_INTEGRATION"
fi
unset ITERM2_INTEGRATION

# Added by Antigravity
export PATH="/Users/mk/.antigravity/antigravity/bin:$PATH"

# zsh-syntax-highlighting (must be sourced last)
if [[ -r "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# cr: ghq管理リポジトリへfzfで移動
cr() {
  command -v ghq >/dev/null || { echo "ghq not found"; return 127; }
  command -v fzf >/dev/null || { echo "fzf not found"; return 127; }

  local selected full
  selected=$(ghq list | fzf --reverse --query "$*") || return 0
  [[ -n "$selected" ]] || return 0

  full=$(ghq list --full-path --exact "$selected") || return 1
  cd "$full" || return 1
}

# qr: 文字列をターミナル上にQRコードとして表示
qr() {
  (( $# > 0 )) || { echo 'usage: qr "文字列"'; return 1; }
  command -v qrencode >/dev/null || { echo "qrencode not found"; return 127; }

  command qrencode -t UTF8 -- "$*"
}

# qrr: クリップボード画像内の最初のQRコードを読み取る
qrr() {
  command -v pngpaste >/dev/null 2>&1 || { echo "qrr: pngpaste not found (run: install pngpaste)" >&2; return 127; }
  command -v ZXingReader >/dev/null 2>&1 || { echo "qrr: ZXingReader not found (run: install zxing-cpp)" >&2; return 127; }
  command -v jq >/dev/null 2>&1 || { echo "qrr: jq not found (run: install jq)" >&2; return 127; }
  command -v pbcopy >/dev/null 2>&1 || { echo "qrr: pbcopy not found" >&2; return 127; }

  local tmpdir image_file json_file result_file
  tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/qrr.XXXXXXXX") || {
    echo "qrr: failed to create temporary directory" >&2
    return 1
  }
  image_file="$tmpdir/clipboard.png"
  json_file="$tmpdir/result.json"
  result_file="$tmpdir/result.txt"

  {
    if ! command pngpaste "$image_file" >/dev/null 2>&1; then
      echo "qrr: clipboard does not contain an image" >&2
      return 1
    fi

    # -single により、複数ある場合は最初に検出されたQRコードだけを返す。
    if ! command ZXingReader -formats QRCode -single -json "$image_file" >"$json_file" 2>/dev/null ||
       [[ ! -s "$json_file" ]]; then
      echo "qrr: QR code not found" >&2
      return 1
    fi

    if ! command jq -erj '.Text' "$json_file" >"$result_file" 2>/dev/null; then
      echo "qrr: failed to decode QR code" >&2
      return 1
    fi

    if ! command pbcopy <"$result_file"; then
      echo "qrr: failed to copy result to clipboard" >&2
      return 1
    fi

    # jq -r は表示用の改行だけを加える。クリップボードには元の文字列を保存済み。
    command jq -er '.Text' "$json_file"
  } always {
    command rm -rf -- "$tmpdir"
  }
}
export PATH="$HOME/go/bin:$PATH"
export PATH="/Library/TeX/texbin:$PATH"

# vimトレーニング
alias nano='vim'
