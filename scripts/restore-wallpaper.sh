#!/bin/bash
# Восстанавливает hyprpaper.conf из актуального background.* и перезапускает hyprpaper

BG_DIR="/usr/share/sddm/themes/ii-sddm-theme/Backgrounds"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

TARGET=$(find "$BG_DIR" -maxdepth 1 -type f -iname "background.*" 2>/dev/null | head -1)

if [ -z "$TARGET" ]; then
    echo "Обои не найдены в $BG_DIR — восстановление пропущено."
    exit 0
fi

mkdir -p "$(dirname "$HYPRPAPER_CONF")"

cat > "$HYPRPAPER_CONF" << CONF
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
