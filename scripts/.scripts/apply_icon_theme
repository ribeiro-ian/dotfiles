#/usr/bin/env bash

# Script to apply icon theme by changing packages .desktop Icon paramete
# Usage: ./apply_icon_theme <icon theme scalable apps path>
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <icon theme scalable apps dir>"
    exit 1
fi

ICON_DIR="$(realpath "$1")/"
ICON_DIR="${ICON_DIR%/}/"
GLOBAL_DIR="/usr/share/applications"
LOCAL_DIR="$HOME/.local/share/applications"
FLATPAK_GLOBAL_DIR="/var/lib/flatpak/exports/share/applications"
FLATPAK_LOCAL_DIR="$HOME/.local/share/flatpak/exports/share/applications"
TOTAL_MATCHED=0

if [ ! -d "$ICON_DIR" ]; then
    echo "Error: '$ICON_DIR' does not exist."
    exit 1
fi

apply_icons() {
    local dir="$1"
    local use_sudo="$2"
    local matched=0 skipped=0

    for f in "$dir"/*.desktop; do
        [ -f "$f" ] || continue
        icon_name=$(grep -Po '(?<=^Icon=)[^/].*' "$f" 2>/dev/null || true)
        [ -z "$icon_name" ] && continue

        svg="$ICON_DIR/$icon_name.svg"
        if [ -f "$svg" ]; then
            echo "  ✓ $(basename "$f") → $icon_name.svg"
            (( TOTAL_MATCHED++ )) || true
            ["$DRY_RUN" = false ] && \
                $use_sudo sed -Ei "s|(Icon=)([^/].*)|\1$svg|" "$f"
        else
            echo "  ✗ $(basename "$f") → no match ($icon_name)"
            (( skipped++ )) || true
        fi
    done
    echo "  matched: $matched | skipped: $skipped"
}

DRY_RUN=true
echo "=== Preview ==="
apply_icons "$GLOBAL_DIR"        "sudo"
apply_icons "$FLATPAK_GLOBAL_DIR" "sudo"
apply_icons "$FLATPAK_LOCAL_DIR"  ""

if [ "$TOTAL_MATCHED" -eq 0 ]; then
    echo ""
    echo "No matching icons found. Nothing to apply."
    exit 0
fi

echo ""
read -rp "Apply changes? [y to confirm]: " answer
if [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    DRY_RUN=false
    apply_icons "$GLOBAL_DIR"         "sudo"
    apply_icons "$FLATPAK_GLOBAL_DIR" "sudo"
    apply_icons "$FLATPAK_LOCAL_DIR"  ""
    echo "Done."
else
    echo "Aborted."
fi
