#!/bin/bash

mapfile -t FONTS < <(fc-list : family | sort -u)

CHOICE=$(printf "%s\n" "${FONTS[@]}" | rofi -dmenu -p "Шрифт" -theme ~/.config/rofi/theme-picker.rasi)

if [ -n "$CHOICE" ]; then
    yad --title="Превью шрифта" --text="<span font='$CHOICE 24'>$CHOICE</span>\n\n<span font='$CHOICE 16'>Съешь ещё этих мягких французских булок, да выпей чаю.</span>" --button="Применить:0" --button="Отмена:1" --center
    
    if [ $? -eq 0 ]; then
        gsettings set org.gnome.desktop.interface font-name "$CHOICE 11"
        sed -i "s/^font_family.*/font_family $CHOICE/" ~/.config/kitty/kitty.conf
        sed -i "s/font-family:.*;/font-family: \"$CHOICE\", sans-serif;/" ~/.config/waybar/style.css
        killall waybar && waybar &
        notify-send "Шрифт" "Установлен: $CHOICE"
    fi
fi
