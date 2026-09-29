#!/bin/bash

if [ -z "$(cliphist list)" ]; then
    hyprctl notify 2 3000 "rgb(FF100)" "История буфера пуста"
    exit 0
fi

# Формируем список и выбираем через rofi, показывая только текст (2-ю колонку)
# ID (1-я колонка) автоматически передается в cliphist decode
CHOICE=$(cliphist list | rofi -dmenu -display-columns 2 -p "📋 Буфер обмена" -theme ~/.config/rofi/clipboard.rasi)

if [ -n "$CHOICE" ]; then
    echo "$CHOICE" | cliphist decode | wl-copy
    hyprctl notify 2 2000 "rgb(4CC9FE)" "Скопировано в буфер"
fi
