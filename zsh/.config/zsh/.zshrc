#===============================================================================
#                                     __             
#                         ____  _____/ /_  __________
#                        /_  / / ___/ __ \/ ___/ ___/
#                         / /_(__  ) / / / /  / /__  
#                        /___/____/_/ /_/_/   \___/  
#                        
#===============================================================================
#                               @cfsanderson

# --- Oh My Zsh Configuration ---

unsetopt BEEP
export LESS="-Q"
PS2="... "  # Cleaner look for bash

# Aliases moved to ~/.oh-my-zsh/custom/aliases.zsh and accessible with "confalias" alias.
export ZSH="$HOME/.config/zsh/oh-my-zsh"

ZSH_THEME=""  # disabled in favor of starship (see the `eval "$(starship init zsh)"` line below)

plugins=(
    asdf
    git 
    npm 
    vi-mode 
    web-search 
    zsh-completions
    zsh-syntax-highlighting
)

# Load Oh My Zsh itself.
source $ZSH/oh-my-zsh.sh
# --- End Oh My Zsh ---

source ~/.config/zsh/.env.local

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line

# Vi style:
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$HOME/.cache/zsh/history

ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"

# SSH key path
export SSH_KEY_PATH="~/.ssh/id_rsa"

# Cursor CLI
export PATH="$HOME/.local/bin:$PATH"

# start gnome keyring
# export $(gnome-keyring-daemon --start --components=secrets 2>/dev/null)

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# asdf version manager (system installation)
# asdf is installed system-wide via pacman

fastfetch
# FZF
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Starship prompt (gruvbox-rainbow preset, recolored -- see ~/.config/starship.toml)
eval "$(starship init zsh)"
