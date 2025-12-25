# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.


# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto  	# update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git gh  command-not-found zsh-syntax-highlighting zsh-autosuggestions zsh-completions fzf-tab vi-mode)

source $ZSH/oh-my-zsh.sh
unset AUTO_NOTIFY_THRESHOLD
# Enable transient prompt
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"
setopt dot_glob
setopt extended_glob

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
autoload -U zsh-newuser-install
# ======================
# Neovim/Vim Key Bindings
# ======================

# Enable vi-mode and set bindkey to viins (insert mode) by default
bindkey -v
export KEYTIMEOUT=1  # Reduce mode switch delay

# Normal mode bindings (ESC to enter normal mode)
bindkey -M vicmd '^k' up-line-or-history	# k for up
bindkey -M vicmd '^j' down-line-or-history  # j for down
bindkey -M vicmd 'h' backward-char     	# h for left
bindkey -M vicmd 'l' forward-char      	# l for right
bindkey -M vicmd '0' beginning-of-line 	# 0 for start of line
bindkey -M vicmd '^' beginning-of-line 	# ^ for start of line (non-blank)
bindkey -M vicmd '$' end-of-line       	# $ for end of line
bindkey -M vicmd 'b' backward-word     	# b for backward word
bindkey -M vicmd 'w' forward-word      	# w for forward word
bindkey -M vicmd 'e' forward-word      	# e for end of word
bindkey -M vicmd 'dd' kill-whole-line  	# dd to delete line
bindkey -M vicmd 'u' undo              	# u for undo
bindkey -M vicmd '^R' redo             	# Ctrl-R for redo

# Insert mode bindings
bindkey -M viins '^[' vi-cmd-mode      	# ESC to enter normal mode
bindkey -M viins '^W' backward-kill-word   # Ctrl-W to delete word backward
bindkey -M viins '^U' backward-kill-line   # Ctrl-U to delete line backward
bindkey -M viins '^A' beginning-of-line	# Ctrl-A to go to start of line
bindkey -M viins '^E' end-of-line      	# Ctrl-E to go to end of line

# Search history with / like in vim
bindkey -M vicmd '/' history-incremental-search-backward

# Make backspace work properly in insert mode
bindkey -M viins '^?' backward-delete-char

# Bind Ctrl+Y to accept autosuggestion
bindkey '^Y' autosuggest-accept
# ======================
# Additional Configuration
# ======================

# History settings
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select  # Changed to 'select' for vim-like menu navigation
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
# Aliases
alias ls='lsd'
alias vim='nvim'
alias c='clear'

# Shell integrations


export PATH="$HOME/.local/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
unsetopt beep

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/tlaloch/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[[ $- == *i* ]] && eval "$(zoxide init --cmd cd zsh)"


# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

alias tmc='/home/tlaloch/mooc/tmc-cli-rust-x86_64-unknown-linux-gnu-v1.1.2'
export TMC_LANGS_CONFIG_DIR='/home/tlaloch/tmc-config'
fpath=(/home/tlaloch/.local/share/tmc-autocomplete/_tmc  $fpath)
compdef _tmc tmc
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# To customize prompt, run `p10k configure` or edit ~/dotfiles/pl10k/.p10k.zsh.
[[ ! -f ~/dotfiles/pl10k/.p10k.zsh ]] || source ~/dotfiles/pl10k/.p10k.zsh
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$HOME/.local/opt/go/bin
GIT="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"
