# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"


# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting   
)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -Uz vcs_info
setopt PROMPT_SUBST

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

# Created by `pipx` on 2025-05-03 13:43:24
export PATH="$HOME/.local/bin:$PATH"

# fastfetch
[[ -o interactive ]] && fastfetch

# Added by Antigravity
export PATH="/Users/mk/.antigravity/antigravity/bin:$PATH"
