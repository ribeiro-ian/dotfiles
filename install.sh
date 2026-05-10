#!/usr/bin/env bash
# =============================================================================
# Dotfiles ─ install.sh
# =============================================================================

set -euo pipefail

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
    case "$PKG_MANAGER" in
        apt)    sudo apt-get install -y "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        *)      die "No supported package manager found. Please install '$pkg' manually." ;;
    esac
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
need stow
need zsh

# ── 1. CLI tools ────────────────
log "CLI tools (bat, tealdeer, fd, ripgrep, eza, sd, wl-clipboard)"
if command -v zoxide &>/dev/null; then
    ok "zoxide already installed"
else
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh || die "Failed to install zoxide"
    ok "zoxide installed"
fi

cli_tools=(bat tealdeer fd ripgrep eza sd wl-clipboard)
for tool in "${cli_tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
        ok "$tool already installed"
    else
        pkg_install "$tool"
        ok "$tool installed"
    fi
done
tldr --update 2>/dev/null || warn "tldr update failed"
ok "tldr cache populated"

# ── 2. Starship prompt ────────────────
log "Starship"
if command -v starship &>/dev/null; then
    ok "Starship already installed ($(starship --version | head -1))"
else
    # Install system-wide to /usr/bin (requires sudo)
    curl -sS https://starship.rs/install.sh | sh || die "Failed to install zoxide"
    ok "Starship installed"
fi

# ── 3. Set Zsh as default shell ─────────────────────────────────────
ZSH_BIN="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
    warn "Your default shell is '$SHELL', not zsh."
    chsh -s "$ZSH_BIN"
    ok "Default shell changed to zsh"
else
    ok "Default shell is already zsh"
fi

# ── 4. packages & utilities ────────────────
packages=(ghostty mpv flatpak btop fastfetch)

log "packages & utilities"
 
for pkg in "${packages[@]}"; do
    if command -v "$pkg" &>/dev/null; then
        ok "$pkg already installed"
    else
        log "Installing $pkg"
        pkg_install "$pkg"
        ok "$pkg installed"
    fi
done

# ── 5. Fonts ────────────────
FONTS=(AdwaitaMono Arimo DepartureMono FiraMono JetBrainsMono Meslo RobotoMono UbuntuMono)
mkdir -p ~/.fonts

for font in "${FONTS[@]}"; do
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip" \
    -o "/tmp/${font}.zip"
    unzip -o "/tmp/${font}.zip" -d "${HOME}/.fonts/${font}"
    rm "/tmp/${font}.zip"
done
fc-cache -fv 2>/dev/null || warn "fc-cache failed — you may need to run it manually"

# ── 6. Rename ~/dotfiles → ~/.dotfiles ────────────────
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

# ── 7. Stow configs ────────────────
log "Stowing configs"
cd "$DOTFILES_DST"

for pkg in */; do
    [ -d "$pkg" ] || continue
    stow -v --restow --adopt "$pkg"
    ok "Stowed $pkg"
done
ok "Stow done successfully"

git restore .
ok "Restored versioned configs"

# ── Done ────────────────
mkdir -vp ~/.icons

echo ""
echo -e "${GREEN}${BOLD}All done!${RESET}"
echo ""
echo -e "${CYAN}${BOLD}Important:${RESET}"
echo -e "  If you changed your default shell to zsh, you need to"
echo -e "  ${BOLD}log out and log back in${RESET} for the change to take effect."
echo ""
echo -e "  Until then, you can start zsh manually by running:"
echo -e "  ${BOLD}exec zsh${RESET}"
echo ""
