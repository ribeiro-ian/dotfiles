# ── Aliases ────────────────
alias cd='z'
alias md='mkdir -p'
alias vim='nvim'
alias ls='eza --icons --group-directories-first'
alias lsa='ls -A'
alias l='ls -l'
alias la='lsa -l'
alias tree='ls --tree --git-ignore'
alias reboot-windows='sudo bootctl set-oneshot windows.conf && sudo reboot'

# Global aliases
alias -g C='| wl-copy'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# ── Environment Variables ────────────────
export EDITOR=nvim
export VISUAL=nvim
export PATH="$HOME/.local/bin/:$PATH"
export PATH="$HOME/.scripts:$PATH"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S'

# ── Shell Integrations ────────────────
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(dircolors -b)"

# ── Completions ────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:(cd|z):*' fzf-preview 'eza -1 --color=always --icons $realpath'

# ── Syntax Highlighting ────────────────
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'

# ── History ────────────────
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTDUP=erase

mkdir -p "$HOME/.cache/zsh"
export HISTFILE="$HOME/.cache/zsh/.zsh_history"
export ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump"

setopt append_history
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# ── Zinit ────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# ── Plugins ────────────────
zi snippet OMZP::colored-man-pages
zi snippet OMZP::command-not-found
zi snippet OMZP::extract
zi snippet OMZP::git
zi snippet OMZP::sudo

zi light Aloxaf/fzf-tab
zi light MichaelAquilina/zsh-you-should-use

zi lucid wait for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zsh-users/zsh-completions \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-syntax-highlighting

# ── Keybindings ────────────────
bindkey -e
zi snippet OMZ::lib/key-bindings.zsh

# Edit command line
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^E' edit-command-line

# Numeric keypad
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"
