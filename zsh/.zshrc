# ── Aliases ────────────────
alias cd='z'
alias md='mkdir -p'
alias vim='nvim'
alias ls='eza --icons --group-directories-first'
alias lsa='ls -A'
alias l='ls -l'
alias la='lsa -l'
alias tree='eza --tree --icons --git-ignore'
alias reboot-windows='sudo bootctl set-oneshot windows.conf && sudo reboot'
# Global aliases
alias -g C='| wl-copy'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# ── Environment Variables ────────────────
export EDITOR=nvim
export VISUAL=nvim
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.scripts:$PATH"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S'

# ── Functions ────────────────

# ── Zsh options ────────────────
setopt interactive_comments

# ── History ────────────────
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTDUP=erase
mkdir -p "$HOME/.cache/zsh"
export HISTFILE="$HOME/.cache/zsh/.zsh_history"
export ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump"
setopt append_history share_history hist_ignore_space
setopt hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

# ── Zinit ────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[[ ! -d $ZINIT_HOME/.git ]] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# ── Plugins ────────────────
zi snippet OMZL::git.zsh
zi snippet OMZP::git
zi snippet OMZP::sudo
zi snippet OMZP::extract
zi snippet OMZP::colored-man-pages
zi snippet OMZP::command-not-found

# fzf install
zi ice as"program" pick"bin/fzf" atclone"./install --bin" atpull"%atclone"
zi light junegunn/fzf

zi light Aloxaf/fzf-tab
zi light MichaelAquilina/zsh-you-should-use

# Turbo
zi lucid wait for \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf \
        zsh-users/zsh-completions \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting

# ── Shell integrations ────────────────
eval "$(dircolors -b)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# fzfs
FZF_PLUGIN="${ZINIT_HOME%/zinit.git}/plugins/junegunn---fzf"
source "${FZF_PLUGIN}/shell/key-bindings.zsh"
source "${FZF_PLUGIN}/shell/completion.zsh"
unset FZF_PLUGIN

# ── Syntax highlight styles ────────────────
FAST_HIGHLIGHT_STYLES[command]='fg=green,bold'
FAST_HIGHLIGHT_STYLES[precommand]='fg=green,bold'
FAST_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
FAST_HIGHLIGHT_STYLES[function]='fg=yellow,bold'
FAST_HIGHLIGHT_STYLES[alias]='fg=green,bold'
#FAST_HIGHLIGHT_STYLES[comment]='fg=8'

# ── Completions ────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:(cd|z):*' fzf-preview 'eza -1 --all --color=always --icons $realpath'

# ── Keybindings ────────────────
bindkey -e
zi snippet OMZL::key-bindings.zsh
# Edit command line
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^E' edit-command-line
# Numeric keypad
bindkey -s "^[Ok" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"
