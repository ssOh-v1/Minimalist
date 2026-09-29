#!/bin/bash

THEME_DIR="$HOME/.config/waybar/themes"
COLORS_FILE="$HOME/.config/waybar/colors/colors.css"

THEMES=$(ls "$THEME_DIR"/*.css 2>/dev/null | xargs -n 1 basename | sed 's/\.css$//')

if [ -z "$THEMES" ]; then
    hyprctl notify 2 3000 "rgb(FFF100)" "Темы не найдены в $THEME_DIR"
    exit 1
fi

CHOICE=$(echo "$THEMES" | rofi -dmenu -p "🎨 Тема Waybar" -theme ~/.config/rofi/clipboard.rasi)

if [ -n "$CHOICE" ]; then
    cp "$THEME_DIR/$CHOICE.css" "$COLORS_FILE"
    killall waybar && waybar &
    hyprctl notify 2 2000 "rgb(4CC9FE)" "Тема: $CHOICE"
fi
