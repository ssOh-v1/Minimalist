#!/bin/bash
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
NAME="Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
path="$DIR/$NAME"

# Take screenshot with selection
# Usage: ./screenshot.sh [region|fullscreen]
# But for now default to region selection as per user config history

if [ "$1" == "full" ]; then
    grim "$path"
else
    # selection
    selection=$(slurp)
    if [ -z "$selection" ]; then
        exit 0 # user cancelled
    fi
    grim -g "$selection" "$path"
fi

# Copy to clipboard if successful
if [ -f "$path" ]; then
    wl-copy < "$path"
    # Optional notification if notify-send is available
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Screenshot Saved" "Saved to $path" -i "$path"
    fi
fi
