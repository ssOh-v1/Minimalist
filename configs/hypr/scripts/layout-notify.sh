#!/bin/bash
# Слушает события Hyprland и показывает уведомление при смене раскладки клавиатуры
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    if [[ "$line" == activelayout* ]]; then
        layout=$(echo "$line" | cut -d',' -f2)
        hyprctl notify 2 2000 "rgb(88c0d0)" "Layout: $layout"
    fi
done
