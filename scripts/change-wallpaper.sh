#!/bin/bash

BG_DIR="/usr/share/sddm/themes/ii-sddm-theme/Backgrounds"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

CHOICE=$(find "$BG_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) ! -name "background.*" | while read -r wallpaper; do
    filename=$(basename "$wallpaper")
    echo -en "$filename\0icon\x1f$wallpaper\n"
done | rofi -dmenu -p "Обои" -show-icons -theme ~/.config/rofi/wallpaper.rasi -icon-size 8em)

if [ -z "$CHOICE" ]; then
    exit 0
fi

FULL_PATH="$BG_DIR/$CHOICE"

if [ -f "$FULL_PATH" ]; then
    # 1. Сохраняем выбранную картинку как background.<реальное расширение> для SDDM
    sudo /usr/local/bin/set-sddm-wallpaper.sh "$FULL_PATH"

    # 2. Находим актуальный файл (расширение может отличаться от предыдущего)
    TARGET=$(find "$BG_DIR" -maxdepth 1 -type f -iname "background.*" | head -1)

    # 3. Обновляем конфиг hyprpaper
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

    # 4. Перезапускаем hyprpaper
    pkill hyprpaper
    sleep 1
    hyprpaper &

    notify-send "Обои" "Установлены: $CHOICE"
else
    notify-send "Ошибка" "Не найден файл: $FULL_PATH"
fi
