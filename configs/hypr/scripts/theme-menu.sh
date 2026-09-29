#!/bin/bash

CHOICE=$(echo -e "🖱️  Курсоры\n🔤  Шрифты" | rofi -dmenu -p "Тема" -theme ~/.config/rofi/theme-picker.rasi)

case "$CHOICE" in
    *"Курсоры"*) bash -c "sleep 0.3 && ~/.config/hypr/scripts/cursor-picker.sh" & ;;
    *"Шрифты"*) bash -c "sleep 0.3 && ~/.config/hypr/scripts/font-picker.sh" & ;;
esac
