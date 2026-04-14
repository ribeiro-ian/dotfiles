#!/usr/bin/env bash
# =============================================================================
# Dotfiles ─ install.sh
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()  { echo -e "${CYAN}${BOLD}==>${RESET} $*"; }
ok()   { echo -e "${GREEN}✔${RESET}  $*"; }
warn() { echo -e "${YELLOW}⚠${RESET}  $*"; }
die()  { echo -e "${RED}✖${RESET}  $*" >&2; exit 1; }

# ── Package manager (detected once, global) ───────────────────────────────────
detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then echo "apt"
    elif command -v pacman &>/dev/null; then echo "pacman"
    else echo "unknown"
    fi
}

PKG_MANAGER="$(detect_pkg_manager)"
log "Detected package manager: ${BOLD}${PKG_MANAGER}${RESET}"
[[ "$PKG_MANAGER" == "unknown" ]] && warn "No supported package manager found — manual installs may be required."

# On Arch, bootstrap paru so AUR packages are available via pkg_install
if [[ "$PKG_MANAGER" == "pacman" ]]; then
    if command -v paru &>/dev/null; then
        ok "paru already installed"
    else
        log "Installing paru (AUR helper)"
        sudo pacman -S --noconfirm paru
        ok "paru installed"
    fi
fi

pkg_install() {
    local pkg="$1"
    case "$PKG_MANAGER" in
        apt)    sudo apt-get install -y "$pkg" ;;
        pacman) paru -S --noconfirm "$pkg" ;;
        *)      die "No supported package manager found. Please install '$pkg' manually." ;;
    esac
}

# ── Helpers ───────────────────────────────────────────────────────────────────
need() {
    local cmd="$1" pkg="${2:-$1}"
    command -v "$cmd" &>/dev/null && return 0

    warn "'$cmd' is not installed."
    pkg_install "$pkg"
    command -v "$cmd" &>/dev/null || die "Installation of '$pkg' failed. Aborting."
    ok "'$cmd' installed"
}

clone_or_pull() {
    local repo="$1" dest="$2"
    if [[ -d "$dest/.git" ]]; then
        ok "$(basename "$dest") already cloned — pulling latest"
        git -C "$dest" pull --ff-only --quiet
    else
        log "Cloning $(basename "$dest")"
        git clone --depth=1 --quiet "$repo" "$dest"
        ok "$(basename "$dest") cloned"
    fi
}

# ── Preflight ─────────────────────────────────────────────────────────────────
need curl
need git
need stow
need zsh
need fzf

# ── 1. Oh My Zsh ─────────────────────────────────────────────────────────────
log "Oh My Zsh"
if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  ok "Oh My Zsh already installed — skipping"
else
    # RUNZSH=no  → don't switch shell mid-script
    # CHSH=no    → don't auto-chsh (do it deliberately below)
    RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok "Oh My Zsh installed"
fi

# Use custom directory or fallback to default path
ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

# ── 2. Zsh plugins ────────────────────────────────────────────────────────────
log "Zsh plugins"

# zsh autosuggestions
clone_or_pull \
"https://github.com/zsh-users/zsh-autosuggestions" \
"${ZSH_CUSTOM}/plugins/zsh-autosuggestions"

# zsh completions
clone_or_pull \
"https://github.com/zsh-users/zsh-completions" \
"${ZSH_CUSTOM}/plugins/zsh-completions"

# zsh synytax highlighting
clone_or_pull \
"https://github.com/zsh-users/zsh-syntax-highlighting" \
"${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"

# fzf
clone_or_pull \
"https://github.com/Aloxaf/fzf-tab" \
"${ZSH_CUSTOM}/plugins/fzf-tab"

# ── 3. Zoxide ─────────────────────────────────────────────────────────────────
log "Zoxide"
if command -v zoxide &>/dev/null; then
    ok "Zoxide already installed ($(zoxide --version))"
else
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    ok "Zoxide installed via curl"
    # pkg_install zoxide
    # ok "Zoxide installed via ${PKG_MANAGER}"
fi

# ── 4. Starship prompt ────────────────────────────────────────────────────────
log "Starship"
if command -v starship &>/dev/null; then
    ok "Starship already installed ($(starship --version | head -1))"
else
    # Install system-wide to /usr/bin (requires sudo)
    curl -sS https://starship.rs/install.sh | sh -s -- -b /usr/bin
    ok "Starship installed to /usr/bin"
fi

# ── 5. set Zsh as default shell ─────────────────────────────────────
ZSH_BIN="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
    warn "Your default shell is '$SHELL', not zsh."
    read -r -p "    Change default shell to zsh now? [y/N] " reply
    if [[ "$reply" =~ ^[Yy]$ ]]; then
        # zsh must be in /etc/shells
        chsh -s $(which zsh)
        ok "Default shell changed to zsh"
    fi
else
    ok "Default shell is already zsh"
fi

# ── 6. Spotify & Spicetify setup ─────────────────────────────────────────────
echo ""
warn "Before continuing, please install Spotify manually and open it once (wait ~60s logged in)."
echo -e "  ${BOLD}Spotify${RESET} → https://www.spotify.com/download/linux/"
echo ""

while true; do
    read -r -p "$(echo -e "${CYAN}${BOLD}==>${RESET} Have you installed Spotify and ran it once? [y/N] ")" reply
    [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]] && break
    warn "Take your time — the script will wait."
done

# --- Detect Spotify install method ---
echo ""
log "How did you install Spotify?"
echo "  1) AUR (spotify)"
echo "  2) Flatpak"
read -r -p "$(echo -e "${CYAN}${BOLD}==>${RESET} Enter option [1-2]: ")" spotify_opt

case "$spotify_opt" in
    1) SPOTIFY_INSTALL_METHOD="aur" ;;
    2) SPOTIFY_INSTALL_METHOD="flatpak" ;;
    *) die "Invalid option." ;;
esac

# --- Install Spicetify ---
log "Installing Spicetify"
if command -v spicetify &>/dev/null || [[ -x "$HOME/.spicetify/spicetify" ]]; then
    ok "Spicetify already installed"
else
    curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
    ok "Spicetify installed"
fi

SPICETIFY="$HOME/.spicetify/spicetify"

# --- Linux-specific setup per install method ---
log "Spicetify Linux setup (${SPOTIFY_INSTALL_METHOD})"

case "$SPOTIFY_INSTALL_METHOD" in
    aur)
        sudo chmod a+wr /opt/spotify
        sudo chmod a+wr -R /opt/spotify/Apps
        ok "Permissions set for /opt/spotify"
        ;;

    flatpak)
        FLATPAK_SYSTEM="/var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify"
        FLATPAK_USER="$HOME/.local/share/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify"

        if [[ -d "$FLATPAK_SYSTEM" ]]; then
            SPOTIFY_PATH="$FLATPAK_SYSTEM"
        elif [[ -d "$FLATPAK_USER" ]]; then
            SPOTIFY_PATH="$FLATPAK_USER"
        else
            warn "Could not detect Flatpak Spotify path — set manually: spicetify config spotify_path <path>"
            SPOTIFY_PATH=""
        fi

        if [[ -n "$SPOTIFY_PATH" ]]; then
            "$SPICETIFY" config spotify_path "$SPOTIFY_PATH"
            sudo chmod a+wr "$SPOTIFY_PATH"
            sudo chmod a+wr -R "$SPOTIFY_PATH/Apps" 2>/dev/null || true
            ok "spotify_path + permissions set for $SPOTIFY_PATH"
        fi

        PREFS_SYSTEM="$HOME/.config/spotify/prefs"
        PREFS_USER="$HOME/.var/app/com.spotify.Client/config/spotify/prefs"

        if [[ -f "$PREFS_SYSTEM" ]]; then
            "$SPICETIFY" config prefs_path "$PREFS_SYSTEM"
            ok "prefs_path set to $PREFS_SYSTEM"
        elif [[ -f "$PREFS_USER" ]]; then
            "$SPICETIFY" config prefs_path "$PREFS_USER"
            ok "prefs_path set to $PREFS_USER"
        else
            warn "Could not detect prefs file — set manually: spicetify config prefs_path <path>"
        fi
        ;;
esac

# --- Apply Spicetify ---
"$SPICETIFY" backup apply
ok "Spicetify applied"

# ── 7. packages & utilities ───────────────────────────────────────────────────────
packages=(ghostty mpv fzf flatpak btop fastfetch wl-clipboard tree cmatrix cbonsai)

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

# ── 8. Fonts ─────────────────────────────────────────────────────────────────
FONTS=(AdwaitaMono Arimo DepartureMono FiraMono JetBrainsMono Lilex RobotoMono UbuntuMono)
mkdir -p ~/.fonts

for font in "${FONTS[@]}"; do
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip" \
    -o "/tmp/${font}.zip"
    unzip -o "/tmp/${font}.zip" -d "${HOME}/.fonts/${font}"
    rm "/tmp/${font}.zip"
done
fc-cache -fv
 
# ── 9. Rename ~/dotfiles → ~/.dotfiles ───────────────────────────────────────
exec zsh
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

# Spicetify symbolic links
cd "$DOTFILES_DST"
ln -s "${HOME}/.config/spicetify/config-xpui.ini" \
      "$DOTFILES_DST/spicetify/.config/spicetify/"
ln -s "${HOME}/.spicetify/spicetify" "$DOTFILES_DST/.bin/"

# ── 10. Stow configs ───────────────────────────────────────────────────────────
log "Stowing configs"
cd "$DOTFILES_DST"

for pkg in */; do
    stow -v --restow --adopt "$pkg"
    ok "Stowed $pkg"
done
ok "Stow done successfully"

git restore .
ok "Restored versioned configs"

# ── Done ──────────────────────────────────────────────────────────────────────
mkdir -vp ~/.icons

echo ""
echo -e "${GREEN}${BOLD}All done!${RESET}"
