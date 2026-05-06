#!/usr/bin/env bash
# ============================================================================
# Dotfiles ─ change_theme.sh
# ============================================================================

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

# ────── Define files and their sed expressions ──────
# Format: "file@sed_expression@file_content"
# file_content: content of file that does not exist yet should have.
# Content empty ("@") for files that must already exist.
declare -a TARGETS=(
    "ghostty/.config/ghostty/theme@\
s|(theme = ).*|\1${THEME}|@\
theme = {$THEME}"

    "starship/.config/starship.toml@\
s|(palette = ).*|\1'${THEME}'|@"

    "neovim/.config/nvim/lua/config/colorscheme.lua@\
s|(return ).*|\1\"${THEME}\"|@\
return \"${THEME}\""

    "mpv/.config/mpv/script-opts/colorscheme.conf@\
s|(colorscheme=).*|\1${THEME}|@\
colorscheme=${THEME}"
)

echo "─────────────────────────────────────────────"
echo " Theme migration preview: '${THEME}'"
echo "─────────────────────────────────────────────"

# ────── Preview changes ──────
any_changes=0
spicetify_change=0
for entry in "${TARGETS[@]}"; do
    file="${entry%%@*}"
    rest="${entry#*@}"
    expr="${rest%%@*}"
    content="${rest##*@}" # empty string when third field is absent/blank
    filepath="${DOTFILES}/${file}"

    if [[ ! -f "$filepath" ]]; then
        echo ""
        if [[ -n "$content" ]]; then
            echo "[CREATE] ${file}:"
            echo "  NEW: ${content}"
            any_changes=1
        else
            echo "[SKIP] File not found: ${file}"
        fi
        continue
    fi

    preview=$(diff <(cat "$filepath") <(sed -E "$expr" "$filepath") || true)

    if [[ -z "$preview" ]]; then
        echo ""
        echo "[NO CHANGE] ${file}"
    else
        echo ""
        echo "[CHANGE] ${file}:"
        echo "$preview" |
            grep -E "^[<>]" |
            sed 's/^< /  OLD: /' |
            sed 's/^> /  NEW: /'
        any_changes=1
    fi
done

# Spicetify preview
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

if [[ $any_changes -eq 0 ]]; then
    echo ""
    echo "No changes to apply. '${THEME}' is already the active theme."
    exit 0
fi

# ────── Confirm ──────
echo ""
echo "─────────────────────────────────────────────"
read -rp "Apply changes? [y to confirm]: " answer

if [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    echo ""
    for entry in "${TARGETS[@]}"; do
        file="${entry%%@*}"
        rest="${entry#*@}"
        expr="${rest%%@*}"
        content="${rest##*@}"
        filepath="${DOTFILES}/${file}"

        if [[ ! -f "$filepath" ]]; then
            if [[ -n "$content" ]]; then
                mkdir -p "$(dirname "$filepath")"
                printf '%s\n' "$content" > "$filepath"
                echo "[CREATED] ${file}"
            fi
            continue
        fi

        sed -Ei "$expr" "$filepath"
        echo "[DONE] ${file}"
    done

    if [[ "$spicetify_change" -eq 1 ]]; then
        echo "[DONE] spicetify"
        "$SPICETIFY" config current_theme Sonder
        "$SPICETIFY" config color_scheme "${THEME}"
        "$SPICETIFY" apply
    fi

    echo ""
    echo "Theme '${THEME}' applied successfully."
else
    echo ""
    echo "Aborted. No files were modified."
    exit 0
fi
