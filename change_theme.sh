#!/usr/bin/env bash
# Dotfiles ─ change_theme.sh

# ────── Parameter validation ──────
if [[ $# -lt 1 ]]; then
    echo "Error: no theme specified." >&2
    echo "Usage: $0 <theme>" >&2
    exit 1
fi

if [[ $# -gt 1 ]]; then
    echo "Error: too many arguments (expected 1, got $#)." >&2
    echo "Usage: $0 <theme>" >&2
    exit 1
fi

THEME="$1"
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPICETIFY="$HOME/.spicetify/spicetify"
SPICETIFY_CONFIG="$HOME/.config/spicetify/config-xpui.ini"

# ────── Global counters ──────
any_changes=0
spicetify_change=0

# ────── Function to update a file ──────
# Usage: update_file <file_path> <pattern> <template> <create_if_missing>
update_file() {
    local file="$1"
    local pattern="$2"
    local template="$3"
    local create_if_missing="$4"
    
    local filepath="${DOTFILES}/${file}"
    local replacement="${template/\{theme\}/$THEME}"
    
    # Check if file exists
    if [[ ! -f "$filepath" ]]; then
        echo ""
        if [[ "$create_if_missing" == "true" ]]; then
            echo "[CREATE] ${file}:"
            echo "  NEW: ${replacement}"
            any_changes=1
            return 0  # Mark for creation, but don't create yet
        else
            echo "[SKIP] File not found: ${file}"
            return 1
        fi
    fi
    
    # Preview changes using diff
    local temp_file=$(mktemp)
    sed -E "s|${pattern}|${replacement}|" "$filepath" > "$temp_file"
    
    local preview=$(diff "$filepath" "$temp_file" 2>/dev/null || true)
    rm -f "$temp_file"
    
    if [[ -z "$preview" ]]; then
        echo ""
        echo "[NO CHANGE] ${file}"
        return 1
    else
        echo ""
        echo "[CHANGE] ${file}:"
        echo "$preview" |
            grep -E "^[<>]" |
            sed 's/^< /  OLD: /' |
            sed 's/^> /  NEW: /'
        any_changes=1
        return 0
    fi
}

# ────── Function to actually apply changes ──────
apply_file() {
    local file="$1"
    local pattern="$2"
    local template="$3"
    local create_if_missing="$4"
    
    local filepath="${DOTFILES}/${file}"
    local replacement="${template/\{theme\}/$THEME}"
    
    if [[ ! -f "$filepath" ]]; then
        if [[ "$create_if_missing" == "true" ]]; then
            mkdir -p "$(dirname "$filepath")"
            printf '%s\n' "$replacement" > "$filepath"
            echo "[CREATED] ${file}"
        fi
        return
    fi
    
    sed -Ei "s|${pattern}|${replacement}|" "$filepath"
    echo "[DONE] ${file}"
}

# ────── Define all managed files ──────
# Format: "file_path|pattern|template|create_if_missing"
declare -a FILE_CONFIGS=(
    "ghostty/.config/ghostty/theme.ghostty|\
^theme = .*|\
theme = {theme}|\
true"

    "neovim/.config/nvim/lua/config/colorscheme.lua|\
^return .*|\
return '{theme}'|\
true"

    "mpv/.config/mpv/script-opts/colorscheme.conf|\
^colorscheme=.*|\
colorscheme={theme}|\
true"

    "zen/profile.ian/chrome/current_theme.css|\
@import url\(.*\);|\
@import url('./themes/{theme}.css');|\
true"
)

# ────── Preview changes ──────
echo "─────────────────────────────────────────────"
echo " Theme migration preview: '${THEME}'"
echo "─────────────────────────────────────────────"

for config in "${FILE_CONFIGS[@]}"; do
    IFS='|' read -r file pattern template create <<< "$config"
    update_file "$file" "$pattern" "$template" "$create"
done

# ────── Spicetify preview ──────
if [[ -f "$SPICETIFY_CONFIG" ]]; then
    current_scheme=$(grep -E "^color_scheme" "$SPICETIFY_CONFIG" | sed 's/.*= *//')
    current_theme=$(grep -E "^current_theme" "$SPICETIFY_CONFIG" | sed 's/.*= *//')

    if [[ "$current_scheme" == "$THEME" && "$current_theme" == "Sonder" ]]; then
        echo ""
        echo "[NO CHANGE] spicetify (color_scheme already '${THEME}')"
    else
        echo ""
        echo "[CHANGE] spicetify:"

        if [[ "$current_theme" != "Sonder" ]]; then
            echo "  OLD: current_theme = ${current_theme}"
            echo "  NEW: current_theme = Sonder"
            echo " "
        fi

        if [[ "$current_scheme" != "$THEME" ]]; then
            echo "  OLD: color_scheme = ${current_scheme}"
            echo "  NEW: color_scheme = ${THEME}"
        fi
        any_changes=1
        spicetify_change=1
    fi
else
    echo ""
    echo "[SKIP] spicetify config not found"
fi

# ────── Check if any changes ──────
if [[ $any_changes -eq 0 ]]; then
    echo ""
    echo "No changes to apply. '${THEME}' is already the active theme."
    exit 0
fi

# ────── Confirmation ──────
echo ""
echo "─────────────────────────────────────────────"
read -rp "Apply changes? [y to confirm]: " answer

if [[ ! "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    echo ""
    echo "Aborted. No files were modified."
    exit 0
fi

# ────── Apply changes ──────
echo ""
for config in "${FILE_CONFIGS[@]}"; do
    IFS='|' read -r file pattern template create <<< "$config"
    apply_file "$file" "$pattern" "$template" "$create"
done

# ────── Apply spicetify changes ──────
if [[ "$spicetify_change" -eq 1 ]]; then
    echo "[DONE] spicetify"
    "$SPICETIFY" config current_theme Sonder
    "$SPICETIFY" config color_scheme "${THEME}"
fi

echo ""
echo "Theme '${THEME}' applied successfully."
