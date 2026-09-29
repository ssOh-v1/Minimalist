#!/bin/bash

# Папки, где искать курсоры
CURSOR_DIRS=("$HOME/.icons" "$HOME/.local/share/icons" "/usr/share/icons")

# Получаем список курсоров
mapfile -t CURSORS < <(find "${CURSOR_DIRS[@]}" -maxdepth 2 -type d -name "cursors" 2>/dev/null | sed 's/cursors$//' | xargs -n 1 basename | sort -u)

# Получаем список шрифтов
mapfile -t FONTS < <(fc-list : family | sort -u)

# Функция для выбора курсора
select_cursor() {
    for cursor in "${CURSORS[@]}"; do
        echo -en "  $cursor\0icon\x1f$HOME/.icons/$cursor/cursors/default\n"
    done | rofi -dmenu -p "Курсор" -show-icons -theme ~/.config/rofi/theme-picker.rasi | while read -r choice; do
        choice=$(echo "$choice" | sed 's/^[^ ]* //')
        if [[ " ${CURSORS[@]} " =~ " $choice " ]]; then
            hyprctl setcursor "$choice" 24
            gsettings set org.gnome.desktop.interface cursor-theme "$choice"
            notify-send "Курсор" "Установлен: $choice"
        fi
    done
}

# Функция для выбора шрифта
select_font() {
    for font in "${FONTS[@]}"; do
        echo "  $font"
    done | rofi -dmenu -p "Шрифт" -theme ~/.config/rofi/theme-picker.rasi | while read -r choice; do
        choice=$(echo "$choice" | sed 's/^[^ ]* //')
        gsettings set org.gnome.desktop.interface font-name "$choice 11"
        notify-send "Шрифт" "Установлен: $choice"
    done
}

# Меню с двумя вкладками
rofi -show "Курсоры" -modi "Курсоры:select_cursor,Шрифты:select_font" -theme ~/.config/rofi/theme-picker.rasi
