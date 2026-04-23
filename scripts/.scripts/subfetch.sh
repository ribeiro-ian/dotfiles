#!/usr/bin/env bash

# Usage: ./getsubs_folder.sh <folder> [extension]
# Extension defaults to mkv if not provided
# Examples:
#   ./getsubs_folder.sh /videos
#   ./getsubs_folder.sh /videos mp4
#   ./getsubs_folder.sh /videos avi

if [ -z "$1" ]; then
    echo "Usage: $0 <folder> [extension]"
    echo "  extension: file extension to match (default: mkv)"
    exit 1
fi

FOLDER="$1"
EXT="${2:-mkv}"
# Strip leading dot if user passed e.g. ".mp4"
EXT="${EXT#.}"

if [ ! -d "$FOLDER" ]; then
    echo "Error: '$FOLDER' is not a valid directory."
    exit 1
fi

cd "$FOLDER" || exit 1

for ep in *."$EXT"; do
    [ -e "$ep" ] || { echo "No .$EXT files found in '$FOLDER'."; break; }
    echo "==> Processing: $ep"
    OpenSubtitlesDownload.py "$ep" -l pt-br | head -25
    echo ""
done
