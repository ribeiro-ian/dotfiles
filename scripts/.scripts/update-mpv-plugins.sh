#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

declare -A PLUGINS=(
  [modernz.lua]="https://raw.githubusercontent.com/Samillion/ModernZ/main/modernz.lua"
  [thumbfast.lua]="https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua"
)

for file in "${!PLUGINS[@]}"; do
  echo "Updating $file..."
  curl -fsSL "${PLUGINS[$file]}" -o "$SCRIPT_DIR/scripts/$file"
done

echo "Done."
