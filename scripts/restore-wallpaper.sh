#!/bin/bash
# Восстанавливает hyprpaper.conf из шаблона и перезапускает hyprpaper

HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
TARGET="/usr/share/sddm/themes/ii-sddm-theme/Backgrounds/background.png"

mkdir -p "$(dirname "$HYPRPAPER_CONF")"

cat > "$HYPRPAPER_CONF" <<CONF
preload = $TARGET

wallpaper {
    monitor =
    path = $TARGET
    fit_mode = cover
}

splash = false
ipc = on
CONF

pkill hyprpaper
sleep 0.5
hyprpaper &

echo "hyprpaper восстановлен: $TARGET"
