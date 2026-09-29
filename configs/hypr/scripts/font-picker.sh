#!/bin/bash

mapfile -t FONTS < <(fc-list : family | sort -u)

CHOICE=$(printf "%s\n" "${FONTS[@]}" | rofi -dmenu -p "Шрифт" -theme ~/.config/rofi/theme-picker.rasi)

if [ -n "$CHOICE" ]; then
    gsettings set org.gnome.desktop.interface font-name "$CHOICE 11"
    notify-send "Шрифт" "Установлен: $CHOICE"
fi
