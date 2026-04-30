# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Optimized plugins
plugins=(
	sudo
	fzf-tab
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	zoxide
)

# History settings
mkdir -p "$HOME/.cache/zsh"
export ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump"

HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.cache/zsh/.zsh_history
setopt appendhistory sharehistory hist_ignore_space
setopt hist_ignore_all_dups hist_save_no_dups
setopt hist_ignore_dups hist_find_no_dups

autoload -Uz compinit
if [[ -s "$ZSH_COMPDUMP" && "$ZSH_COMPDUMP" -nt "$ZSH_COMPDUMP".zwc ]]; then
    compinit -d "$ZSH_COMPDUMP"
else
    compinit -C -d "$ZSH_COMPDUMP"
fi
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# Source OMZ
source $ZSH/oh-my-zsh.sh

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'

# Shell integrations
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export PATH="$HOME/.scripts:$PATH"

export EDITOR=nvim
export VISUAL=nvim

# time function
TIMEFMT='real	%E
user	%U
sys	%S'

# Aliases
alias ls='ls --color'
alias lsa='ls -A'
alias cd='z'
alias vim=nvim
alias reboot-windows='sudo bootctl set-oneshot windows.conf && sudo reboot'

# Keypad
# + -  * /
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"

