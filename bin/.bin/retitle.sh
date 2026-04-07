#!/bin/bash

# Script to set metadata titles for episode files based on a text file
# Usage: ./set-episode-titles.sh <titles.txt> <folder>

if [ $# -lt 2 ]; then
    echo "Usage: $0 <titles.txt> <folder>"
    echo "Example: $0 episode_titles.txt /path/to/episodes"
    exit 1
fi

TITLES_FILE="$1"
FOLDER="$2"

if [ ! -f "$TITLES_FILE" ]; then
    echo "Error: File '$TITLES_FILE' not found!"
    exit 1
fi

if [ ! -d "$FOLDER" ]; then
    echo "Error: Folder '$FOLDER' not found!"
    exit 1
fi

# Check if mkvpropedit is installed
if ! command -v mkvpropedit &> /dev/null; then
    echo "Error: mkvpropedit is not installed!"
    echo "Install it with: sudo apt install mkvtoolnix"
    exit 1
fi

# Get absolute path for titles file BEFORE changing directory
TITLES_FILE_ABS="$(realpath "$TITLES_FILE")"

# Change to the target folder
cd "$FOLDER" || exit 1
echo "Working in folder: $(pwd)"
echo ""

# Get all video files in the folder (sorted naturally)
mapfile -t VIDEO_FILES < <(ls -1v *.mkv *.mp4 *.avi 2>/dev/null | sort -V)

if [ ${#VIDEO_FILES[@]} -eq 0 ]; then
    echo "No video files found in folder!"
    exit 1
fi

echo "Found ${#VIDEO_FILES[@]} video files"
echo ""

# Read titles into array
mapfile -t TITLES < "$TITLES_FILE_ABS"

# Process each file
for i in "${!VIDEO_FILES[@]}"; do
    video_file="${VIDEO_FILES[$i]}"
    title="${TITLES[$i]}"
    
    if [ -z "$title" ]; then
        echo "Warning: No title for file #$((i+1)): $video_file (skipping)"
        continue
    fi
    
    echo "[$((i+1))/${#VIDEO_FILES[@]}] Setting title for: $video_file"
    echo "  Title: $title"
    
    # Set the title based on file extension
    if [[ "$video_file" == *.mkv ]]; then
        mkvpropedit "$video_file" --edit info --set "title=$title"
    elif [[ "$video_file" == *.mp4 ]] || [[ "$video_file" == *.m4v ]]; then
        # For MP4 files, use ffmpeg
        temp_file="${video_file}.temp.mp4"
        ffmpeg -i "$video_file" -metadata title="$title" -c copy "$temp_file" -y -loglevel quiet
        if [ $? -eq 0 ]; then
            mv "$temp_file" "$video_file"
        else
            echo "  Error: Failed to set title"
            rm -f "$temp_file"
        fi
    else
        echo "  Warning: Unsupported file format (only .mkv and .mp4 supported)"
    fi
    
    echo ""
done

echo "Done! Titles have been set."
