#!/usr/bin/env bash

# Script to apply icon theme by changing packages .desktop Icon paramete
# Usage: ./apply_icon_theme <icon theme scalable apps path>

[ $# -ne 1 ] && echo "Usage: $0 <icon theme scalable apps dir>" && exit 1

ICON_DIR="$(realpath "$1")/"
GLOBAL_DIR="/usr/share/applications"
LOCAL_DIR="$HOME/.local/share/applications"
FLATPAK_GLOBAL_DIR="/var/lib/flatpak/exports/share/applications"
FLATPAK_LOCAL_DIR="$HOME/.local/share/flatpak/exports/share/applications"
TOTAL_MATCHED=0
TOTAL_SKIPPED=0

[ ! -d "$ICON_DIR" ] && echo "Error: '$ICON_DIR' does not exist." && exit 1

apply_icons() {
    local dir="$1"
    local use_sudo="$2"

    for f in "$dir"/*.desktop; do
        [ -f "$f" ] || continue
        icon_name=$(grep -Po '(?<=^Icon=)[^/].*' "$f" 2>/dev/null | head -1 || true)
        [ -z "$icon_name" ] && continue

        svg="${ICON_DIR}${icon_name}.svg"
        if [ -f "$svg" ]; then
            echo -e "  \033[32m✓\033[0m $(basename "$f") → $icon_name.svg"
            ((TOTAL_MATCHED++))
            [ "$DRY_RUN" = false ] &&
                $use_sudo sed -Ei "s|(Icon=)([^/].*)|\1$svg|" "$f"
        else
            echo -e "  \033[31m✗\033[0m $(basename "$f") → no match ($icon_name)"
            ((TOTAL_SKIPPED++))
        fi
    done
}

DRY_RUN=true
echo "=== Preview ==="
apply_icons "$GLOBAL_DIR" "sudo"
apply_icons "$LOCAL_DIR" ""
apply_icons "$FLATPAK_GLOBAL_DIR" "sudo"
apply_icons "$FLATPAK_LOCAL_DIR" ""

if [ "$TOTAL_MATCHED" -eq 0 ]; then
    echo ""
    echo "No matching icons found. Nothing to apply."
    exit 0
fi

echo "  matched: $TOTAL_MATCHED | skipped: $TOTAL_SKIPPED"
echo ""
read -rp "Apply changes? [y to confirm]: " answer
if [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    DRY_RUN=false
    apply_icons "$GLOBAL_DIR" "sudo"
    apply_icons "$FLATPAK_GLOBAL_DIR" "sudo"
    apply_icons "$FLATPAK_LOCAL_DIR" ""
    echo "Done."
    killall cosmic-panel
else
    echo "Aborted."
fi
