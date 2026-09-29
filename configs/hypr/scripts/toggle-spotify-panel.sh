#!/bin/bash

# Проверяем, запущена ли панель
if pgrep -f "spotify-panel.py" > /dev/null; then
    # Если запущена — убиваем (скрываем)
    pkill -f "spotify-panel.py"
else
    # Если не запущена — показываем
    python3 ~/.config/hypr/scripts/spotify-panel.py &
fi
