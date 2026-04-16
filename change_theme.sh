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
# Format: "file@sed_expression"
declare -a TARGETS=(
    "ghostty/.config/ghostty/config@\
    s|(theme = ).*|\1${THEME}|"
    
    "starship/.config/starship.toml@\
    s|(palette = ).*|\1'${THEME}'|"
)

echo "─────────────────────────────────────────────"
echo " Theme migration preview: '${THEME}'"
echo "─────────────────────────────────────────────"

# ────── Preview changes ──────
any_changes=0
for entry in "${TARGETS[@]}"; do
    file="${entry%%@*}"
    expr="${entry##*@}"
    filepath="${DOTFILES}/${file}"

    if [[ ! -f "$filepath" ]]; then
        echo ""
        echo "[SKIP] File not found: ${file}"
        continue
    fi

    preview=$(diff <(cat "$filepath") <(sed -E "$expr" "$filepath") || true)

    if [[ -z "$preview" ]]; then
        echo ""
        echo "[NO CHANGE] ${file}"
    else
        echo ""
        echo "[CHANGE] ${file}:"
        echo "$preview" \
            | grep -E "^[<>]" \
            | sed 's/^< /  OLD: /' \
            | sed 's/^> /  NEW: /'
        any_changes=1
    fi
done

# Spicetify preview
if [[ -f "$SPICETIFY_CONFIG" ]]; then
    current_scheme=$(grep -E "^color_scheme" "$SPICETIFY_CONFIG" | sed 's/.*= *//')

    if [[ "$current_scheme" == "$THEME" ]]; then
        echo ""
        echo "[NO CHANGE] spicetify (color_scheme already '${THEME}')"
    else
        echo ""
        echo "[CHANGE] spicetify:"
        echo "  OLD: color_scheme = ${current_scheme}"
        echo "  NEW: color_scheme = ${THEME}"
        any_changes=1
    fi
else
    echo ""
    echo "[SKIP] spicetify config not found"
fi

if [[ $any_changes -eq 0 ]]; then
    echo ""
    echo "No changes to apply. Is '${THEME}' already the active theme?"
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
        expr="${entry##*@}"
        filepath="${DOTFILES}/${file}"

        [[ ! -f "$filepath" ]] && continue

        sed -Ei "$expr" "$filepath"
        echo "[DONE] ${file}"
    done
    
    "$HOME/.spicetify/spicetify" config current_theme sonder
    "$HOME/.spicetify/spicetify" config color_scheme "${THEME}"
    "$HOME/.spicetify/spicetify" apply
    echo "[DONE] spicetify"

    echo ""
    echo "Theme '${THEME}' applied successfully."
else
    echo ""
    echo "Aborted. No files were modified."
    exit 0
fi