#!/bin/bash

if [ -z "$(cliphist list)" ]; then
    hyprctl notify 2 3000 "rgb(FF100)" "История буфера пуста"
    exit 0
fi

CHOICE=$(cliphist list | rofi -dmenu -display-columns 2 -p "🗑️ Удалить из буфера" -theme ~/.config/rofi/clipboard.rasi)

if [ -n "$CHOICE" ]; then
    echo "$CHOICE" | cliphist delete
    hyprctl notify 2 2000 "rgb(FF100)" "Элемент удалён"
fi
