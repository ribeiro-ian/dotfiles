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

# ── Package manager ────────────────
detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then echo "apt"
    elif command -v pacman &>/dev/null; then echo "pacman"
    else echo "unknown"
    fi
}

PKG_MANAGER="$(detect_pkg_manager)"
log "Detected package manager: ${BOLD}${PKG_MANAGER}${RESET}"
[[ "$PKG_MANAGER" == "unknown" ]] && warn "No supported package manager found — manual installs may be required."

pkg_install() {
    local pkg="$1"

    log "Installing $pkg..."
    case "$PKG_MANAGER" in
        apt)    sudo apt-get install -y "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        *)      die "No supported package manager found. Please install '$pkg' manually." ;;
    esac
}

safe_install() {
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
    fi
}

# ── Helpers ────────────────
need() {
    local cmd="$1" pkg="${2:-$1}"
    command -v "$cmd" &>/dev/null && return 0

    warn "'$cmd' is not installed."
    pkg_install "$pkg"
    command -v "$cmd" &>/dev/null || die "Installation of '$pkg' failed. Aborting."
    ok "'$cmd' installed"
}

# ── Preflight ────────────────
need curl
need git

# ── Packages ────────────────
packages=(ghostty mpv zsh stow flatpak btop fastfetch)

log "Packages"
 
for pkg in "${packages[@]}"; do
    safe_install "$pkg"
done

# ── CLI tools ────────────────
log "CLI tools (zoxide, bat, tealdeer, fd, ripgrep, eza, sd, wl-clipboard)"
if command -v zoxide &>/dev/null; then
    ok "zoxide already installed"
else
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh || die "Failed to install zoxide"
    ok "zoxide installed"
fi

cli_tools=(bat tealdeer fd ripgrep eza sd wl-clipboard)
for util in "${cli_tools[@]}"; do
    safe_install "$util"
done
tldr --update 2>/dev/null || warn "tldr update failed"
ok "tldr cache populated"

# ── Set Zsh as default shell ─────────────────────────────────────
ZSH_BIN="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
    warn "Your default shell is '$SHELL', not zsh."
    chsh -s "$ZSH_BIN"
    ok "Default shell changed to zsh"
else
    ok "Default shell is already zsh"
fi

# ── Fonts ────────────────
FONTS=(AdwaitaMono Arimo DepartureMono FiraMono JetBrainsMono Meslo RobotoMono UbuntuMono)
mkdir -p ~/.fonts

for font in "${FONTS[@]}"; do
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip" \
    -o "/tmp/${font}.zip"
    unzip -o "/tmp/${font}.zip" -d "${HOME}/.fonts/${font}"
    rm "/tmp/${font}.zip"
done
fc-cache -fv 2>/dev/null || warn "fc-cache failed — you may need to run it manually"

# ── Rename ~/dotfiles → ~/.dotfiles ────────────────
log "Dotfiles directory"
DOTFILES_SRC="${HOME}/dotfiles"
DOTFILES_DST="${HOME}/.dotfiles"
 
if [[ -d "$DOTFILES_DST" ]]; then
    ok "~/.dotfiles already exists — skipping rename"
elif [[ -d "$DOTFILES_SRC" ]]; then
    mv "$DOTFILES_SRC" "$DOTFILES_DST"
    ok "Renamed ~/dotfiles → ~/.dotfiles"
else
    die "~/dotfiles not found"
fi

# ── Stow configs ────────────────
log "Stowing configs"
cd "$DOTFILES_DST"

for pkg in */; do
    [ -d "$pkg" ] || continue
    stow -v --stow --adopt "$pkg"
    ok "Stowed $pkg"
done
ok "Stow done successfully"

git restore .
ok "Restored to versioned configs"

# ── Done ────────────────
mkdir -vp ~/.icons

echo ""
echo -e "${GREEN}${BOLD}All done!${RESET}"
if (( ${#FAILED_PKGS[@]} > 0 )); then
    echo
    warn "Some packages failed:"
    printf ' - %s\n' "${FAILED_PKGS[@]}"
fi
echo ""
echo -e "${CYAN}${BOLD}Important:${RESET}"
echo -e "  If you changed your default shell to zsh, you need to"
echo -e "  ${BOLD}log out and log back in${RESET} for the change to take effect."
echo ""
echo -e "  Until then, you can start zsh manually by running:"
echo -e "  ${BOLD}exec zsh${RESET}"
echo ""
