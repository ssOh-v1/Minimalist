#!/bin/bash
# Window switcher using rofi/fuzzel logic with jq
# Requires: jq, fuzzel

# Get list of windows, format as "Workspace:Title", pipe to fuzzel
# We use address to identify the window uniquely
WINDOWS=$(hyprctl clients -j | jq -r '.[] | "\(.workspace.name) : \(.title) [\(.address)]"')

if [ -z "$WINDOWS" ]; then
    exit 0
fi

# Show fuzzel and get selection
SELECTED=$(echo "$WINDOWS" | fuzzel --dmenu --prompt="Switch > " --width=50 --lines=10)

if [ -n "$SELECTED" ]; then
    # Extract address (last part in brackets)
    ADDRESS=$(echo "$SELECTED" | grep -o '\[0x.*\]' | sed 's/\[//;s/\]//')
    
    # Focus the window
    hyprctl dispatch focuswindow address:$ADDRESS
fi
