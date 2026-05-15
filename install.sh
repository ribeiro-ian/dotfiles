#!/usr/bin/env bash
# Dotfiles ─ install.sh

set -uo pipefail

# ── Colours ────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()  { echo -e "${CYAN}${BOLD}==>${RESET} $*"; }
ok()   { echo -e "${GREEN}✔${RESET}  $*"; }
warn() { echo -e "${YELLOW}⚠${RESET}  $*"; }
die()  { echo -e "${RED}✖${RESET}  $*" >&2; exit 1; }
trap 'echo; warn "Installation interrupted"' INT TERM

# ── Package manager ────────────────
detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then echo "apt"
    elif command -v pacman &>/dev/null; then echo "pacman"
    else echo "unknown"
    fi
}

FAILED_PKGS=()
PKG_MANAGER="$(detect_pkg_manager)"
log "Detected package manager: ${BOLD}${PKG_MANAGER}${RESET}"
[[ "$PKG_MANAGER" == "unknown" ]] && die "No supported package manager found."

# ── Sudo keepalive ────────────────
sudo -v || die "Failed to authenticate with sudo"

while true; do
    sudo -n true
    sleep 240
    kill -0 "$$" || exit
done 2>/dev/null &

# ── Package mappings ────────────────
pkg_name() {
    local pkg="$1"

    case "$PKG_MANAGER:$pkg" in
        apt:fd) echo "fd-find" ;;
        *) echo "$pkg" ;;
    esac
}

pkg_install() {
    local cmd="$1" pkg
    pkg="$(pkg_name "$cmd")"

    log "Installing $cmd ($pkg)..."
    case "$PKG_MANAGER" in
        apt)    sudo apt-get install -y "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        *)      warn "No supported package manager found. Please install '$pkg' manually." ;;
    esac
    return $?
}

install() {
    local cmd="$1"

    if command -v "$cmd" &>/dev/null; then
        ok "$cmd already installed"
        return 0
    fi

    if pkg_install "$cmd"; then
        ok "$cmd installed"
    else
        warn "Failed to install $cmd"
        FAILED_PKGS+=("$cmd")
        return 1
    fi
}

install_group() {
    local required="$1"
    local title="$2"
    shift 2

    log "$title"

    for pkg in "$@"; do
        if ! install "$pkg" && [[ "$required" == "true" ]]; then
            die "Failed to install required package: $pkg"
        fi
    done
}

# ── Install packages ────────────────
install_packages() {
    [[ "$PKG_MANAGER" == "apt" ]] && sudo apt-get update

    core_packages=(curl git unzip zsh stow)
    extra_packages=(ghostty mpv flatpak btop fastfetch)

    install_group true "Core packages" "${core_packages[@]}"
    install_group false "Extra packages" "${extra_packages[@]}"
}

# ── CLI tools ────────────────
install_cli_tools() {
    cli_tools=(bat tealdeer fd ripgrep eza sd wl-clipboard)

    install_group false "CLI tools" "${cli_tools[@]}"

    if command -v zoxide &>/dev/null; then
        ok "zoxide already installed"
    else
        log "Installing zoxide..."

        if curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
            ok "zoxide installed"
        else
            warn "Failed to install zoxide"
        fi
    fi

    tldr --update 2>/dev/null || warn "tldr update failed"
    ok "tldr cache populated"
}

# ── Fonts ────────────────
install_fonts() {
    FONT_DIR="${XDG_DATA_HOME:-$HOME}/.fonts"
    mkdir -p "$FONT_DIR"

    log "Installing fonts"
    FONTS=(Arimo CascadiaMono FiraMono IBMPlexMono JetBrainsMono Meslo)
    for font in "${FONTS[@]}"; do
        local url
        url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"

        if curl -#fLo "/tmp/${font}.zip" "$url"; then
            unzip -o "/tmp/${font}.zip" -d "${FONT_DIR}/${font}" &>/dev/null
            rm -f "/tmp/${font}.zip"
            ok "$font installed"
        else
            warn "Failed to download $font"
        fi
    done

    fc-cache -fv "$FONT_DIR" &>/dev/null ||
        warn "fc-cache failed"
}

# ── Zsh ────────────────
setup_shell() {
    local zsh_bin

    zsh_bin="$(command -v zsh)"

    if [[ "$SHELL" == "$zsh_bin" ]]; then
        ok "Default shell is already zsh"
        return
    fi

    warn "Your default shell is '$SHELL', not zsh."

    if chsh -s "$zsh_bin"; then
        ok "Default shell changed to zsh"
    else
        warn "Failed to change shell"
    fi
}

# ── Dotfiles ────────────────
stow_configs() {
    local dotfiles_src
    local dotfiles_dst

    dotfiles_src="${HOME}/dotfiles"
    dotfiles_dst="${HOME}/.dotfiles"

    log "Dotfiles directory"

    if [[ -d "$dotfiles_dst" ]]; then
        ok "~/.dotfiles already exists — skipping rename"
    elif [[ -d "$dotfiles_src" ]]; then
        mv "$dotfiles_src" "$dotfiles_dst"
        ok "Renamed ~/dotfiles → ~/.dotfiles"
    else
        die "~/dotfiles not found"
    fi

    log "Stowing configs"

    cd "$dotfiles_dst" || die "Failed to enter $dotfiles_dst"

    for pkg in */; do
        [[ -d "$pkg" ]] || continue

        stow -v --restow --adopt "$pkg"
        ok "Stowed $pkg"
    done

    git restore .
    ok "Restored to versioned configs"
}

# ── Run installation ────────────────
main() {
    install_packages
    install_cli_tools
    install_fonts
    setup_shell
    stow_configs

    mkdir -p ~/.icons

    echo
    echo -e "${GREEN}${BOLD}All done!${RESET}"

    if (( ${#FAILED_PKGS[@]} > 0 )); then
        echo
        warn "Some packages failed:"
        printf ' - %s\n' "${FAILED_PKGS[@]}"
    fi

    echo
    echo -e "${CYAN}${BOLD}Important:${RESET}"
    echo -e "  If you changed your default shell to zsh,"
    echo -e "  log out and log back in for the change to take effect."
    echo
    echo -e "  Or start zsh immediately with:"
    echo -e "  ${BOLD}exec zsh${RESET}"
    echo
}

main