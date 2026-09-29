#!/bin/bash

CURSOR_DIRS=("$HOME/.icons" "$HOME/.local/share/icons" "/usr/share/icons")

mapfile -t CURSORS < <(find "${CURSOR_DIRS[@]}" -maxdepth 2 -type d -name "cursors" 2>/dev/null | sed 's/cursors$//' | xargs -n 1 basename | sort -u)

for cursor in "${CURSORS[@]}"; do
    echo -en "  $cursor\0icon\x1f$HOME/.icons/$cursor/cursors/default\n"
done | rofi -dmenu -p "Курсор" -show-icons -theme ~/.config/rofi/theme-picker.rasi | while read -r choice; do
    choice=$(echo "$choice" | sed 's/^[^ ]* //')
    if [[ " ${CURSORS[@]} " =~ " $choice " ]]; then
        hyprctl setcursor "$choice" 24
        gsettings set org.gnome.desktop.interface cursor-theme "$choice"
        gsettings set org.gnome.desktop.interface cursor-size 24

        sed -i "s|^env = HYPRCURSOR_THEME,.*|env = HYPRCURSOR_THEME,$choice|" ~/.config/hypr/hyprland.conf
        sed -i "s|^env = XCURSOR_THEME,.*|env = XCURSOR_THEME,$choice|" ~/.config/hypr/hyprland.conf
        sed -i "s|^env = HYPRCURSOR_SIZE,.*|env = HYPRCURSOR_SIZE,24|" ~/.config/hypr/hyprland.conf
        sed -i "s|^env = XCURSOR_SIZE,.*|env = XCURSOR_SIZE,24|" ~/.config/hypr/hyprland.conf

        notify-send "Курсор" "Установлен и сохранён: $choice"
    fi
done
